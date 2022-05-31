from fastapi import FastAPI

from app.api.login import app as login_app

app = FastAPI()

app.include_router(login_app)
