.PHONY: setup run
PYTHON=python3.10

all: setup run

run:
	bash -c 'source ${PWD}/.venv/bin/activate && uvicorn app:app --host 0.0.0.0 --port $${PORT:-8000}'

setup:
	${PYTHON} -m venv .venv
	bash -c 'source ${PWD}/.venv/bin/activate && ${PYTHON} -m pip install --upgrade pip && ${PYTHON} -m pip install -r requirements.txt'

dev:
	bash -c 'source ${PWD}/.venv/bin/activate && uvicorn app:app --reload --host 0.0.0.0 --port $${PORT:-8000}'

clean_dev:
	rm -rf database.db || true

clean: clean_dev
	rm -rf .venv
