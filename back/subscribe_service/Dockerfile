FROM quentinn42/seleniumpython

COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY runner.py runner.py
COPY flask_app.py flask_app.py

CMD ["gunicorn", "-w", "1", "-b", "0.0.0.0:3000", "flask_app:flask"]
