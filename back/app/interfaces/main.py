from pydantic import BaseModel
from typing import List

Token = str


class BearerToken(BaseModel):
    access_token: Token
    token_type: str = "bearer"


class BaseEvent(BaseModel):
    id: str
    date: str
    duration: str
    desc: str
    title: str
    img: str
    loc: str

class Event(BaseEvent):
    available: bool

class EventInscrit(BaseEvent):
    barcode: str


class Events(BaseModel):
    """A list of events."""
    events: List[Event]


class UserModel(BaseModel):
    phone: str
    email: str
    first_name: str
    last_name: str
    events: List[EventInscrit]
    min_event_delay_days: int

    # email: str
    # full_name: str


class UserEditModel(BaseModel):
    email: str | None
    first_name: str | None
    last_name: str | None


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


class ScanResponse(BaseModel):
    scanned: bool = True


class UserCreationResponse(BoolResponse):
    pass


class UserValidationResponse(BoolResponse):
    pass


class UserLoginResponse(BoolResponse):
    token: BearerToken


class SubscribeResponse(BaseModel):
    success: bool = True
    barcode: str = ""
    reason: str = ""
