# backend/config.py
import os
from datetime import timedelta
from dotenv import load_dotenv

# .env файлындағы айнымалыларды жүктейміз
load_dotenv()

DATABASE_PATH = os.getenv("DATABASE_PATH", "students.db")
GOOGLE_SHEETS_WEBHOOK_URL = os.getenv("GOOGLE_SHEET_URL", "https://script.google.com/macros/s/AKfycbxcVoABW0Cr__eN8eA4qDGICEWUVkmC8pnrLx_FvNkxGB64FnjDgKE7FYQRUj1RlnkmZQ/exec")

class Config:
    DATABASE_PATH = DATABASE_PATH
    GOOGLE_SHEETS_WEBHOOK_URL = GOOGLE_SHEETS_WEBHOOK_URL
    
    # JWT Қауіпсіздік баптаулары
    JWT_SECRET_KEY = os.getenv("JWT_SECRET", "super-secret-key-change-this")
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=2)
    
    # Рұқсат етілген домендер (CORS)
    ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "*").split(",")
    