from dotenv import load_dotenv
from os import getenv
load_dotenv()


def wrapper():
    from .api import app
    return app


# import module after loading environment
app = wrapper()
