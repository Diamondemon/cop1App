from fastapi import APIRouter

from app.interfaces.main import Events, Event
from app.database.tables import Event as EventInDB


app = APIRouter(tags=["events"])

@app.get("/events")
async def list_all_events() -> Events:
    """List the events of a user."""
    return Events(
        events=[
            Event(
                url=e.url,
                date=str(e.date)
            )
            for e in EventInDB.select()
        ]
    )
