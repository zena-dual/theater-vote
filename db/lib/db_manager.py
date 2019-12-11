from typing import Optional, TypeVar
import mysql.connector
import os


IntOrList = TypeVar('IntOrList', int, list)


class Manager:
    connection: None
    cursor: None
    should_use_transaction: bool

    def __init__(self, transaction: bool = False) -> None:
        self.should_use_transaction = transaction

    def __enter__(self):
        self.connection = mysql.connector.connect(
            host='theater-vote.db',
            user=os.environ['MYSQL_USER'],
            password=os.environ['MYSQL_PASSWORD'],
            database=os.environ['MYSQL_DATABASE'],
        )
        self.connection.ping(reconnect=True)

        if self.should_use_transaction:
            self.connection.start_transaction()

        self.cursor = self.connection.cursor(dictionary=True)

        return self

    def __exit__(self, ex_type, ex_value, trace) -> None:
        if self.should_use_transaction:
            self.connection.commit()

        self.cursor.close()
        self.connection.close()

    def execute(self, sql: str, *args: Optional[tuple]) -> IntOrList:
        self.cursor.execute(sql, *args)

        if sql.strip().upper().startswith('SELECT'):
            return self.cursor.fetchall()

        return self.cursor.lastrowid


def use_manager(sql: str, args: Optional[tuple] = None) -> IntOrList:
    with Manager() as manager:
        if args:
            return manager.execute(sql, args)
        return manager.execute(sql)


def use_manager_with_transaction(sql: str, args: Optional[tuple] = None) -> IntOrList:
    with Manager(transaction=True) as manager:
        if args:
            return manager.execute(sql, args)
        return manager.execute(sql)
