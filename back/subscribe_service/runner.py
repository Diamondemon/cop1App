
from flask import Flask, jsonify, request
from selenium.webdriver.chrome.webdriver import WebDriver
from selenium.webdriver.common.by import By
from time import sleep
from selenium.webdriver.support.ui import Select
from functools import wraps
from uuid import uuid4
import textract

import os


def log(func):
    @wraps(func)
    def inner_func(*args, **kwargs):
        """Inner function within the invocation_log"""
        # print(f'Start |\t{func.__name__}')
        res = func(*args, **kwargs)
        # print(f'Done  |\t{func.__name__}')
        return res

    return inner_func


class Browser:

    def __init__(self, driver: WebDriver, evt_id: int, phone: str, first_name: str, last_name: str, email: str) -> None:
        self.driver = driver
        self.evt_id = evt_id
        self.phone = phone
        self.first_name = first_name
        self.last_name = last_name
        self.email = email

    @log
    def go_to_page_1(self) -> None:
        url = f'https://www.weezevent.com/widget_billeterie.php?id_evenement={self.evt_id}'
        self.driver.get(url)
        sleep(3)

    @log
    def fill_page_1(self) -> None:
        self.select_one_ticket()

    @log
    def select_one_ticket(self) -> None:
        table = self.driver.find_element(By.CLASS_NAME, 'ticket_table')
        sel = table.find_element(By.TAG_NAME, 'select')
        Select(sel).select_by_visible_text('1')

    @log
    def go_to_page_2(self) -> None:
        but = self.driver.find_element(By.ID, 'submitTicketForm')
        but.click()
        sleep(1)

    @log
    def fill_page_2(self) -> None:
        self.fill_phone()
        self.fill_buyer()

    @log
    def fill_phone(self) -> None:
        block = self.driver.find_elements(
            By.CLASS_NAME, 'billetterie_etape2_tb')[0]
        cell = block.find_element(By.CLASS_NAME, 'fieldWrapper')
        inp = cell.find_element(By.CLASS_NAME, 'visibleInputWidget')
        inp.send_keys(self.phone)

    @staticmethod
    def fill_field(field, value) -> None:
        field.find_element(
            By.TAG_NAME, 'input').send_keys(value)

    @log
    def fill_buyer(self) -> None:
        """assertion : elements are in this order :
        Prénom
        Nom
        E-mail
        Confirmation e-mail
        """
        validate = self.driver.find_element(By.CLASS_NAME, 'buyer-description')
        validate.click()

        block = self.driver.find_elements(
            By.CLASS_NAME, 'billetterie_etape2_tb')[1]
        sleep(1)
        fields = block.find_elements(By.CLASS_NAME, 'fieldWrapper')
        self.fill_field(fields[0], self.first_name)
        self.fill_field(fields[1], self.last_name)
        self.fill_field(fields[2], self.email)
        self.fill_field(fields[3], self.email)
        block.find_element(By.ID, 'accepte_cgv').click()

    @log
    def go_to_page_3(self) -> None:
        but = self.driver.find_element(
            By.CLASS_NAME, 'widget_billetterie_bt_suite')
        but.click()
        sleep(3)

    @log
    def retrive_ticket_url(self) -> str:
        a = self.driver.find_element(
            By.CLASS_NAME, 'downloadTicketButton')
        full = a.get_attribute('outerHTML')
        return full.split('href="')[1].split('"')[0]

    @log
    def get_barcode(self) -> str:
        url = self.retrive_ticket_url()
        fname = f'/tmp/{uuid4()}.pdf'
        os.system(f"curl '{url}' -sL -o {fname}")
        text = textract.process(fname, method='pdfminer')
        ext = ''.join(
            text
            .decode()
            .split('N°')[1]
            .split('\n')[1:4]
        ).replace(' ', '')
        return ext

    @log
    def run(self) -> str:
        self.go_to_page_1()
        self.fill_page_1()
        self.go_to_page_2()
        self.fill_page_2()
        self.go_to_page_3()
        return self.get_barcode()


def main(driver: WebDriver):
    keys = [
        'evt_id',
        'phone',
        'first_name',
        'last_name',
        'email'
    ]

    app = Flask(__name__)

    @app.route('/', methods=['GET'])
    def _help():
        return jsonify({'method': 'POST', 'args': keys})

    @app.route('/', methods=['POST'])
    def _index():
        data = request.get_json(force=True)
        kwargs = {
            x: data.get(x)
            for x in keys
        }
        for x in keys:
            if kwargs[x] is None:
                return jsonify({'error': f'Missing {x}', 'barcode': None})
        print(f'User {kwargs["phone"]} subscribe to {kwargs["evt_id"]}')
        code = Browser(
            driver,
            **kwargs
        ).run()
        print(f'User {kwargs["phone"]} succeed')
        return jsonify({'error': None, 'barcode': code})

    return app
