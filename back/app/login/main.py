from fastapi import HTTPException, status

from app.interfaces import BearerToken, UserCreationModel, UserCreationResponse, UserResetModel, UserValidationResponse
from app.database import DB, UserInDB, get_user, create_db_user, create_db_user, update_db_user_password
from app.login.crypto import check_password, randomword, hash_password, create_token, decode_token, InvalidToken
from app.sms import generate_and_send_token


def unauthorized(detail: str) -> HTTPException:
    return HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=detail)


def conflict(detail: str) -> HTTPException:
    return HTTPException(status_code=status.HTTP_409_CONFLICT, detail=detail)


def user_login(phone: str, code: str) -> BearerToken:
    user = get_user(phone)
    if user is None:
        raise unauthorized("Unknown username.")
    if not check_password(user, code):
        raise unauthorized("Incorrect username or password")
    return token_from_user(user)


def token_from_user(user: UserInDB) -> BearerToken:
    return BearerToken(access_token=create_token(user.phone))


def user_from_token(token: str) -> UserInDB:
    try:
        username = decode_token(token)
        if (user := get_user(username)) is not None:
            return user
        raise unauthorized("Invalid authentication credentials")
    except InvalidToken as e:
        raise unauthorized(str(e))
    except Exception as e:
        raise unauthorized("Invalid authentication credentials")


def create_user(user_input: UserCreationModel) -> UserCreationResponse:
    phone = user_input.phone
    if get_user(phone) is not None:
        raise conflict("Username already exists")
    salt = randomword(100)
    password = generate_and_send_token(phone)

    if create_db_user(
        phone=phone,
        hashed_password=hash_password(salt, password),
        salt=salt
    ):
        return UserCreationResponse()
    else:
        return UserCreationResponse(
            valid=False,
            message="Failed to create user"
        )


def update_user_password(user_input: UserResetModel) -> UserValidationResponse:
    user = get_user(user_input.phone)
    if user is None:
        raise conflict("Unknown username")
    salt = user.salt
    password = generate_and_send_token(user.phone)
    update_db_user_password(user.phone, hash_password(salt, password))
    return UserValidationResponse()
