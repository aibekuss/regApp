"""
sheets_service.py
------------------
Synchronizes user registration and updates with Google Sheets database.
Uses unified API payload structure supporting create and update actions.
"""

import requests
from config import Config  # Сенің config.py файлыңа бағытталған импорт

def add_user_to_sheet(user_id, first_name, last_name, age, phone, email, password_hash, created_at):
    """
    Send newly registered user data to the connected Google Sheet.
    """
    payload = {
        "action": "create",
        "id": user_id,
        "first_name": first_name,
        "last_name": last_name,
        "age": age,
        "phone": phone,
        "email": email,
        "password_hash": password_hash,
        "created_at": created_at,
    }

    if not Config.GOOGLE_SHEETS_WEBHOOK_URL or "PASTE_YOUR" in Config.GOOGLE_SHEETS_WEBHOOK_URL:
        print("⚠️ Google Sheets URL is not configured in .env - skipping sync.")
        return

    try:
        response = requests.post(Config.GOOGLE_SHEETS_WEBHOOK_URL, json=payload, timeout=5)
        if response.status_code == 200:
            print(f"📡 Sync successful: Created user {email} in Google Sheets.")
        else:
            print(f"❌ Google Sheets returned error status: {response.status_code}")
    except requests.exceptions.RequestException as error:
        print(f"❌ Google Sheets synchronization failed: {error}")

def update_user_in_sheet(user_id, first_name, last_name, age, phone):
    """
    Update existing user data in Google Sheet dynamically by ID.
    """
    payload = {
        "action": "update",
        "id": user_id,
        "first_name": first_name,
        "last_name": last_name,
        "age": age,
        "phone": phone
    }

    if not Config.GOOGLE_SHEETS_WEBHOOK_URL or "PASTE_YOUR" in Config.GOOGLE_SHEETS_WEBHOOK_URL:
        print("⚠️ Google Sheets URL is not configured in .env - skipping update.")
        return

    try:
        response = requests.post(Config.GOOGLE_SHEETS_WEBHOOK_URL, json=payload, timeout=5)
        if response.status_code == 200:
            print(f"📡 Sync successful: Updated user ID {user_id} in Google Sheets.")
        else:
            print(f"❌ Google Sheets returned error status on update: {response.status_code}")
    except requests.exceptions.RequestException as error:
        print(f"❌ Google Sheets update sync failed: {error}")
        