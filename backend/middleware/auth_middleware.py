# backend/middleware/auth_middleware.py
from functools import wraps
from flask import request, jsonify
from utils.security import SecurityUtils

def token_required(f):
    """
    Decorator to protect routes. Decodes JWT and attaches user info to the request.
    """
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        
        # Токенді Authorization header-ден іздейміз (Форматы: Bearer <token>)
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(" ")[1]
            except IndexError:
                return jsonify({"success": False, "message": "Bearer token format is invalid."}), 401

        if not token:
            return jsonify({"success": False, "message": "Authentication token is missing."}), 401

        # Токенді декодтау және тексеру
        result = SecurityUtils.decode_jwt(token)
        if not result["success"]:
            return jsonify({"success": False, "message": result["message"]}), 401

        # Токен ішіндегі мәліметтерді (user_id мен email) request-ке қосып жібереміз
        request.user = result["data"]
        return f(*args, **kwargs)

    return decorated
