from fastapi import Depends, APIRouter
import datetime

from app.interfaces.main import Events, Event, BoolResponse, SubscribeResponse
from app.database.tables import User as UserInDB, Event as EventInDB, Inscription as InscriptionInDB, DB
from app.database.main import user_can_subscribe_to_event
from app.api.login import token

from app.login import user_from_token
from app.logger import logger
from auto_subscribe import subscribe, unsubscribe

app = APIRouter(tags=["events"])


@app.get("/events")
async def list_all_events() -> Events:
    """List the events of a user."""
    return Events(
        events=[
            Event(
                id=str(e.id),
                date=str(e.date),
                duration=str(e.duration),
                desc=str(e.desc),
                title=str(e.title),
                img=str(e.img),
                loc=str(e.loc),
            )
            for e in EventInDB.select().order_by(EventInDB.date)
        ]
    )


@app.post("/events/subscribe/{item_id}")
async def subscribe_to_an_event(item_id: int, _token: str = Depends(token)) -> SubscribeResponse:
    """Subscribe to an event."""
    user = user_from_token(_token)
    try:
        evt = EventInDB.get(EventInDB.id == item_id)
    except:
        logger.info('Invalid event')
        return SubscribeResponse(success=False, barcode='')
    if not user_can_subscribe_to_event(user, evt):
        return SubscribeResponse(success=False, barcode='')
    try:
        barcode = subscribe(
            str(item_id),
            user.phone,
            user.first_name,
            user.last_name,
            user.email
        )
    except Exception as e:
        logger.error('Unable to subscribe to event %d', item_id)
        logger.error(e)
        barcode=''
    with DB:
        InscriptionInDB.create(
            user=user,
            event=evt,
            barcode=barcode
        )
    return SubscribeResponse(success=True, barcode=barcode)


@app.delete("/events/subscribe/{item_id}")
async def unsubscribe_to_an_event(item_id: int, _token: str = Depends(token)) -> BoolResponse:
    """Unsubscribe from an event."""
    user = user_from_token(_token)
    try:
        insc = InscriptionInDB.get(InscriptionInDB.user == user.phone and InscriptionInDB.event == item_id)
        logger.info(insc)
        if datetime.datetime.strptime(insc.event.date, '%Y-%m-%dT%H:%M') < datetime.datetime.now():
            return BoolResponse(valid=False, message="Unable to unsubscribe to previous event.")
        try:
            barcode = insc.barcode
            unsubscribe(str(item_id), barcode)
        except Exception as e:
            logger.error(e)
            insc.delete_instance()
        return BoolResponse()
    except Exception as e:
        return BoolResponse(valid=False, message=f"Unable to access event {item_id}")
