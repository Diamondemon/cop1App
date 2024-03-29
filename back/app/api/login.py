import re

from fastapi import Depends, APIRouter
from fastapi.security import APIKeyHeader

from app.login import user_login, create_user, user_from_token, update_user_password
from app.interfaces.main import *
from app.logger import logger
from app.database.tables import Event as EventInDB, Inscription as InscriptionInDB
from app.tools import check_email, check_username, check_phone
from weezevent import WEEZEVENT

app = APIRouter(tags=["login"])

token = APIKeyHeader(name="bearer", description="Connection token")


@app.post("/account/create")
async def create_new_user(user: UserCreationModel) -> UserCreationResponse:
    logger.info("Creating user : %s", user)
    if check_phone(user.phone):
        return create_user(user)
    return UserCreationResponse(
        valid=False,
        message="Invalid phone number"
    )


@app.post("/account/ask_validation")
async def ask_token_validation_sms(user: UserResetModel) -> UserValidationResponse:
    logger.info("Reset token for user : %s", user)
    return update_user_password(user)


@app.post("/account/login")
async def login(user: UserLoginModel) -> UserLoginResponse:
    logger.info(f"User {user} try to login")
    return UserLoginResponse(token=user_login(user.phone, user.code))


@app.get("/account/me")
async def read_users_me(_token: str = Depends(token)) -> UserModel:
    user = user_from_token(_token)
    logger.info('user %s is connected', user)
    evt = EventInDB \
        .select(EventInDB, InscriptionInDB) \
        .join(InscriptionInDB) \
        .where(InscriptionInDB.user == user) \
        .prefetch()
    return UserModel(
        phone=user.phone,
        email=user.email,
        first_name=user.first_name,
        last_name=user.last_name,
        min_event_delay_days=user.min_event_delay_days,
        events=[
            EventInscrit(
                id=str(e.id),
                date=str(e.date),
                duration=str(e.duration),
                desc=str(e.desc),
                title=str(e.title),
                img=str(e.img),
                loc=str(e.loc),
                barcode=str(e.inscription.barcode)
            )
            for e in evt
        ]
    )


@app.post("/account/me")
async def edit_users_me(edit: UserEditModel, _token: str = Depends(token)) -> BoolResponse:
    user = user_from_token(_token)
    logger.info('user %s is connected', user)
    logger.info(edit)
    if edit.email is not None:
        if check_email(edit.email):
            logger.info('email edited')
            user.email = edit.email
        else:
            logger.info('invalid email')
            return BoolResponse(valid=False, message='email')
    if edit.first_name is not None:
        if check_username(edit.first_name):
            logger.info('first_name edited')
            user.first_name = edit.first_name
        else:
            logger.info('invalid first_name')
            return BoolResponse(valid=False, message='first_name')
    if edit.last_name is not None:
        if check_username(edit.last_name):
            logger.info('last_name edited')
            user.last_name = edit.last_name
        else:
            logger.info('invalid last_name')
            return BoolResponse(valid=False, message='last_name')
    user.save()
    return BoolResponse()


@app.delete("/account/me")
async def delete_account(_token: str = Depends(token)) -> BoolResponse:
    user = user_from_token(_token)
    logger.info('user %s request account deletion', user)
    evt = InscriptionInDB \
        .select(InscriptionInDB) \
        .where(InscriptionInDB.user == user)
    for e in evt:
        e.delete_instance()
    user.delete_instance()
    return BoolResponse()


@app.get("/unscanned/{event_id}")
async def unscanned(event_id: str, _token: str = Depends(token)) -> ScanResponse:
    """Subscribe to an event."""
    user = user_from_token(_token)
    try:
        barcode = InscriptionInDB.get(
                (InscriptionInDB.user == user.phone) &
                (InscriptionInDB.event == event_id)
            ).barcode
        return ScanResponse(scanned=not WEEZEVENT.is_participent_unscanned(event_id, barcode))
    except Exception as e:
        logger.error(e)
        return ScanResponse(scanned=False)
