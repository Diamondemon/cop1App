from peewee import Database, SqliteDatabase, Model  # type: ignore
from os import getenv
from typing import Callable
from app.logger import logger


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
            logger.info('Using database %s', db_type)
            return orms_init[db_type]()
        else:
            raise EnvironmentError(f'Unknown database type: {db_type}')
    else:
        logger.info('Falling back to sqlite database')
        return SqliteDatabase('database.db')


DB: Database = get_db()


class Table(Model):
    class Meta:
        database = DB
