from os import getenv
from typing import Callable
from app.logger import logger
import requests
import random


api_key = getenv('SMSMODE_API_KEY')


def fake_generator(phone: str) -> str:
    """return 123456"""
    logger.info('Generating token for user : %s', phone)
    token = '123456'
    return token


def gen_smsmode_generator(access_token: str) -> Callable[[str], str]:
    """Generate the token generator"""
    
    def smsmode_generator(phone: str) -> str:
        """Generate the token and sent it via twilo"""
        logger.info('Generating token for user : %s', phone)
        token = ''.join(random.choices('0123456789', k=6))
        res = requests.post(
            'https://api.smsmode.com/http/1.6/sendSMS.do',
            params={
                'accessToken': access_token,
                'message': f'Code : {token}',
                'numero': phone.replace('+', '')
            }
        )
        logger.info('SMSMODE: %d status code', res.status_code)
        return token

    return smsmode_generator


if api_key is not None:
    logger.info('Logging in to smsmode')
    try:
        res = requests.get('https://api.smsmode.com/http/2.0/createAuthorisation.do', params={'accessToken': api_key})
        if not res.ok:
            raise requests.exceptions.HTTPError(str(res.status_code))
        data = res.json()
        access_token = data['accessToken']
        generate_and_send_token = gen_smsmode_generator(access_token)
    except Exception as e:
        logger.error('Unable to connect to smsmode')
        raise e
    logger.info('Done')
else:
    logger.warning('Using fake code generator')
    generate_and_send_token = fake_generator
