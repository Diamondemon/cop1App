
from dataclasses import dataclass


@dataclass
class UserInDB:
    username: str
    full_name: str
    email: str
    hashed_password: str


class DB:

    def __init__(self) -> None:
        self.data = {
            "johndoe": {
                "username": "johndoe",
                "full_name": "John Doe",
                "email": "johndoe@example.com",
                "hashed_password": "fakehashedsecret",
            },
            "alice": {
                "username": "alice",
                "full_name": "Alice Wonderson",
                "email": "alice@example.com",
                "hashed_password": "fakehashedsecret2",
            },
        }

    def get_user(self, username: str) -> UserInDB | None:
        user = self.data.get(username)
        if user is not None:
            return UserInDB(**user)
        return None
