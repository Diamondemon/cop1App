from asyncio.log import logger
from traceback import print_exception
import datetime

from app.database.utils import DB
from app.database.tables import User as UserInDB, Event as EventInDB, Inscription as InscriptionInDB


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
                email='',
                first_name='',
                last_name='',
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

def user_can_subscribe_to_event(user: UserInDB, event: EventInDB) -> bool:
    user_date = datetime.datetime.strptime(event.date, '%Y-%m-%dT%H:%M')
    delta = datetime.timedelta(days=user.min_event_delay_days)
    start = user_date - delta
    stop = user_date + delta
    events = EventInDB.select(EventInDB).join(InscriptionInDB) \
        .where(InscriptionInDB.user == user.phone)
    for _event in events:
        evt_date = datetime.datetime.strptime(_event.date, '%Y-%m-%dT%H:%M')
        print(evt_date)
        if start < evt_date < stop:
            return False
    return True
