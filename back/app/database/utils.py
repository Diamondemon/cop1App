from peewee import Database, SqliteDatabase, Model  # type: ignore
from os import getenv
from typing import Callable


def init_sqlite() -> Database:
    if (db_path := getenv('DATABASE_PATH')):
        return SqliteDatabase(db_path)
    raise EnvironmentError('DATABASE_PATH is not set')


orms_init: dict[str, Callable[[], Database]] = {
    "SqliteDatabase": init_sqlite
}


def get_db() -> Database:
    if (db_type := getenv('DATABASE_TYPE')):
        if db_type in orms_init:
            return orms_init[db_type]()
        else:
            raise EnvironmentError(f'Unknown database type: {db_type}')
    else:
        return SqliteDatabase('database.db')


DB: Database = get_db()


class Table(Model):
    class Meta:
        database = DB
