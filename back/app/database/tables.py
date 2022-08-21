from peewee import CharField, IntegerField, TextField, ForeignKeyField  # type: ignore

from app.database.utils import Table, DB


class Event(Table):
    id = CharField(primary_key=True, index=True)
    date = CharField()
    duration = CharField()
    desc = TextField()
    title = CharField()
    img = CharField()
    loc = CharField()


class User(Table):
    phone = CharField(primary_key=True, index=True, unique=True)
    hashed_password = CharField()
    salt = CharField()

    email = CharField()
    first_name = CharField()
    last_name = CharField()
    min_event_delay_days = IntegerField(default=14)
    skiped = IntegerField(default=0)


class Inscription(Table):
    user = ForeignKeyField(User, backref='inscription')
    event = ForeignKeyField(Event, backref='inscription')
    barcode = CharField(index=True)


DB.create_tables([User, Event, Inscription])