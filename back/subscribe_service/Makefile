.PHONY: all run insall clean clean_dev admin enable restart deps
PYTHON=python3.10
INSTALL_DST=/etc/systemd/system

all: .venv deps

.venv:
	${PYTHON} -m venv .venv >/dev/null

deps:
	bash -c 'source ${PWD}/.venv/bin/activate && ${PYTHON} -m pip install --upgrade pip && ${PYTHON} -m pip install -r requirements.txt' >/dev/null
	wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip
	unzip /tmp/chromedriver.zip chromedriver
	chmod 700 chromedriver

run: .venv
	bash -c 'source ${PWD}/.venv/bin/activate && PATH="`pwd`:$$PATH" gunicorn -w 1 -b 0.0.0.0:7000 flask_app:flask'
