import json
from os import getenv
import requests
import json
from urllib import parse
from typing import Tuple


def d(x):
    print(json.dumps(x, indent=2))

def quote(x: str) -> str:
    return parse.quote(x.encode('utf-8'))


class Auth:

    def __init__(self):
        self.base_url = 'https://api.weezevent.com'
        self.headers = {
            'content-type': 'application/x-www-form-urlencoded', 'charset': 'utf-8'}
        self.token = self.get_token()
        self.key = getenv('API_KEY')

    def get_token(self) -> str:
        user = getenv('API_USER')
        password = getenv('API_PASS')
        key = getenv('API_KEY')
        if None in [key, user, password]:
            raise EnvironmentError('Missing env vars')
        creds = f'username={quote(user or "")}&password={quote(password or "")}&api_key={quote(key or "")}'
        url = self.base_url + '/auth/access_token'
        full = f'{url}?{creds}'
        res = requests.post(
            full,
            headers=self.headers
        )
        return res.json()['accessToken']


class CoreApi:
    def _request(self, method, action, params={}, data={}):
        if method == "GET":
            return self._request_get(action, params)
        if method == "POST":
            return self._request_post(action, params, data)
        if method == "PATCH":
            return self._request_patch(action, params, data)
        if method == "DELETE":
            return self._request_delete(action, params, data)

    def _request_get(self, action, params={}):
        params = self._get_params(params)
        url = self.domain + action
        return requests.get(url, params=params)

    def _request_post(self, action, params={}, data={}):
        url = self.domain + action
        params = self._get_params(params)
        data = {"data": json.dumps(data)}
        return requests.post(url, headers=self.headers, params=params, data=data)

    def _request_patch(self, action, params={}, data={}):
        url = self.domain + action
        params = self._get_params(params)
        data = {"data": json.dumps(data)}
        return requests.patch(url, headers=self.headers, params=params, data=data)

    def _request_delete(self, action, params={}, data={}):
        url = self.domain + action
        params = self._get_params(params)
        data = {"data": json.dumps(data)}
        return requests.delete(url, headers=self.headers, params=params, data=data)

    def _get_params(self, params={}):
        requests_params = Params(params)
        requests_params.api_key = self.api_key
        if self.access_token is not None:
            requests_params.access_token = self.access_token

        return requests_params.__dict__


class Params:
    ARRAY_PARAMETER = '[]'

    def __init__(self, params={}):
        self.api_key = None
        self.access_token = None
        for attr_key, attr_value in params.items():
            if isinstance(attr_value, list):
                attr_key += self.ARRAY_PARAMETER
            setattr(self, attr_key, attr_value)


class Api(CoreApi):
    AUTH_ACCESS_TOKEN = '/auth/access_token'
    EVENTS = '/events'
    DATES = '/dates'
    TICKETS = '/tickets'
    TICKET_STATS = '/ticket/:id/stats'
    PARTICIPANT_LIST = '/participant/list'
    PARTICIPANT_ANSWERS = '/participant/:id/answers'
    SCAN_SETTINGS = '/scan/settings'
    SCAN_USER = '/scan/user'
    EVENT_DETAILS = '/event/:id/details/'
    EVENT_SEARCH = '/event/search/'
    EVENT_CATEGORIES = '/event/categories/'
    PARTICIPANTS = "/participants"

    def __init__(self):
        try:
            auth = Auth()
        except Exception as e:
            raise EnvironmentError('Invalid auth') from e
        self.headers = auth.headers
        self.api_key = auth.key
        self.access_token = auth.token
        self.domain = 'https://api.weezevent.com'

    def post_auth_access_token(self, username, password):
        params = {"username": username, "password": password}
        return self._request_post(self.AUTH_ACCESS_TOKEN, params)

    def get_events(self, params={}):
        return self._request_get(self.EVENTS, params)

    def get_dates(self, params={}):
        return self._request_get(self.DATES, params)

    def get_tickets(self, params={}):
        return self._request_get(self.TICKETS, params)

    def get_ticket_stats(self, ticket_id, params={}):
        url = self.TICKET_STATS.replace(':id', str(ticket_id))
        return self._request_get(url, params)

    def get_participant_list(self, params={}):
        return self._request_get(self.PARTICIPANT_LIST, params)

    def get_participant_answers(self, participant_id):
        url = self.PARTICIPANT_ANSWERS.replace(':id', str(participant_id))
        return self._request_get(url)

    def participants(self, method, **kwargs):
        return self._request(method, self.PARTICIPANTS, **kwargs)

    def get_scan_settings(self):
        return self._request_get(self.SCAN_SETTINGS)

    def post_scan_user(self, name_user):
        params = {'user': name_user}
        return self._request_post(self.SCAN_USER, params)

    def get_event_details(self, event_id):
        url = self.EVENT_DETAILS.replace(':id', str(event_id))
        return self._request_get(url)

    def get_event_search(self, params={}):
        return self._request_get(self.EVENT_SEARCH, params)

    def get_event_categories(self):
        return self._request_get(self.EVENT_CATEGORIES)


