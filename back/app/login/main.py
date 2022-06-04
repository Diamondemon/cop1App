from fastapi.security import OAuth2PasswordRequestForm
from fastapi import HTTPException, status

from app.interfaces import BearerToken, UserCreationModel, UserCreationResponse
from app.database import DB, UserInDB, get_user
from app.logger import logger
from app.login.crypto import check_password


def unauthorized(detail: str) -> HTTPException:
    return HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=detail)


def login(form_data: OAuth2PasswordRequestForm) -> BearerToken:
    user = get_user(form_data.username)
    if user is None:
        raise unauthorized("Unknown username.")
    if not check_password(user, form_data.password):
        raise unauthorized("Incorrect username or password")
    return token_from_user(user)


def token_from_user(user: UserInDB) -> BearerToken:
    # This doesn't provide any security at all
    return BearerToken(access_token=user.username)


def user_from_token(token: BearerToken) -> UserInDB:
    # This doesn't provide any security at all
    if token.token_type != "bearer":
        raise unauthorized("Invalid authentication credentials")
    with DB as db:
        decoded_username = token.access_token
        user = db.get_user(decoded_username)
    if user is None:
        raise unauthorized("Invalid authentication credentials")
    return user
