# ── Base image: Python 3.11 slim ──────────────────────────────────────────────
FROM python:3.11-slim

# ── Set working directory inside the container ────────────────────────────────
WORKDIR /app

# ── Install Microsoft ODBC Driver 18 for SQL Server ──────────────────────────
# Step 1: Install curl, gnupg2 and apt-transport-https (needed to add Microsoft repo)
# Step 2: Download Microsoft signing key and convert to gpg format
# Step 3: Add Microsoft package repository
# Step 4: Install msodbcsql18 (actual ODBC driver pyodbc needs)
# Step 5: Install unixodbc-dev (ODBC development headers)
# Step 6: Clean up to reduce image size
RUN apt-get update && \
    apt-get install -y curl gnupg2 apt-transport-https && \
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/microsoft.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/11/prod bullseye main" > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 unixodbc-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# ── Copy requirements first (allows Docker to cache this layer) ───────────────
# If requirements.txt does not change Docker skips reinstalling packages
COPY requirements.txt .

# ── Install Python dependencies ───────────────────────────────────────────────
RUN pip install --no-cache-dir --timeout=300 --retries=5 -r requirements.txt

# ── Copy the rest of the application code ────────────────────────────────────
COPY . .

# ── Expose the port Flask runs on ────────────────────────────────────────────
EXPOSE 5000

# ── Start the Flask application ───────────────────────────────────────────────
CMD ["python", "app.py"]