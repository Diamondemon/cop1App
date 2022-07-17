from fastapi import Depends, APIRouter, HTTPException

from app.interfaces.main import Events, Event, BoolResponse
from app.database.tables import Event as EventInDB, User as UserInDB
from app.api.login import token

from app.login import user_from_token
from app.logger import logger


app = APIRouter(tags=["events"])

@app.get("/events")
async def list_all_events() -> Events:
    """List the events of a user."""
    return Events(
        events=[
            Event(
                id=e.id,
                url=e.url,
                date=str(e.date),
                title=e.title,
                img=e.img,
                loc=e.loc
            )
            for e in EventInDB.select()
        ]
    )

@app.post("/events/subscribe/{item_id}")
async def subscribe_to_an_event(item_id: int, _token: str = Depends(token)) -> BoolResponse:
    """Subscribe to an event."""
    user = user_from_token(_token)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    try:
        UserInDB.get(UserInDB.phone == user).events.add([EventInDB.get(EventInDB.id == item_id)])
        return BoolResponse()
    except:
        return BoolResponse(valid=False, message=f"Unable to access event {item_id}")

@app.delete("/events/subscribe/{item_id}")
async def unsubscribe_to_an_event(item_id: int, _token: str = Depends(token)) -> BoolResponse:
    """Unsubscribe from an event."""
    user = user_from_token(_token)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    try:
        UserInDB.get(UserInDB.phone == user).events.remove([EventInDB.get(EventInDB.id == item_id)])
        return BoolResponse()
    except:
        return BoolResponse(valid=False, message=f"Unable to access event {item_id}")
