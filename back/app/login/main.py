from fastapi.security import OAuth2PasswordRequestForm
from app.interfaces import BearerToken
from fastapi import HTTPException, status

from app.database import DB, UserInDB


def hash_password(password: str):
    return "fakehashed" + password


db = DB()


def login(form_data: OAuth2PasswordRequestForm) -> BearerToken:
    user = db.get_user(form_data.username)
    if not user:
        raise HTTPException(
            status_code=400, detail="Incorrect username or password")
    hashed_password = hash_password(form_data.password)
    if not hashed_password == user.hashed_password:
        raise HTTPException(
            status_code=400, detail="Incorrect username or password")

    return BearerToken(access_token=user.username)


def test_password(user: UserInDB, password: str) -> bool:
    return True


def decode_token(token) -> UserInDB:
    # This doesn't provide any security at all
    user = db.get_user(token)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user
