# Student Registration App — Setup & Testing Guide

A simple full-stack project for a university assignment:

- **Backend:** Python + Flask + SQLite
- **Frontend:** Dart + Flutter
- **Bonus:** every successful registration is also added to a Google Sheet

```
student_registration_app/
├── backend/
│   ├── app.py
│   ├── database.py
│   ├── models.py
│   ├── sheets_service.py
│   ├── config.py
│   └── requirements.txt
├── frontend/
│   ├── pubspec.yaml
│   └── lib/
│       ├── main.dart
│       ├── login_page.dart
│       ├── register_page.dart
│       ├── home_page.dart
│       └── api_service.dart
└── google_apps_script/
    └── Code.gs
```

---

## 1. Install dependencies

### Backend (Python)

You need Python 3.9+ installed.

```bash
cd backend
python -m venv venv          # optional but recommended
source venv/bin/activate      # on Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Frontend (Flutter)

You need the Flutter SDK installed (https://docs.flutter.dev/get-started/install) and either an Android emulator, iOS simulator, or a physical device connected.

The project doesn't come with the generated Flutter project files (`android/`, `ios/`, etc.) — only the `lib/` source code and `pubspec.yaml`, since those generated folders are large and machine-specific. Create the rest of the Flutter project shell first, then drop in the provided files:

```bash
cd frontend
flutter create . --project-name student_registration_app
flutter pub get
```

(The `flutter create .` command will add `android/`, `ios/`, `web/`, etc. around your existing `lib/` and `pubspec.yaml` — it won't overwrite the files you already have, but if it asks to overwrite `pubspec.yaml`, choose "no" and keep the one provided here.)

---

## 2. Configure Google Sheets

This project uses a **Google Apps Script Web App** instead of the full Google Sheets API — it's much simpler to set up for a student project (no service-account JSON keys, no Google Cloud Console).

1. Go to [sheets.google.com](https://sheets.google.com) and create a new blank spreadsheet (e.g. "Registered Students").
2. In the spreadsheet menu, click **Extensions > Apps Script**.
3. Delete any starter code in the editor, and paste in the contents of `google_apps_script/Code.gs`.
4. Click **Deploy > New deployment**.
5. Click the gear icon next to "Select type" and choose **Web app**.
6. Set:
   - **Execute as:** Me
   - **Who has access:** Anyone
7. Click **Deploy**. The first time, Google will ask you to authorize the script — click through and approve it (you may need to click "Advanced" > "Go to project (unsafe)" since it's your own unverified script).
8. Copy the **Web app URL** shown — it looks like:
   `https://script.google.com/macros/s/AKfycby.../exec`
9. Open `backend/config.py` and paste the URL into `GOOGLE_SHEETS_WEBHOOK_URL`:

```python
GOOGLE_SHEETS_WEBHOOK_URL = "https://script.google.com/macros/s/AKfycby.../exec"
```

That's it — no API keys needed. If you skip this step, registration will still work and save to SQLite; the backend will just print a console warning instead of writing to Sheets.

---

## 3. Run the Flask backend

```bash
cd backend
python app.py
```

You should see something like:

```
Database ready at: .../backend/students.db
 * Running on http://0.0.0.0:5000
```

The SQLite file `students.db` is created automatically on first run — you don't need to create it manually.

**Tip:** keep this terminal window open while testing the app.

---

## 4. Run the Flutter application

In a separate terminal:

```bash
cd frontend
flutter run
```

Pick your target device when prompted (emulator, simulator, or connected phone).

### Important — connecting to the backend

Open `frontend/lib/api_service.dart` and check the `baseUrl` value matches your setup:

| Where you run the app          | `baseUrl` value to use         |
|---------------------------------|---------------------------------|
| Android emulator                 | `http://10.0.2.2:5000`          |
| iOS simulator                    | `http://127.0.0.1:5000`         |
| Real phone (same Wi-Fi as PC)    | `http://<your-computer-IP>:5000` (e.g. `http://192.168.1.50:5000`) |

To find your computer's local IP: run `ipconfig` (Windows) or `ifconfig` / `ip addr` (Mac/Linux) and look for something like `192.168.x.x`.

---

## 5. Test registration and login

1. Launch the app — you'll land on the **Login** screen.
2. Tap **"Don't have an account? Register here"**.
3. Fill in Full Name, Age, Phone Number, Email, Password and tap **Register**.
   - Try submitting with a field empty → you should see a validation error.
   - Try an invalid email (e.g. `abc`) or phone (e.g. `12`) → you should see a format error.
4. On success, you'll see **"Registration successful."** and return to the Login screen.
5. Try registering the **same email or phone again** → you should see:
   - `"This email is already registered."`
   - `"This phone number is already registered."`
   - `"This user is already registered."` (if both match an existing user)
6. Go to **Login**, enter the same email/password you just registered with, and tap **Login**.
   - Wrong password or email → `"Invalid email or password."`
   - Correct credentials → you land on the **Home** screen showing your Full Name, Age, Phone, and Email.
7. Tap **Logout** → you return to the Login screen.

You can also test the API directly with `curl` while the Flask server is running:

```bash
curl -X POST http://127.0.0.1:5000/register \
  -H "Content-Type: application/json" \
  -d '{"full_name":"Jane Doe","age":21,"phone":"+15551234567","email":"jane@example.com","password":"secret123"}'

curl -X POST http://127.0.0.1:5000/login \
  -H "Content-Type: application/json" \
  -d '{"email":"jane@example.com","password":"secret123"}'

curl http://127.0.0.1:5000/user/1
```

---

## 6. Verify registrations appear in Google Sheets

1. After registering a new user in the app, open your Google Sheet.
2. A new row should appear automatically with: Full Name, Age, Phone Number, Email, and Registration Date & Time.
3. Check the terminal running `python app.py` — it prints `Saved to Google Sheets: <email>` when this succeeds, or a warning if it couldn't reach Google.
4. Try registering with a duplicate email/phone — confirm **no new row** is added to the sheet, since the backend rejects the request before it ever calls the Sheets webhook.

---

## How the duplicate-check logic works

On every `/register` request, the backend (in `app.py`) checks, in order:

1. Are all fields filled in?
2. Is the age a valid number?
3. Does the email match a valid email pattern?
4. Does the phone number match a valid phone pattern?
5. Does the email already exist in the database? Does the phone already exist?
   - Both exist → `"This user is already registered."`
   - Only email exists → `"This email is already registered."`
   - Only phone exists → `"This phone number is already registered."`
6. Only if all checks pass: insert the user into SQLite, hash their password, and send their data to Google Sheets.

The Flutter `register_page.dart` repeats the empty-field, email-format, and phone-format checks on the client side too, so users get instant feedback before a network request is even made — but the backend always re-checks everything itself, since client-side validation alone is never trustworthy.

---

## Notes for students

- Passwords are hashed with Werkzeug's `generate_password_hash` / `check_password_hash` before being stored — never store plain text passwords, even in a class project.
- This project intentionally skips authentication tokens (JWT/sessions) to keep things simple — the Home screen just receives the logged-in user's data directly after a successful login.
- If you want to reset the database during testing, just stop the Flask server and delete `backend/students.db`, then restart `python app.py` to get a fresh empty database.
