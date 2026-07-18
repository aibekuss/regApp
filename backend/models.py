"""
models.py
---------
Contains all SQLite database operations for users.
Utilizes secure Bcrypt hashing for password security.
"""

from datetime import datetime
from database import get_connection
from utils.security import SecurityUtils

def email_exists(email: str) -> bool:
    """Return True if a user with this email exists in the database."""
    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute("SELECT id FROM users WHERE email = ?", (email.strip().lower(),))
    result = cursor.fetchone()
    connection.close()
    return result is not None

def phone_exists(phone: str) -> bool:
    """Return True if a user with this phone number exists in the database."""
    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute("SELECT id FROM users WHERE phone = ?", (phone.strip(),))
    result = cursor.fetchone()
    connection.close()
    return result is not None

def create_user(first_name: str, last_name: str, age: int, phone: str, email: str, password: str):
    """
    Insert a new user with hashed password.
    Returns: (user_id, hashed_password, created_at_timestamp)
    """
    hashed_password = SecurityUtils.hash_password(password)
    created_at = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")

    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute(
        """
        INSERT INTO users (first_name, last_name, age, phone, email, password_hash, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """,
        (first_name.strip(), last_name.strip(), age, phone.strip(), email.strip().lower(), hashed_password, created_at),
    )
    connection.commit()
    new_id = cursor.lastrowid
    connection.close()
    return new_id, hashed_password, created_at

def get_user_by_email(email: str) -> dict:
    """Fetch user dictionary by email (used for login)."""
    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM users WHERE email = ?", (email.strip().lower(),))
    user = cursor.fetchone()
    connection.close()
    return dict(user) if user else None

def get_user_by_id(user_id: int) -> dict:
    """Fetch user dictionary by ID."""
    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
    user = cursor.fetchone()
    connection.close()
    return dict(user) if user else None

def update_user_profile(user_id: int, first_name: str, last_name: str, age: int, phone: str) -> bool:
    """Update user's profile information in SQLite database."""
    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute(
        """
        UPDATE users
        SET first_name = ?, last_name = ?, age = ?, phone = ?
        WHERE id = ?
        """,
        (first_name.strip(), last_name.strip(), age, phone.strip(), user_id),
    )
    connection.commit()
    success = cursor.rowcount > 0
    connection.close()
    return success

def get_all_users() -> list:
    """Fetch all users for the Admin Dashboard (excluding password hashes)."""
    connection = get_connection()
    cursor = connection.cursor()
    cursor.execute("""
        SELECT id, first_name, last_name, age, phone, email, created_at 
        FROM users 
        ORDER BY id DESC
    """)
    users = [dict(row) for row in cursor.fetchall()]
    connection.close()
    return users