from os import getenv
from app.logger import logger
# from twilio.rest import Client

# account_sid = getenv('TWILIO_ACCOUNT_SID')
# auth_token = getenv('TWILIO_AUTH_TOKEN')
# client = Client(account_sid, auth_token)


def generate_and_send_token(phone: str) -> str:
    """Generate the token and sent it via twilo"""
    logger.info('Generating token for user : %s', phone)
    token = '123456'
    # client.messages.create(
    #     body=f'Your code is ; {token}',
    #     from_='+15017122661',
    #     to=phone
    # )
    return token
