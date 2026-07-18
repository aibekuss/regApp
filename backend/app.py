# backend/app.py
from flask import Flask, request, jsonify
from flask_cors import CORS

from config import Config
from database import init_db
from models import (
    email_exists,
    phone_exists,
    create_user,
    get_user_by_email,
    get_user_by_id,
    update_user_profile,
    get_all_users,
)
from utils.security import SecurityUtils
from validators.auth_validator import AuthValidator
from middleware.auth_middleware import token_required
from sheets_service import add_user_to_sheet, update_user_in_sheet

app = Flask(__name__)

# Production-ready CORS configuration
CORS(app, resources={r"/*": {"origins": Config.ALLOWED_ORIGINS}})

# Initialize database schema
init_db()


@app.route("/register", methods=["POST"])
def register():
    """
    POST /register
    Registers a new user after strict validation and checks for duplicates.
    Saves to SQLite and syncs with Google Sheets.
    """
    data = request.get_json() or {}

    # 1. Backend validation
    is_valid, error_message = AuthValidator.validate_registration(data)
    if not is_valid:
        return jsonify({"success": False, "message": error_message}), 400

    first_name = data.get("first_name").strip()
    last_name = data.get("last_name").strip()
    age = int(data.get("age"))
    phone = data.get("phone").strip()
    email = data.get("email").strip().lower()
    password = data.get("password")

    # 2. Duplicate validation
    email_taken = email_exists(email)
    phone_taken = phone_exists(phone)

    if email_taken or phone_taken:
        return jsonify({
            "success": False, 
            "message": "Бұл электронды почта немесе телефон нөмірі бұрын тіркелген."
        }), 409

    # 3. Create user in SQLite (returns user_id, hashed_password, created_at)
    try:
        user_id, hashed_password, created_at = create_user(
            first_name, last_name, age, phone, email, password
        )
    except Exception as e:
        return jsonify({"success": False, "message": f"Database error: {str(e)}"}), 500

    # 4. Sync with Google Sheets
    add_user_to_sheet(user_id, first_name, last_name, age, phone, email, hashed_password, created_at)

    return jsonify({
        "success": True,
        "message": "Registration successful.",
        "user_id": user_id
    }), 201


@app.route("/login", methods=["POST"])
def login():
    """
    POST /login
    Supports authentication via Email OR Phone Number.
    Returns secure JWT token on success.
    """
    data = request.get_json() or {}
    email = (data.get("email") or "").strip().lower()
    phone = (data.get("phone") or "").strip()
    password = data.get("password") or ""

    if not (email or phone) or not password:
        return jsonify({"success": False, "message": "Электронды почта/Телефон нөмері және құпия сөз міндетті."}), 400

    user = None
    # Email арқылы іздеу
    if email:
        user = get_user_by_email(email)
    
    # Егер Email арқылы табылмаса, телефон нөмірі арқылы іздейміз
    if not user and phone:
        from database import get_connection
        connection = get_connection()
        cursor = connection.cursor()
        cursor.execute("SELECT * FROM users WHERE phone = ?", (phone,))
        row = cursor.fetchone()
        connection.close()
        if row:
            user = dict(row)

    # Парольді хэшпен салыстырып тексеру
    if user is None or not SecurityUtils.verify_password(password, user["password_hash"]):
        return jsonify({"success": False, "message": "Жарамсыз құпия сөз."}), 401

    # JWT токен генерациялау
    token = SecurityUtils.generate_jwt(user["id"], user["email"])

    return jsonify({
        "success": True,
        "message": "Login successful.",
        "token": token,
        "user": {
            "id": user["id"],
            "first_name": user["first_name"],
            "last_name": user["last_name"],
            "age": user["age"],
            "phone": user["phone"],
            "email": user["email"],
        }
    }), 200


@app.route("/user/profile", methods=["GET"])
@token_required
def get_profile():
    """
    GET /user/profile
    Protected endpoint to retrieve current user's profile details.
    """
    user_id = request.user["sub"]
    user = get_user_by_id(user_id)
    
    if not user:
        return jsonify({"success": False, "message": "User not found."}), 404

    return jsonify({
        "success": True,
        "user": {
            "id": user["id"],
            "first_name": user["first_name"],
            "last_name": user["last_name"],
            "age": user["age"],
            "phone": user["phone"],
            "email": user["email"],
        }
    }), 200


@app.route("/user/update", methods=["PUT"])
@token_required
def update_profile():
    """
    PUT /user/update
    Protected endpoint to update profile details.
    Saves changes locally in SQLite and synchronizes them with Google Sheets.
    """
    data = request.get_json() or {}
    user_id = request.user["sub"]

    first_name = (data.get("first_name") or "").strip()
    last_name = (data.get("last_name") or "").strip()
    age = data.get("age")
    phone = (data.get("phone") or "").strip()

    if not all([first_name, last_name, phone]) or age in (None, ""):
        return jsonify({"success": False, "message": "Аты-жөні, Жас немесе Телефон/Почта міндетті."}), 400

    try:
        age_int = int(age)
    except (ValueError, TypeError):
        return jsonify({"success": False, "message": "Жас сан форматта болуы керек."}), 400

    # 1. Update SQLite DB
    success = update_user_profile(user_id, first_name, last_name, age_int, phone)
    if not success:
        return jsonify({"success": False, "message": "Профильді жаңарту сәтсіз аяқталды немесе пайдаланушы табылмады."}), 404

    # 2. Sync changes to Google Sheets
    update_user_in_sheet(user_id, first_name, last_name, age_int, phone)

    return jsonify({
        "success": True,
        "message": "Профиль сәтті жаңартылды."
    }), 200


@app.route("/forgot-password", methods=["POST"])
def forgot_password():
    """
    POST /forgot-password
    API endpoint structure for forgot password.
    Designed to easily plug in email services (like SMTP or SendGrid) later.
    """
    data = request.get_json() or {}
    email = (data.get("email") or "").strip().lower()

    if not email:
        return jsonify({"success": False, "message": "Электронды почта міндетті."}), 400

    user = get_user_by_email(email)
    if not user:
        return jsonify({"success": False, "message": "Бұл электронды почта бойынша колданушы табылмады."}), 404

    # TODO: Generate a reset token, store it, and send a real email.
    # Currently acting as a backend structure ready for implementation.
    return jsonify({
        "success": True,
        "message": "Құпия сөзді қалпына келтіруді имитациялау сәтті өтті. SMTP баптауына дайын."
    }), 200


@app.route("/admin/users", methods=["GET"])
@token_required
def admin_get_users():
    """
    GET /admin/users
    Protected endpoint to display all registered users for the Admin Dashboard.
    """
    users = get_all_users()
    return jsonify({
        "success": True,
        "users": users
    }), 200


if __name__ == "__main__":
    # Runs on 0.0.0.0 to allow mobile emulators/devices to connect
    app.run(host="0.0.0.0", port=5000, debug=True)
