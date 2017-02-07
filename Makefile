.PHONY: help clean clean-venv clean-build clean-pyc clean-test coverage lint lint-html test venv install-dev-deps
.DEFAULT_GOAL := help
define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT
BROWSER := python -c "$$BROWSER_PYSCRIPT"

PYTHON_V = python2.7
PIP_V = 1.5.4
PIP_V_LATEST = 8.1.0
VIRTUALENV_V = 13.1.2
VENV_NAME=venv

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-venv: ## removes the the venv files
	rm -rf $(VENV_NAME).zip $(VENV_NAME)

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +
	find . -name '*_flymake.py' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/

coverage: ## check code coverage quickly with the default Python
	$(VENV_NAME)/bin/coverage run --source pipeline `which py.test`
	$(VENV_NAME)/bin/coverage report -m
	$(VENV_NAME)/bin/coverage html
	$(BROWSER) htmlcov/index.html

lint: ## check style with flake8
	$(VENV_NAME)/bin/flake8 pipeline tests

lint-html:  ##linting with an html report
	test -f flake8.txt && rm flake8.txt
	$(VENV_NAME)/bin/flake8 pipeline tests --output-file=flake8.txt
	$(VENV_NAME)/bin/pepper8 -o flake8.html flake8.txt


test: ## run tests quickly with the default Python
	$(VENV_NAME)/bin/py.test tests

venv: ## creates a virtual environment with all packages from requirements.txt
	test -d $(VENV_NAME) && echo "VENV already exists" || virtualenv -p $(PYTHON_V) $(VENV_NAME) && \
	. $(VENV_NAME)/bin/activate && \
	pip install -U pip==$(PIP_V) && \
	pip install -U virtualenv==$(VIRTUALENV_V) && \
	pip install -r requirements.txt  && \
	deactivate

install-dev-deps: venv ## installs packages from requirements_dev.txt
	. $(VENV_NAME)/bin/activate && \
	pip install -r requirements_dev.txt && \
	deactivate
