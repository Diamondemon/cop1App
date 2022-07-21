import re

from fastapi import Depends, APIRouter, HTTPException
from fastapi.security import APIKeyHeader

from app.login import user_login, create_user, user_from_token, update_user_password
from app.interfaces.main import *
from app.logger import logger
from app.database.tables import User as UserInDB

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
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    logger.info('user %s is connected', user)
    return UserModel(
        phone=user,
        events=[
            Event(
                id=e.id,
                url=e.url,
                date=str(e.date),
                title=e.title,
                img=e.img,
                loc=e.loc
            )
            for e in UserInDB.get(UserInDB.phone == user).events
        ]
    )
