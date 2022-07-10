from traceback import print_exception

from app.database.utils import DB
from app.database.tables import User as UserInDB


def get_user(phone: str) -> UserInDB | None:
    with DB:
        try:
            user = UserInDB.select().where(
                UserInDB.phone == phone
            ).get()
        except:
            return None
        return user


def create_db_user(
    phone: str,
    hashed_password: str,
    salt: str
) -> bool:
    try:
        with DB:
            UserInDB.create(
                phone=phone,
                hashed_password=hashed_password,
                salt=salt,
            )
    except Exception as e:
        print_exception(e)
        return False
    return True


def update_db_user_password(
    phone: str,
    hashed_password: str
) -> None:
    user = get_user(phone)
    with DB:
        user.hashed_password = hashed_password
