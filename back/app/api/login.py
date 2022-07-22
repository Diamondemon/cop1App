import re

from fastapi import Depends, APIRouter, HTTPException
from fastapi.security import APIKeyHeader

from app.login import user_login, create_user, user_from_token, update_user_password
from app.interfaces.main import *
from app.logger import logger
from app.database.tables import User as UserInDB, DB
from app.database.main import get_user

app = APIRouter(tags=["login"])

token = APIKeyHeader(name="bearer", description="Connection token")


@app.post("/account/create")
async def create_new_user(user: UserCreationModel) -> UserCreationResponse:
    logger.info("Creating user : %s", user)
    if not re.match('\\+33[1-9][0-9]{8}', user.phone):
        return UserCreationResponse(
                valid=False,
                message="Invalid phone number"
            )
    return create_user(user)


@app.post("/account/ask_validation")
async def ask_token_validation_sms(user: UserResetModel) -> UserValidationResponse:
    logger.info("Reset token for user : %s", user)
    return update_user_password(user)


@app.post("/account/login")
async def login(user: UserLoginModel) -> UserLoginResponse:
    logger.info(f"User {user} try to login")
    return UserLoginResponse(token=user_login(user.phone, user.code))


@app.get("/account/me")
async def read_users_me(_token: str = Depends(token)) -> UserModel:
    user = user_from_token(_token)
    logger.info('user %s is connected', user)
    return UserModel(
        phone=user.phone,
        email=user.email,
        first_name=user.first_name,
        last_name=user.last_name,
        events=[
            Event(
                id=e.id,
                url=e.url,
                date=str(e.date),
                title=e.title,
                img=e.img,
                loc=e.loc
            )
            for e in user.events
        ]
    )


@app.post("/account/me")
async def edit_users_me(edit: UserEditModel, _token: str = Depends(token)) -> BoolResponse:
    user = user_from_token(_token)
    logger.info('user %s is connected', user)
    logger.info(edit)
    if edit.email is not None:
        logger.info('email edited')
        user.email = edit.email
    if edit.first_name is not None:
        logger.info('first_name edited')
        user.first_name = edit.first_name
    if edit.last_name is not None:
        logger.info('last_name edited')
        user.last_name = edit.last_name
    user.save()
    return BoolResponse()


@app.delete("/account/me")
async def delete_account(_token: str = Depends(token)) -> BoolResponse:
    user = user_from_token(_token)
    logger.info('user %s request account deletion', user)
    user.delete().execute()
    return BoolResponse()
