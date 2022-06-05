from fastapi import Depends, APIRouter, HTTPException
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm

from app.login import login, create_user, user_from_token
from app.database import get_user
from app.interfaces.main import BearerToken, Token, User, UserCreationModel, UserCreationResponse
from app.logger import logger


app = APIRouter(tags=["login"])


oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/account/login")


@app.post("/account/create")
def new(user: UserCreationModel) -> UserCreationResponse:
    logger.info(f"Creating user : {user}")
    return create_user(user)


@app.post("/account/login")  # type: ignore
async def get_token(form_data: OAuth2PasswordRequestForm = Depends()) -> BearerToken:
    logger.info(f"Login attempt: {form_data.username}")
    return login(form_data)


@app.get("/account/me")
async def read_users_me(token: Token = Depends(oauth2_scheme)) -> User:
    username = user_from_token(BearerToken(access_token=token))
    user = get_user(username)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return User(
        username=username,
        email=user.email,
        full_name=user.full_name
    )
