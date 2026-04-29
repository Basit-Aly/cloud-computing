from flask import Flask, render_template, request, jsonify
import pyodbc
# import os   flake8 found that we imported os but never used it. This is a code quality issue.
from config import Config

app = Flask(__name__)
app.config.from_object(Config)


def get_db_connection():
    """Create and return a database connection."""
    conn = pyodbc.connect(app.config["DATABASE_URL"])
    return conn


# ── Health check (used by CI/CD pipeline to verify deployment) ──────────────
@app.route("/health")
def health():
    return jsonify({"status": "ok"}), 200


# ── Home page ────────────────────────────────────────────────────────────────
@app.route("/")
def index():
    return render_template("index.html")


# ── Return all menu items ────────────────────────────────────────────────────
@app.route("/api/menu", methods=["GET"])
def get_menu():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, name, description, price, category FROM MenuItems")
    rows = cursor.fetchall()
    conn.close()

    menu = [
        {
            "id": row[0],
            "name": row[1],
            "description": row[2],
            "price": float(row[3]),
            "category": row[4],
        }
        for row in rows
    ]
    return jsonify(menu), 200


# ── Create a new booking ─────────────────────────────────────────────────────
@app.route("/api/booking", methods=["POST"])
def create_booking():
    data = request.get_json()

    # Basic validation
    required = ["name", "phone", "date", "time", "guests", "menu_items"]
    for field in required:
        if field not in data:
            return jsonify({"error": f"Missing field: {field}"}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    # Insert booking into Bookings table
    cursor.execute(
        """
        INSERT INTO Bookings (customer_name, phone, booking_date, booking_time, guests, total_amount)
        OUTPUT INSERTED.id
        VALUES (?, ?, ?, ?, ?, ?)
        """,
        data["name"],
        data["phone"],
        data["date"],
        data["time"],
        data["guests"],
        data["total_amount"],
    )
    booking_id = cursor.fetchone()[0]

    # Insert each selected menu item into BookingItems table
    for item in data["menu_items"]:
        cursor.execute(
            """
            INSERT INTO BookingItems (booking_id, menu_item_id, quantity)
            VALUES (?, ?, ?)
            """,
            booking_id,
            item["id"],
            item["quantity"],
        )

    conn.commit()
    conn.close()

    return jsonify({"message": "Booking confirmed!", "booking_id": booking_id}), 201


# ── Get available time slots for a given date ────────────────────────────────
@app.route("/api/timeslots", methods=["GET"])
def get_timeslots():
    date = request.args.get("date")
    if not date:
        return jsonify({"error": "Date is required"}), 400

    # Fixed available time slots for the restaurant
    all_slots = ["12:00", "13:00", "14:00", "18:00", "19:00", "20:00", "21:00"]

    conn = get_db_connection()
    cursor = conn.cursor()

    # Find slots already booked on this date
    cursor.execute(
        "SELECT booking_time FROM Bookings WHERE booking_date = ?", date
    )
    booked = [str(row[0])[:5] for row in cursor.fetchall()]
    conn.close()

    # Return slots with availability flag
    slots = [
        {"time": slot, "available": slot not in booked} for slot in all_slots
    ]
    return jsonify(slots), 200

# debug=True in Flask exposes the Werkzeug debugger which allows anyone to execute arbitrary code on our server. Bandit flagged this as a High severity security issue
if __name__ == "__main__":
    app.run(debug=False, host="0.0.0.0", port=5000)