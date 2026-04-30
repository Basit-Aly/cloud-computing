# ── Base image: Python 3.11 full image ───────────────────────────────────────
# Using full image (not slim) because it includes apt-key and other tools
# required to install Microsoft ODBC Driver 18 for SQL Server
FROM python:3.11

# ── Set working directory inside the container ────────────────────────────────
WORKDIR /app

# ── Install curl (needed to download Microsoft packages) ──────────────────────
RUN apt-get update \
    && apt-get install curl -y

# ── Add Microsoft package signing key ────────────────────────────────────────
# This tells apt to trust packages from Microsoft's repository
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

# ── Add Microsoft SQL Server package repository ───────────────────────────────
# This tells apt where to find Microsoft SQL Server packages
RUN curl https://packages.microsoft.com/config/debian/11/prod.list > /etc/apt/sources.list.d/mssql-release.list

# ── Update package list with Microsoft repository ─────────────────────────────
RUN apt-get update

# ── Install Microsoft ODBC Driver 18 for SQL Server ──────────────────────────
# This is the actual driver pyodbc uses to connect to Azure SQL Database
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql18

# ── Install Microsoft SQL Server command line tools ───────────────────────────
# Includes sqlcmd and other SQL Server utilities
RUN ACCEPT_EULA=Y apt-get install -y mssql-tools18

# ── Install unixODBC development headers ─────────────────────────────────────
# Required by pyodbc to compile and link against ODBC libraries
RUN apt-get install -y unixodbc-dev

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