from fastapi import Depends, APIRouter, HTTPException
from fastapi.security import APIKeyHeader, HTTPAuthorizationCredentials

from app.login import user_login, create_user, user_from_token, update_user_password
from app.interfaces.main import *
from app.logger import logger

app = APIRouter(tags=["login"])

token = APIKeyHeader(name="bearer", description="Connection token")


@app.post("/account/create")
async def create_new_user(user: UserCreationModel) -> UserCreationResponse:
    logger.info(f"Creating user : {user}")
    return create_user(user)


@app.post("/account/ask_validation")
async def ask_token_validation_sms(user: UserResetModel) -> UserValidationResponse:
    logger.info(f"Reset token for user : {user}")
    return update_user_password(user)


@app.post("/account/login")
async def login(user: UserLoginModel) -> UserLoginResponse:
    logger.info(f"User {user} try to login")
    return UserLoginResponse(token=user_login(user.phone, user.code))


@app.get("/account/me")
async def read_users_me(token: str = Depends(token)) -> UserModel:
    user = user_from_token(token)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    logger.info(f'user {user} is connected')
    return UserModel(phone=user)
