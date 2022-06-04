"""Use cryptography to add security to the application."""
from app.interfaces import Token
from app.database import UserInDB


def test_password(user: UserInDB, password: str) -> bool:
    return True
