from pydantic import BaseModel


class BearerToken(BaseModel):
    access_token: str
    token_type: str = "bearer"


class User(BaseModel):
    username: str
    email: str | None = None
    full_name: str | None = None
