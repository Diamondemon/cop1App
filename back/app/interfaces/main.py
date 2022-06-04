from pydantic import BaseModel

Token = str


class BearerToken(BaseModel):
    access_token: Token
    token_type: str = "bearer"


class User(BaseModel):
    username: str
    email: str | None = None
    full_name: str | None = None


class UserCreationModel(BaseModel):
    username: str
    password: str


class UserCreationResponse(BaseModel):
    vaild: bool = True
    message: str = "Ok"
