"""Use cryptography to add security to the application."""

from dataclasses import dataclass
import hashlib
import random
import string
from datetime import datetime, timedelta
import base64
from json import loads, dumps
from os import getenv

from app.interfaces import Token
from app.database import UserInDB
from app.logger import logger


class CryptoException(Exception):
    pass


class InvalidToken(CryptoException):
    pass


if (priv := getenv("PRIVATE_KEY")):
    PRIVATE_KEY = priv
else:
    logger.warning("No private key found. Using default.")
    PRIVATE_KEY = "default"


def sign(data: str) -> str:
    return sha256(data + PRIVATE_KEY)


def check_signature(data: str, signature: str) -> bool:
    return sign(data) == signature


def b64encode(data: str) -> str:
    return base64.b64encode(bytes(data, 'utf-8')).decode('utf-8')


def b64decode(data: str) -> str:
    return base64.b64decode(bytes(data, 'utf-8')).decode('utf-8')


def sha256(string: str) -> str:
    return hashlib.sha256(string.encode('utf-8')).hexdigest()


def randomword(length):
    return ''.join(random.choice(string.ascii_lowercase) for _ in range(length))


def check_password(user: UserInDB, password: str) -> bool:
    return hash_password(user.salt, password) == user.hashed_password


def hash_password(salt: str, password: str) -> str:
    string = salt + password
    return sha256(string)


@dataclass
class JsonToken:
    exp: int
    preferred_username: str
    typ: str = "Bearer"

    @property
    def json(self) -> str:
        return dumps({
            "exp": self.exp,
            "preferred_username": self.preferred_username,
            "typ": self.typ
        })

    @classmethod
    def from_str(cls, data: str) -> 'JsonToken':
        json = loads(data)
        if (keys := set(json.keys())) != {"exp", "preferred_username", "typ"}:
            logger.warning(
                "Invalid token content it can be a hacker. Token keys provided %s.",
                keys
            )
            raise InvalidToken("Invalid token")
        return cls(
            exp=json.get("exp"),
            preferred_username=json.get("preferred_username"),
            typ=json.get("typ")
        )


def create_token(username: str) -> Token:
    """Create a token with 24h expiration."""
    expiration = datetime.now() + timedelta(hours=24)
    token = JsonToken(
        exp=int(expiration.timestamp()),
        preferred_username=username
    )
    token_b64 = b64encode(token.json)
    signature = sign(token_b64)

    return Token(token_b64 + "." + signature)


def decode_token(token: Token) -> str:
    """Decode a token."""
    token_b64, signature = token.split(".")
    if not check_signature(token_b64, signature):
        logger.warning("Invalid signature it can be a hacker.")
        raise InvalidToken("Invalid signature.")
    parsed_token = JsonToken.from_str(b64decode(token_b64))
    if parsed_token.exp < int(datetime.now().timestamp()):
        raise InvalidToken("Token expired.")
    return parsed_token.preferred_username
