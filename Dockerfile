# ── Base image: Python 3.11 ───────────────────────────────────────────────────
FROM python:3.11-slim

# ── Set working directory ─────────────────────────────────────────────────────
WORKDIR /app

# ── Install curl (needed to download Microsoft packages) ──────────────────────
RUN apt-get update \
    && apt-get install curl -y

# ── Add Microsoft package signing key ────────────────────────────────────────
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

# ── Add Microsoft SQL Server package repository ───────────────────────────────
RUN curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list

# ── Update package list with Microsoft repository ─────────────────────────────
RUN apt-get update

# ── Install Microsoft ODBC Driver 18 for SQL Server ──────────────────────────
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql18

# ── Install Microsoft SQL Server tools ───────────────────────────────────────
RUN ACCEPT_EULA=Y apt-get install -y mssql-tools18

# ── Install unixODBC development headers ─────────────────────────────────────
RUN apt-get install -y unixodbc-dev

# ── Copy requirements first (allows Docker to cache this layer) ───────────────
COPY requirements.txt .

# ── Install Python dependencies ───────────────────────────────────────────────
RUN pip install --no-cache-dir --timeout=300 --retries=5 -r requirements.txt

# ── Copy the rest of the application code ────────────────────────────────────
COPY . .

# ── Expose Flask port ─────────────────────────────────────────────────────────
EXPOSE 5000

# ── Start the application ─────────────────────────────────────────────────────
CMD ["python", "app.py"]