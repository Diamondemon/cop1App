from pydantic import BaseModel
from typing import List

Token = str


class BearerToken(BaseModel):
    access_token: Token
    token_type: str = "bearer"


class Event(BaseModel):
    """An event."""
    id: int
    date: str
    url: str
    title: str
    img: str
    loc: str


class Events(BaseModel):
    """A list of events."""
    events: List[Event]


class UserModel(BaseModel):
    phone: str
    email: str
    first_name: str
    last_name: str
    events: List[Event]

    # email: str
    # full_name: str


class UserCreationModel(BaseModel):
    phone: str


class UserResetModel(BaseModel):
    phone: str


class UserLoginModel(BaseModel):
    phone: str
    code: str


class BoolResponse(BaseModel):
    valid: bool = True
    message: str = "Ok"


class UserCreationResponse(BoolResponse):
    pass


class UserValidationResponse(BoolResponse):
    pass


class UserLoginResponse(BoolResponse):
    token: BearerToken
