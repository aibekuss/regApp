# backend/validators/auth_validator.py
import re

EMAIL_PATTERN = r"^[^\s@]+@[^\s@]+\.[^\s@]+$"
PHONE_PATTERN = r"^\+?[0-9]{7,15}$"  # Мысалы: +77071234567 немесе 87071234567

class AuthValidator:
    @staticmethod
    def validate_registration(data: dict) -> tuple[bool, str]:
        """
        Validates registration fields on the backend level.
        Returns (is_valid, error_message).
        """
        first_name = (data.get("first_name") or "").strip()
        last_name = (data.get("last_name") or "").strip()
        age = data.get("age")
        phone = (data.get("phone") or "").strip()
        email = (data.get("email") or "").strip().lower()
        password = data.get("password") or ""
        confirm_password = data.get("confirm_password") or ""

        # 1. Бос өрістерді тексеру
        if not all([first_name, last_name, phone, email, password, confirm_password]) or age in (None, ""):
            return False, "All fields are required."

        # 2. Жастың сан екенін тексеру
        try:
            age_int = int(age)
            if age_int <= 0 or age_int > 120:
                return False, "Please enter a valid age."
        except (ValueError, TypeError):
            return False, "Age must be a valid number."

        # 3. Email форматы
        if not re.match(EMAIL_PATTERN, email):
            return False, "Invalid email format."

        # 4. Телефон форматы
        if not re.match(PHONE_PATTERN, phone):
            return False, "Invalid phone number format."

        # 5. Пароль ұзындығы (кем дегенде 6 символ)
        if len(password) < 6:
            return False, "Password must be at least 6 characters long."

        # 6. Парольдердің сәйкестігі
        if password != confirm_password:
            return False, "Passwords do not match."

        return True, ""