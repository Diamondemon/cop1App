from dotenv import load_dotenv
load_dotenv()


def app():
    """Create the app after loading environment"""
    from app.api import app
    return app
