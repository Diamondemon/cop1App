from peewee import CharField, ManyToManyField, DateField, IntegerField  # type: ignore

from app.database.utils import Table, DB


class Event(Table):
    id = IntegerField(primary_key=True)
    url = CharField(index=True)
    date = DateField()
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
    # status = CharField(default='normal')
    events = ManyToManyField(Event)


Relation = User.events.get_through_model()
DB.create_tables([User, Event, Relation])
