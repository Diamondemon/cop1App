from peewee import SQL, CharField, ManyToManyField, DateField, IntegerField  # type: ignore

from app.database.utils import Table, DB


class Event(Table):
    id = IntegerField(
        primary_key=True,
        index=True,
        unique=True,
        # auto_increment=True
    )
    date = DateField()
    url = CharField()


class User(Table):
    email = CharField(primary_key=True, index=True, unique=True)
    phone = CharField()
    full_name = CharField()
    hashed_password = CharField()
    salt = CharField()
    status = CharField(default='normal')
    users = ManyToManyField(Event, backref='id')


with DB as db:
    db.create_tables([User, Event])
