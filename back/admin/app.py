from datetime import datetime
from functools import wraps

from flask import Flask
from flask import session
from flask import request
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask import render_template, redirect, abort
from math import ceil as top


from admin.utils import ENV, ADMIN
from app.database.tables import Event, DB

app = Flask(__name__)
item_per_page = 10

limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["60 per minute"]
)

app.secret_key = ENV.FLASK_SECRET_KEY


def get_int(name: str, default: int) -> int:
    try:
        return int(request.args.get(name, default))
    except:
        return default


def protect(f):
    @wraps(f)
    def wrapped(*args, **kwargs):
        if 'token' not in session:
            return redirect('/login')
        if not ADMIN.test_token(session["token"]):
            return redirect('/login')
        return f(*args, **kwargs)
    return wrapped


@app.before_request
def before_request():
    try:
        DB.connect()
    except Exception as e:
        app.logger.error(e)


@app.after_request
def after_request(response):
    DB.close()
    return response


@app.route('/')
@limiter.exempt
@protect
def index():
    max_page = top(Event.select().count() / item_per_page)
    page = min(max(1, get_int('page', 1)), max_page)
    events = [
        {
            'title': x.title,
            'date': x.date,
            'url': x.url,
            'id': x.id,
            'img': x.img
        }
        for x in Event.select().order_by(Event.date).paginate(page, item_per_page)
    ]
    return render_template(
        'index.html',
        page=page,
        max_page=max_page,
        events=events,
    )


@app.route('/event/<evt_id>', methods=['GET', 'POST'])
@protect
@limiter.exempt
def event(evt_id):
    try:
        evt_id = int(evt_id)
    except:
        evt_id = -1
    evt = None
    try:
        evt = Event.get(Event.id == evt_id)
    except:
        abort(404)
    if request.method == 'POST':
        Event.delete().where(Event.id == evt_id).execute()
        print(f'Event {evt_id} deleted.')
        return redirect('/')
    return render_template(
        'event.html',
        url=evt.url,
        date=evt.date,
        title=evt.title,
        img=evt.img,
        loc=evt.loc,
        id=evt.id
    )


@app.route('/new', methods=['GET', 'POST'])
@protect
@limiter.exempt
def new_event():
    if request.method == 'POST':
        Event.create(
            url=request.form['url'],
            date=request.form['date'],
            title=request.form['title'],
            img=request.form['img'],
            loc=request.form['loc']
        )
        return redirect('/')
    return render_template(
        'new.html',
        date= datetime.now().date(),
        )


@app.route('/login', methods=['GET', 'POST'])
@limiter.limit("5 per minute")
def login():
    if request.method == 'POST':
        token = ADMIN.login(
            request.form['username'], request.form['password'])
        if token:
            session['token'] = ADMIN.gen_token()
            return redirect('/')
    return render_template('login.html')


@app.route('/logout')
@protect
def logout():
    session.pop('token', None)
    return redirect('/login')
