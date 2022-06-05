from app.database.utils import DB
from app.database.tables import User as UserInDB


def get_user(username: str) -> UserInDB | None:
    with DB:
        try:
            user = UserInDB.select().where(
                UserInDB.username == username
            ).get()
        except:
            return None
        return user


def create_db_user(
    email: str,
    phone: str,
    full_name: str,
    hashed_password: str,
    salt: str
) -> bool:
    with DB:
        UserInDB.create(
            email=email,
            phone=phone,
            full_name=full_name,
            hashed_password=hashed_password,
            salt=salt,
        )
    return True
