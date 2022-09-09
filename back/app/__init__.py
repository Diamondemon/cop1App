from os import getenv

from dotenv import load_dotenv
import sentry_sdk


load_dotenv()


if (dsn := getenv('SENTRY_DSN')):
    sentry_sdk.init(dsn=dsn, traces_sample_rate=1.0)


def app():
    """Create the app after loading environment"""
    from app.api import app
    return app
