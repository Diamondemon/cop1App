from pydantic import BaseModel

Token = str


class BearerToken(BaseModel):
    access_token: Token
    token_type: str = "bearer"


class UserModel(BaseModel):
    phone: str

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
