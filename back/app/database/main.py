from traceback import print_exception
import datetime

from app.database.utils import DB
from app.database.tables import User as UserInDB, Event


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
            Event.create(date=datetime.datetime.now() + datetime.timedelta(days=1), url=f'https://aaa.com/{phone}/x')
            Event.create(date=datetime.datetime.now() + datetime.timedelta(days=10), url=f'https://aaa.com/{phone}/y')
            UserInDB.get(UserInDB.phone == phone).events.add([Event.get(Event.url == f'https://aaa.com/{phone}/x'), Event.get(Event.url == f'https://aaa.com/{phone}/y')])
    except Exception as e:
        print_exception(e)
        return False
    return True


def update_db_user_password(
    phone: str,
    hashed_password: str
) -> None:
    user = get_user(phone)
    if user is None:
        raise ValueError('User not found')
    with DB:
        user.hashed_password = hashed_password
