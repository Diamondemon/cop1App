from fastapi import FastAPI, Request

from app.api.login import app as login_app
from app.api.events import app as event_app
from app.logger import logger

app = FastAPI()


@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    response = await call_next(request)
    if response.headers.get('content-type'):
        response.headers['content-type'] = response.headers['content-type'] + \
            '; charset=utf-8'
    return response

app.include_router(login_app)
app.include_router(event_app)
