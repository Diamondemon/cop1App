from fastapi import FastAPI

from app.api.login import app as login_app
from app.api.events import app as event_app

app = FastAPI()

app.include_router(login_app)
app.include_router(event_app)
