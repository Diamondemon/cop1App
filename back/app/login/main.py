from fastapi.security import OAuth2PasswordRequestForm
from fastapi import HTTPException, status

from app.interfaces import BearerToken, UserCreationModel, UserCreationResponse
from app.database import DB, UserInDB, get_user, create_user as create_db_user
from app.login.crypto import check_password, randomword, hash_password


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
    decoded_username = token.access_token
    user = get_user(decoded_username)
    if user is None:
        raise unauthorized("Invalid authentication credentials")
    return user


def create_user(user_input: UserCreationModel) -> UserCreationResponse:
    if get_user(user_input.username) is not None:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT,
                            detail="Username already exists")
    salt = randomword(100)
    create_db_user(
        username=user_input.username,
        hashed_password=hash_password(salt, user_input.password),
        full_name="TODO",
        email="TODO",
        salt=salt
    )
    return UserCreationResponse()
