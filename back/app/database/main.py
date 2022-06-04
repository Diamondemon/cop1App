from app.database.utils import DB
from app.database.tables import User as UserInDB
from app.interfaces import UserCreationModel, UserCreationResponse
from app.logger import logger


def get_user(username: str) -> UserInDB | None:
    with DB:
        try:
            user = UserInDB.select().where(
                UserInDB.username == username
            ).get()
        except:
            return None
        return user


def create_user(user: UserCreationModel) -> UserCreationResponse:
    with DB:
        user = UserInDB.create(
            username=user.username,
            hashed_password=user.password,
            full_name="TODO",
            email="TODO",
            salt="TODO",
        )
    return UserCreationResponse()
