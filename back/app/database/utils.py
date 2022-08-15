from playhouse.db_url import connect
from peewee import Database, Model  # type: ignore
from os import getenv


DB: Database = connect(getenv('DATABASE', 'sqlite:///database.db'))


class Table(Model):
    class Meta:
        database = DB
