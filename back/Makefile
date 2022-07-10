.PHONY: all setup run insall clean clean_dev
PYTHON=python3.10
INSTALL_DST=/etc/systemd/system/cop1.service

all: setup

setup:
	${PYTHON} -m venv .venv
	bash -c 'source .env && source ${PWD}/.venv/bin/activate && ${PYTHON} -m pip install --upgrade pip && ${PYTHON} -m pip install -r requirements.txt'

run:
	bash -c 'source .env && source ${PWD}/.venv/bin/activate && uvicorn app:app --host 0.0.0.0 --port $${PORT:-8000}'

dev:
	bash -c 'source .env && source ${PWD}/.venv/bin/activate && uvicorn app:app --reload --host 0.0.0.0 --port $${PORT:-8000}'

install:
	envsubst < cop1.service > /tmp/cop1.service
	sudo bash -c 'mv /tmp/cop1.service ${INSTALL_DST} && chmod 755 ${INSTALL_DST} && chown root:root ${INSTALL_DST}'
	sudo systemctl daemon-reload
	$(info You can now start and enable the cop1 service)
	$(info )
	$(info # systemctl enable cop1)
	$(info )
	$(info # systemctl start cop1)
	$(info )
	$(info Configure the service using the environement variables present in the .env file)

clean_dev: clean
	rm -rf database.db || true

clean:
	rm -rf .venv
