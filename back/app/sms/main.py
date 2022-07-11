from app.logger import logger


def generate_and_send_token(phone: str) -> str:
    logger.info('Generating token for user : %s', phone)
    token = '123456'
    logger.info('Token is : %s', token)
    return token
