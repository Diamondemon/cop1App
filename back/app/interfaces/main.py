from pydantic import BaseModel

Token = str


class BearerToken(BaseModel):
    access_token: Token
    token_type: str = "bearer"


class User(BaseModel):
    email: str
    phone: str
    full_name: str


class UserCreationModel(BaseModel):
    email: str
    phone: str
    full_name: str
    password: str


class UserCreationResponse(BaseModel):
    vaild: bool = True
    message: str = "Ok"
