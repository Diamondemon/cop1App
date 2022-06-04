"""Use cryptography to add security to the application."""
from app.interfaces import Token
from app.database import UserInDB


def check_password(user: UserInDB, password: str) -> bool:
    return True


def hash_password(salt: str, password: str) -> str:
    return "hashed_password"
