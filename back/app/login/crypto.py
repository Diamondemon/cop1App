"""Use cryptography to add security to the application."""
from app.interfaces import Token
from app.database import UserInDB
import hashlib
import random
import string


def randomword(length):
    return ''.join(random.choice(string.ascii_lowercase) for _ in range(length))


def check_password(user: UserInDB, password: str) -> bool:
    return hash_password(user.salt, password) == user.hashed_password


def hash_password(salt: str, password: str) -> str:
    string = salt + password
    return hashlib.sha256(string.encode('utf-8')).hexdigest()
