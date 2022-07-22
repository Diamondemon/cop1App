.PHONY: all run insall clean clean_dev admin
PYTHON=python3.10
INSTALL_DST=/etc/systemd/system

all: setup

.venv:
	${PYTHON} -m venv .venv >/dev/null
	bash -c 'source ${PWD}/.venv/bin/activate && ${PYTHON} -m pip install --upgrade pip && ${PYTHON} -m pip install -r requirements.txt' >/dev/null

.env:
	cp .env.example .env;
	@echo "\e[0;33mWARNING: New env file generated, modify variables in the .env file\e[0m";

run: .venv .env
	bash -c 'source .env && source ${PWD}/.venv/bin/activate && uvicorn app:app --host 0.0.0.0 --port $${PORT:-8000}'

dev: .venv
	bash -c 'source .env && source ${PWD}/.venv/bin/activate && uvicorn app:app --reload --host 0.0.0.0 --port $${PORT:-8000}'

install: .venv .env
	envsubst < cop1.service > /tmp/cop1.service
	envsubst < cop1adm.service > /tmp/cop1adm.service
	sudo bash -c 'mv /tmp/cop1.service ${INSTALL_DST}/cop1.service && chmod 755 ${INSTALL_DST}/cop1.service && chown root:root ${INSTALL_DST}/cop1.service'
	sudo bash -c 'mv /tmp/cop1adm.service ${INSTALL_DST}/cop1adm.service && chmod 755 ${INSTALL_DST}/cop1adm.service && chown root:root ${INSTALL_DST}/cop1adm.service'
	sudo systemctl daemon-reload
	@echo "\e[0;32mINFO: You can now start and enable the cop1 service\e[0m"
	@echo "\e[0;32mINFO: \e[0m"
	@echo "\e[0;32mINFO: # systemctl enable cop1\e[0m"
	@echo "\e[0;32mINFO: # systemctl enable cop1adm\e[0m"
	@echo "\e[0;32mINFO: \e[0m"
	@echo "\e[0;32mINFO: # systemctl start cop1\e[0m"
	@echo "\e[0;32mINFO: # systemctl start cop1adm\e[0m"
	@echo "\e[0;32mINFO: \e[0m"
	@echo "\e[0;32mINFO: Configure the service using the environement variables present in the .env file\e[0m"

clean_dev:
	rm -rf database.db || true

clean:
	rm -rf .venv

admin: .venv
	bash -c 'source .env && source ${PWD}/.venv/bin/activate && gunicorn -w 1 -b 0.0.0.0:3000 "admin.app:app"'
