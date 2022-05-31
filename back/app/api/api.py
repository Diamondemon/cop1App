
from fastapi import FastAPI
from fastapi.responses import JSONResponse


async def get_slash() -> JSONResponse:
    """Get responses linked to a given session_id."""

    return JSONResponse({'message': 'Ok'})


def build_app() -> FastAPI:
    app = FastAPI()
    app.get('/')(get_slash)

    return app
