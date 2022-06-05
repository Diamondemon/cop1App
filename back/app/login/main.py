from fastapi.security import OAuth2PasswordRequestForm
from fastapi import HTTPException, status

from app.interfaces import BearerToken, UserCreationModel, UserCreationResponse
from app.database import DB, UserInDB, get_user, create_db_user
from app.login.crypto import check_password, randomword, hash_password, create_token, decode_token, InvalidToken


def unauthorized(detail: str) -> HTTPException:
    return HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=detail)


def conflict(detail: str) -> HTTPException:
    return HTTPException(status_code=status.HTTP_409_CONFLICT, detail=detail)


def login(form_data: OAuth2PasswordRequestForm) -> BearerToken:
    user = get_user(form_data.username)
    if user is None:
        raise unauthorized("Unknown username.")
    if not check_password(user, form_data.password):
        raise unauthorized("Incorrect username or password")
    return token_from_user(user)


def token_from_user(user: UserInDB) -> BearerToken:
    return BearerToken(access_token=create_token(user.username))


def user_from_token(token: BearerToken) -> str:
    if token.token_type != "bearer":
        raise unauthorized("Invalid authentication credentials")
    try:
        return decode_token(token.access_token)
    except InvalidToken as e:
        raise unauthorized(str(e))
    except Exception as e:
        raise unauthorized("Invalid authentication credentials")


def create_user(user_input: UserCreationModel) -> UserCreationResponse:
    if get_user(user_input.email) is not None:
        raise conflict("Username already exists")
    salt = randomword(100)
    if create_db_user(
        email=user_input.email,
        phone="TODO",
        full_name="TODO",
        hashed_password=hash_password(salt, user_input.password),
        salt=salt
    ):
        return UserCreationResponse()
    else:
        return UserCreationResponse(
            vaild=False,
            message="Failed to create user"
        )
