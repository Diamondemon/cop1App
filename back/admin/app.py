from datetime import datetime
from functools import wraps
from logging import INFO
from traceback import print_exception

from flask import Flask, jsonify
from flask import session
from flask import request
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask import render_template, redirect, abort
from math import ceil as top


from admin.utils import ENV, ADMIN
from app.database.tables import Inscription, User, Event, DB
from weezevent import WEEZEVENT

app = Flask(__name__)
app.logger.setLevel(INFO)

item_per_page = 10
limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["60 per minute"]
)

app.secret_key = ENV.FLASK_SECRET_KEY
apps = {
    'Events': '/events',
    'Users': '/users'
}

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
    return render_template(
        'index.html',
        apps=[
            {
                'name': k,
                'path': v
            }
            for k, v in apps.items()
        ]
    )

@app.route(apps['Events'])
@limiter.exempt
@protect
def events():
    max_page = top(Event.select().count() / item_per_page)
    page = min(max(1, get_int('page', 1)), max_page)
    events = [
        {
            'id': x.id,
            'title': x.title,
            'img': x.img,
            'date': x.date.replace("T", " à ")
        }
        for x in Event.select().order_by(Event.date).paginate(page, item_per_page)
    ]
    return render_template(
        'events/index.html',
        page=page,
        max_page=max_page,
        events=events,
    )


@app.route(apps['Users'])
@limiter.exempt
@protect
def users():
    max_page = top(User.select().count() / item_per_page)
    page = min(max(1, get_int('page', 1)), max_page)
    mapping = {
        'phone': User.phone,
        'email': User.email,
        'delay': User.min_event_delay_days,
        'skiped': User.skiped
    }
    _order = request.args.get('order', 'phone')
    order = mapping.get(_order, User.phone)
    req = User.select().order_by(order).paginate(page, item_per_page).prefetch()
    users = [
        {
            'phone': x.phone,
            'email': x.email,
            'delay': x.min_event_delay_days,
            'skiped': x.skiped
        }
        for x in req
    ]
    return render_template(
        'users/index.html',
        page=page,
        max_page=max_page,
        users=users,
        order=_order
    )


@app.route('/user/view/<phone>')
@protect
@limiter.exempt
def view_user(phone):
    try:
        user = User.get(User.phone == phone)
    except:
        abort(404)
    return render_template(
        'users/view.html',
        phone=user.phone,
        email=user.email,
        first_name=user.first_name,
        last_name=user.last_name,
        delay=user.min_event_delay_days,
        skiped=user.skiped,
    )


@app.route('/user/edit/<phone>', methods=['GET', 'POST'])
@protect
@limiter.exempt
def edit_user(phone):
    try:
        user = User.get(User.phone == phone)
    except:
        abort(404)
    if request.method == 'POST':
        try:
            user.email=request.form['email']
            user.first_name=request.form['first_name']
            user.last_name=request.form['last_name']
            user.min_event_delay_days=int(request.form['delay'])
            user.skiped=int(request.form['skiped'])
            user.save()
        except Exception as e:
            print_exception(e)
        return redirect(f'/user/view/{phone}')
    return render_template(
        'users/edit.html',
        phone=user.phone,
        email=user.email,
        first_name=user.first_name,
        last_name=user.last_name,
        delay=user.min_event_delay_days,
        skiped=user.skiped,
    )


@app.route('/event/view/<evt_id>')
@protect
@limiter.exempt
def view_event(evt_id):
    try:
        evt_id = int(evt_id)
    except:
        evt_id = -1
    evt = None
    try:
        evt = Event.get(Event.id == evt_id)
    except:
        abort(404)
    return render_template(
        'events/view.html',
        title=evt.title,
        desc=evt.desc,
        id=evt.id,
        date=evt.date.replace("T", " à "),
        duration=evt.duration,
        img=evt.img,
        loc=evt.loc,
    )


@app.route('/event/delete/<evt_id>', methods=['POST'])
@protect
@limiter.exempt
def delete_event(evt_id):
    try:
        evt_id = int(evt_id)
    except:
        evt_id = -1
    evt = None
    try:
        evt = Event.get(Event.id == evt_id)
    except:
        abort(404)
    Inscription.delete().where(Inscription.event == evt_id).execute()
    evt.delete_instance()
    app.logger.info(f'Event {evt_id} deleted.')
    return redirect(apps['Events'])


@app.route('/event/edit/<evt_id>', methods=['GET', 'POST'])
@protect
@limiter.exempt
def edit_event(evt_id):
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
        try:
            evt.date=request.form['date']
            evt.duration=request.form['duration']
            evt.desc=request.form['desc']
            evt.title=request.form['title']
            evt.img=request.form['img']
            evt.loc=request.form['loc']
            evt.save()
        except Exception as e:
            print_exception(e)
        return redirect(f'/event/view/{evt_id}')
    return render_template(
        'events/edit.html',
        title=evt.title,
        desc=evt.desc,
        id=evt.id,
        date=evt.date,
        duration=evt.duration,
        img=evt.img,
        loc=evt.loc,
    )


@app.route('/event/unscan/<evt_id>', methods=['GET', 'POST'])
@protect
@limiter.exempt
def unscan_event(evt_id):
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
        try:
            users_phones = request.form.getlist('selected')
            app.logger.info(users_phones)
            users = User.select().where(User.phone.in_(users_phones))
            for user in users:
                user.get()
                user.skiped += 1
                user.save()
        except Exception as e:
            print_exception(e)
        return redirect(f'/event/view/{evt_id}')
    users = [
        {
            'phone': x,
        }
        for x in WEEZEVENT.list_unscanned_users(evt_id)
    ]
    return render_template(
        'events/unscan.html',
        id=evt.id,
        users=users
    )


@app.route('/event/create', methods=['GET', 'POST'])
@protect
@limiter.exempt
def new_event():
    if request.method == 'POST':
        try:
            evt_id = int(request.form['id'])
        except:
            return render_template(
                'events/create.html',
                date=datetime.now().date(),
                error="ID is required"
            )
        Event.create(
            id=evt_id,
            date=request.form['date'],
            duration=request.form['duration'],
            desc=request.form['desc'],
            title=request.form['title'],
            img=request.form['img'],
            loc=request.form['loc'],
        )
        return redirect(apps['Events'])
    return render_template(
        'events/create.html',
        date=datetime.now().date(),
    )


@app.route('/event_info/<evt_id>', methods=['GET'])
@protect
@limiter.exempt
def info(evt_id):
    try:
        return jsonify({'error': None, 'data': WEEZEVENT.event(evt_id)})
    except Exception as e:
        print_exception(e)
        return jsonify({'error': str(e), 'data': None})


@app.route('/login', methods=['GET', 'POST'])
@limiter.limit("5 per minute")
def login():
    if request.method == 'POST':
        token = ADMIN.login(
            request.form['username'], request.form['password'])
        if token:
            session['token'] = ADMIN.gen_token()
            return redirect('/')
    return render_template('login/index.html')


@app.route('/logout')
@protect
def logout():
    session.pop('token', None)
    return redirect('/login')
