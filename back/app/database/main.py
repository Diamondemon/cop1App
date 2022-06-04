from app.database.utils import DB
from app.database.tables import User as UserInDB
from app.interfaces import UserCreationModel, UserCreationResponse


def get_user(username: str) -> UserInDB | None:
    with DB:
        try:
            user = UserInDB.select().where(
                UserInDB.username == username
            ).get()
        except:
            return None
        return user


def create_user(
    username: str,
    hashed_password: str,
    full_name: str,
    email: str,
    salt: str
) -> UserCreationResponse:
    with DB:
        UserInDB.create(
            username=username,
            hashed_password=hashed_password,
            full_name=full_name,
            email=email,
            salt=salt,
        )
    return UserCreationResponse()
