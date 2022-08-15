import re

from fastapi import Depends, APIRouter, HTTPException
from fastapi.security import APIKeyHeader

from app.login import user_login, create_user, user_from_token, update_user_password
from app.interfaces.main import *
from app.logger import logger
from app.database.tables import User as UserInDB, Event as EventInDB, Inscription as InscriptionInDB, DB
from app.database.main import get_user
from app.tools import check_email, check_username

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
    evt = UserInDB \
        .select(InscriptionInDB, EventInDB) \
        .join(InscriptionInDB, on=(UserInDB.phone == InscriptionInDB.user)) \
        .join(EventInDB, on=(EventInDB.id == InscriptionInDB.event)) \
        .where(UserInDB == user.phone)
    return UserModel(
        phone=user.phone,
        email=user.email,
        first_name=user.first_name,
        last_name=user.last_name,
        events=[
            Event(
                id=str(e.id),
                date=str(e.date),
                duration=str(e.duration),
                desc=str(e.desc),
                title=str(e.title),
                img=str(e.img),
                loc=str(e.loc),
            )
            for e in evt
        ]
    )


@app.post("/account/me")
async def edit_users_me(edit: UserEditModel, _token: str = Depends(token)) -> BoolResponse:
    user = user_from_token(_token)
    logger.info('user %s is connected', user)
    logger.info(edit)
    if edit.email is not None:
        if check_email(edit.email):
            logger.info('email edited')
            user.email = edit.email
        else:
            logger.info('invalid email')
            return BoolResponse(valid=False, message='email')
    if edit.first_name is not None:
        if check_username(edit.first_name):
            logger.info('first_name edited')
            user.first_name = edit.first_name
        else:
            logger.info('invalid first_name')
            return BoolResponse(valid=False, message='first_name')
    if edit.last_name is not None:
        if check_username(edit.last_name):
            logger.info('last_name edited')
            user.last_name = edit.last_name
        else:
            logger.info('invalid last_name')
            return BoolResponse(valid=False, message='last_name')
    user.save()
    return BoolResponse()


@app.delete("/account/me")
async def delete_account(_token: str = Depends(token)) -> BoolResponse:
    user = user_from_token(_token)
    logger.info('user %s request account deletion', user)
    user.events.remove(user.events)
    user.delete_instance()
    return BoolResponse()
