import os


class Config:
    # Database connection string — loaded from environment variable.
    # Locally you set this in a .env file or your shell.
    # In Azure it will be injected from Key Vault via the pipeline.
    DATABASE_URL = os.environ.get("DATABASE_URL", "")

    # Flask secret key (used internally by Flask)
    SECRET_KEY = os.environ.get("SECRET_KEY", "dev-secret-key")

    # Debug mode — always False in production
    DEBUG = os.environ.get("FLASK_DEBUG", "false").lower() == "true"
