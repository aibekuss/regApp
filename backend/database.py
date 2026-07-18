"""
database.py
-----------
Handles creation and migration of the SQLite database and the `users` table.
"""

import sqlite3
from config import Config

def get_connection():
    """
    Create and return a new connection to the SQLite database.
    """
    connection = sqlite3.connect(Config.DATABASE_PATH)
    connection.row_factory = sqlite3.Row
    return connection

def init_db():
    """
    Create the `users` table if it doesn't exist yet.
    Migrates old schema automatically if detected.
    """
    connection = get_connection()
    cursor = connection.cursor()

    # Check if the old schema (with full_name) exists
    cursor.execute("PRAGMA table_info(users)")
    columns = [row[1] for row in cursor.fetchall()]
    
    if columns and "full_name" in columns:
        print("⚠️ Old database schema detected. Recreating table for migration...")
        cursor.execute("DROP TABLE users")
        connection.commit()

    # Create table with production-ready fields
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            age INTEGER NOT NULL,
            phone TEXT NOT NULL UNIQUE,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            created_at TEXT NOT NULL
        )
    """)

    connection.commit()
    connection.close()
    print("✅ SQLite database is ready at:", Config.DATABASE_PATH)

if __name__ == "__main__":
    init_db()
