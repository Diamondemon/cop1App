from peewee import CharField  # type: ignore

from app.database.utils import Table, DB


class User(Table):
    username = CharField()
    full_name = CharField()
    email = CharField()
    hashed_password = CharField()
    salt = CharField()


with DB as db:
    db.create_tables([User])
