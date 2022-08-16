from fastapi import Depends, APIRouter

from app.interfaces.main import Events, Event, BoolResponse, SubscribeResponse
from app.database.tables import User as UserInDB, Event as EventInDB, Inscription as InscriptionInDB, DB
from app.api.login import token

from app.login import user_from_token
from app.logger import logger
from auto_subscribe import subscribe

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
    try:
        barcode = subscribe(
            str(item_id),
            user.phone,
            user.first_name,
            user.last_name,
            user.email
        )
    except:
        logger.error('Unable to subscribe to event %d', item_id)
        barcode=''
    with DB:
        InscriptionInDB.create(
            user=user,
            event=evt,
            barcode=barcode,
            id='TODO'
        )
    return SubscribeResponse(success=True, barcode=barcode)


@app.delete("/events/subscribe/{item_id}")
async def unsubscribe_to_an_event(item_id: int, _token: str = Depends(token)) -> BoolResponse:
    """Unsubscribe from an event."""
    user = user_from_token(_token)
    try:
        user.events.remove([EventInDB.get(EventInDB.id == item_id)])
        return BoolResponse()
    except:
        return BoolResponse(valid=False, message=f"Unable to access event {item_id}")
