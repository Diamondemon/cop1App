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
            Event.create(
                url=f'https://aaa.com/{phone}/x',
                date=datetime.datetime.now() + datetime.timedelta(days=1),
                title = 'title x',
                img = 'http://images4.fanpop.com/image/photos/17000000/Stock-Space-stock-17004535-1280-800.jpg',
                loc = 'loc'
            )
            Event.create(
                url=f'https://aaa.com/{phone}/y',
                date=datetime.datetime.now() + datetime.timedelta(days=10),
                title = 'title y',
                img = 'http://images4.fanpop.com/image/photos/17000000/Stock-Space-stock-17004535-1280-800.jpg',
                loc = 'loc'
            )
            UserInDB.get(UserInDB.phone == phone).events.add(
                [
                    Event.get(Event.url == f'https://aaa.com/{phone}/x'),
                    Event.get(Event.url == f'https://aaa.com/{phone}/y')
                ]
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
    if user is None:
        raise ValueError('User not found')
    with DB:
        user.hashed_password = hashed_password
