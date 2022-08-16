import requests
from os import getenv
import json


SUBSCRIPTION_URL = getenv('SUBSCRIPTION_URL', '')
if not SUBSCRIPTION_URL:
    raise EnvironmentError('SUBSCRIPTION_URL not set')


class SubscriptionException(Exception):
    pass


def subscribe(
    evt_id: str,
    phone: str,
    first_name: str,
    last_name: str,
    email: str
) -> str:
    res = requests.post(
        SUBSCRIPTION_URL,
        data=json.dumps({
            'evt_id': evt_id,
            'phone': phone,
            'first_name': first_name,
            'last_name': last_name,
            'email': email
        })
    )
    data = res.json()
    if data['error'] is not None:
        raise SubscriptionException(data['error'])
    if not data['barcode']:
        raise SubscriptionException('Unknow error')
    return data['barcode']
