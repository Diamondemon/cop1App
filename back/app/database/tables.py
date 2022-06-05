from peewee import SQL, CharField, ManyToManyField, DateField, IntegerField  # type: ignore

from app.database.utils import Table, DB


class User(Table):
    email = CharField(primary_key=True, index=True, unique=True)
    phone = CharField()
    full_name = CharField()
    hashed_password = CharField()
    salt = CharField()
    status = CharField(constraints=[SQL("DEFAULT ('normal')")])


class Event(Table):
    id = IntegerField(
        primary_key=True,
        index=True,
        unique=True,
        # auto_increment=True
    )
    date = DateField()
    url = CharField()
    # users = ManyToManyField(User, backref='email')


with DB as db:
    db.create_tables([User])
