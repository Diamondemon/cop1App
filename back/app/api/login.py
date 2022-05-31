from fastapi import Depends, APIRouter
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel

from app.login import login, decode_token
from app.interfaces.main import BearerToken, User


app = APIRouter(tags=["login"])


oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")


@app.post("/token")  # type: ignore
async def login(token: BearerToken = Depends(login)) -> BearerToken:
    return token


@app.get("/users/me")
async def read_users_me(current_user: User = Depends(decode_token)) -> User:
    return current_user
