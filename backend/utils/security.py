# backend/utils/security.py
import datetime
import bcrypt
import jwt
from config import Config  # Сенің config.py файлыңа бағытталған импорт

class SecurityUtils:
    @staticmethod
    def hash_password(password: str) -> str:
        """Hash a plain text password using bcrypt."""
        salt = bcrypt.gensalt()
        return bcrypt.hashpw(password.encode('utf-8'), salt).decode('utf-8')

    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        """Compare a plain text password with its hash safely."""
        return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))

    @staticmethod
    def generate_jwt(user_id: int, email: str) -> str:
        """Generate a secure JWT token for the authenticated user."""
        try:
            payload = {
                'exp': datetime.datetime.utcnow() + Config.JWT_ACCESS_TOKEN_EXPIRES,
                'iat': datetime.datetime.utcnow(),
                'sub': user_id,
                'email': email
            }
            return jwt.encode(payload, Config.JWT_SECRET_KEY, algorithm='HS256')
        except Exception as e:
            raise RuntimeError(f"Token generation failed: {str(e)}")

    @staticmethod
    def decode_jwt(token: str) -> dict:
        """Decode and validate the provided JWT token."""
        try:
            payload = jwt.decode(token, Config.JWT_SECRET_KEY, algorithms=['HS256'])
            return {"success": True, "data": payload}
        except jwt.ExpiredSignatureError:
            return {"success": False, "message": "Token has expired."}
        except jwt.InvalidTokenError:
            return {"success": False, "message": "Invalid token."}