class Weezevent:
    PARTICIPANTS = '/v3/participants'
    FORMS = '/v3/form'
    
    def __init__(self) -> None:
        self.api = Api()

    def list_events(self) -> list:
        ids = [
            x['id']
            for x in
            self.api.get_events().json()['events']
        ]
        return [
            self.event(_id)
            for _id in ids
        ]

    def list_unscanned_users(self, evt: int) -> list:
        return list(set(
            self.participant_phone(user['id_participant'])
            for user in
            filter(
                self._has_not_check,
                self.api.get_participant_list(
                    {'id_event[]': evt}
                ).json()['participants']
            )
        ))

    def event(self, evt_id: int) -> dict:
        return self._clean_obj(self.api.get_event_details(evt_id).json())

    def participant_phone(self, participant_id: int) -> str | None:
        res = self.api.get_participant_answers(participant_id).json()
        return dict(enumerate(res.get('answers', []))).get(0, {}).get('value')

    def participant_barcode(self, evt_id: int, phone: str) -> str | None:
        res = self.api.get_participant_list({'id_event[]': evt_id}).json()[
            'participants']
        for x in res:
            if x.get('id_participant') is None:
                continue
            if phone == self.participant_phone(x.get('id_participant')):
                return x.get('barcode')
        return None

    @staticmethod
    def _clean_obj(obj: dict) -> dict:
        evt = obj['events']
        loc = evt['venue']
        return {
            'id': evt.get('id'),
            'date': evt.get('period', {}).get('start'),
            'duration': '01:00:00',
            'title': evt.get('title'),
            'desc': evt.get('desc') or evt.get('description'),
            'img': evt.get('image'),
            'loc': f"{loc.get('address')}, {loc.get('zip_code')} {loc.get('city')}"
        }

    @staticmethod
    def _has_not_check(obj: dict) -> bool:
        return obj.get('deleted') == '0' and obj.get('control_status', {}).get('status') == '0'

    def billet_id(self, evt_id: int) -> int:
        full = self.api.get_tickets({'id_event': evt_id}).json()
        return full['events'][0]['tickets'][0]['id']


    def form_question(self, evt_id: int) -> str:
        full = self.api._request_get(self.FORMS ,{'id_event': evt_id}).json()
        for x in full:
            if x['id_evenement'] == str(evt_id):
                q = x['questions_participant'][0]
                if q['type'] == 'custom':
                    return q['id']
                return q['type']
        return 'telephone'

    def add_participant(
            self,
            evt_id: int,
            email: str,
            first_name: str,
            last_name: str,
            phone: str,
        ) -> str:
        billet_id = self.billet_id(evt_id)
        form_question = self.form_question(evt_id)
        data = {
            "participants": [
                {
                    "id_evenement": evt_id,
                    "id_billet": billet_id,
                    "email": email,
                    "nom": last_name,
                    "prenom": first_name,
                    "form": {
                        form_question: phone
                    },
                    "notify": False
                }
            ]
        }
        res = self.api._request_post(self.PARTICIPANTS, data=data)
        barcode = res.json()['participants'][0]['barcode_id']
        return barcode
    
    
    def delete_participant(
            self,
            evt_id: int,
            barcode: str,
        ) -> None:
        data = {
            "participants": [
                {
                    "id_evenement": evt_id,
                    "barcode_id": barcode
                }
            ]
        }
        self.api._request_delete(self.PARTICIPANTS, data=data)


    def is_participent_unscanned(self, evt_id: str, barcode: str) -> bool:
        try:
            res = self.api.get_participant_list({'id_event[]': evt_id}).json()['participants']
        except:
            return False
        for user in res:
            if user.get('barcode') == barcode:
                if self._has_not_check(user):
                    return True
                else:
                    return False
        else:
            return False


WEEZEVENT = Weezevent()
