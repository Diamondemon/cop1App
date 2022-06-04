from venv import create
from fastapi import Depends, APIRouter
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm

from app.login import login, create_user
from app.interfaces.main import BearerToken, User, UserCreationModel, UserCreationResponse
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


@app.post("/account/me")
async def read_users_me(current_user: User = Depends(oauth2_scheme)) -> User:
    return current_user
