
from hashlib import sha256
from os import getenv
from dotenv import load_dotenv
load_dotenv()


def _get_or_warn(key: str) -> str:
    val = getenv(key)
    if val is not None:
        return val
    print(f'WARNING : {key} not set')
    return 'dev'


def _hash(txt: str) -> str:
    return sha256(txt.encode('utf-8')).hexdigest()


class Env:
    ADMIN_USERNAME = _get_or_warn('ADMIN_USERNAME')
    ADMIN_PASSWORD = _get_or_warn('ADMIN_PASSWORD')
    ADMIN_SECRET = _get_or_warn('ADMIN_SECRET')
    FLASK_SECRET_KEY = bytes(_get_or_warn(
        'FLASK_SECRET_KEY'), encoding='utf-8')


class Admin:
    def __init__(self) -> None:
        self.username = ENV.ADMIN_USERNAME
        self.password = ENV.ADMIN_PASSWORD
        self.secret = ENV.ADMIN_SECRET

    @staticmethod
    def fingerprint(username: str, password: str) -> str:
        return _hash(_hash(username) + _hash(password))

    def gen_token(self) -> str:
        return self.secret

    def test_token(self, token: str) -> bool:
        return _hash(token) == _hash(self.gen_token())

    def login(self, username: str, password: str) -> str:
        if self.fingerprint(username, password) == self.fingerprint(self.username, self.password):
            return self.gen_token()
        return ''


ENV = Env()
ADMIN = Admin()
