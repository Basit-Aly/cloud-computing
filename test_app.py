import pytest
import json
from unittest.mock import patch, MagicMock
from app import app


@pytest.fixture
def client():
    """Create a test client for the Flask app."""
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


# ── Test 1: Health check endpoint ───────────────────────────────────────────
def test_health_check(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data["status"] == "ok"


# ── Test 2: Home page loads ──────────────────────────────────────────────────
def test_index_page(client):
    response = client.get("/")
    assert response.status_code == 200


# ── Test 3: Booking fails when required fields are missing ───────────────────
def test_booking_missing_fields(client):
    # Send incomplete booking data
    incomplete_data = {"name": "John"}
    response = client.post(
        "/api/booking",
        data=json.dumps(incomplete_data),
        content_type="application/json",
    )
    assert response.status_code == 400
    data = json.loads(response.data)
    assert "error" in data


# ── Test 4: Timeslots endpoint requires a date ───────────────────────────────
def test_timeslots_missing_date(client):
    response = client.get("/api/timeslots")
    assert response.status_code == 400
    data = json.loads(response.data)
    assert "error" in data


# ── Test 5: Menu endpoint returns a list (mocked DB) ────────────────────────
def test_get_menu_returns_list(client):
    # Mock the database connection so we don't need a real DB for CI tests
    mock_conn = MagicMock()
    mock_cursor = MagicMock()
    mock_conn.cursor.return_value = mock_cursor
    mock_cursor.fetchall.return_value = [
        (1, "Grilled Chicken", "Juicy grilled chicken", 12.99, "Main Course"),
        (2, "Caesar Salad", "Fresh Caesar salad", 7.99, "Starter"),
    ]

    with patch("app.get_db_connection", return_value=mock_conn):
        response = client.get("/api/menu")
        assert response.status_code == 200
        data = json.loads(response.data)
        assert isinstance(data, list)
        assert len(data) == 2
        assert data[0]["name"] == "Grilled Chicken"


# ── Test 6: About page returns correct information ───────────────────────────
def test_about_page(client):
    response = client.get("/about")
    assert response.status_code == 200
    data = json.loads(response.data)
    assert data["restaurant"] == "Click & Dine"