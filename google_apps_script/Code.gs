/**
 * Code.gs
 * --------
 * Paste this code into the Apps Script editor attached to the Google Sheet
 * that will store your registered users.
 *
 * It creates a simple Web App endpoint. Every time a student registers
 * successfully, the Flask backend sends an HTTP POST request here, and
 * this script appends a new row to the active sheet.
 *
 * SETUP STEPS (also explained in the README):
 *   1. Go to https://sheets.google.com and create a new spreadsheet.
 *   2. In the spreadsheet, open Extensions > Apps Script.
 *   3. Delete any starter code and paste this entire file in its place.
 *   4. Click "Deploy" > "New deployment".
 *   5. Click the gear icon next to "Select type" and choose "Web app".
 *   6. Set "Execute as" to "Me" and "Who has access" to "Anyone".
 *   7. Click "Deploy", then "Authorize access" and approve the permissions.
 *   8. Copy the Web App URL that is shown (it ends in /exec).
 *   9. Paste that URL into backend/config.py as GOOGLE_SHEETS_WEBHOOK_URL.
 */

function doPost(e) {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();

  // Add a header row automatically the first time this is used
  if (sheet.getLastRow() === 0) {
    sheet.appendRow(["Full Name", "Age", "Phone Number", "Email", "Registration Date & Time"]);
  }

  var data = JSON.parse(e.postData.contents);

  sheet.appendRow([
    data.full_name,
    data.age,
    data.phone,
    data.email,
    data.registered_at
  ]);

  return ContentService
    .createTextOutput(JSON.stringify({ status: "success" }))
    .setMimeType(ContentService.MimeType.JSON);
}
