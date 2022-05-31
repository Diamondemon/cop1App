"""A simple module to catch requests."""

from fastapi import FastAPI
from fastapi.responses import JSONResponse

app = FastAPI()


@app.get('/')
async def get_slash() -> JSONResponse:
    """Get responses linked to a given session_id."""

    return JSONResponse({'message': 'Ok'})
