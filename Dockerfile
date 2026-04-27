# ── Base image: official Python 3.11 slim (lightweight Linux) ────────────────
FROM python:3.11-slim

# ── Set working directory inside the container ────────────────────────────────
WORKDIR /app

# ── Install system dependency required by pyodbc ─────────────────────────────
# unixodbc-dev provides the ODBC headers needed to compile pyodbc on Linux
RUN apt-get update && apt-get install -y \
    unixodbc-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# ── Copy requirements first (allows Docker to cache this layer) ───────────────
# If requirements.txt does not change, Docker skips reinstalling packages
COPY requirements.txt .

# ── Install Python dependencies ───────────────────────────────────────────────
RUN pip install --no-cache-dir -r requirements.txt

# ── Copy the rest of the application code ────────────────────────────────────
COPY . .

# ── Expose the port Flask runs on ────────────────────────────────────────────
EXPOSE 5000

# ── Start the Flask application ───────────────────────────────────────────────
# We use the flask command directly for production-safe startup
CMD ["python", "app.py"]
