from fastapi import Depends, APIRouter

from app.interfaces.main import Events, Event, BoolResponse
from app.database.tables import Event as EventInDB
from app.api.login import token

from app.login import user_from_token
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
async def subscribe_to_an_event(item_id: int, _token: str = Depends(token)) -> BoolResponse:
    """Subscribe to an event."""
    user = user_from_token(_token)
    try:
        evt = EventInDB.get(EventInDB.id == item_id)
    except:
        return BoolResponse(valid=False, message=f"Unable to access event {item_id}")
    try:
        barcode = subscribe(
            str(item_id),
            user.phone,
            user.first_name,
            user.last_name,
            user.email
        )
    except:
        return BoolResponse(valid=False, message=f"Unable to subscribe to event {item_id}")
    try:
        user.events.add([evt])
    except:
        return BoolResponse(valid=False, message=f"Unable link event {item_id} to you")
    return BoolResponse(message=barcode)


@app.delete("/events/subscribe/{item_id}")
async def unsubscribe_to_an_event(item_id: int, _token: str = Depends(token)) -> BoolResponse:
    """Unsubscribe from an event."""
    user = user_from_token(_token)
    try:
        user.events.remove([EventInDB.get(EventInDB.id == item_id)])
        return BoolResponse()
    except:
        return BoolResponse(valid=False, message=f"Unable to access event {item_id}")
