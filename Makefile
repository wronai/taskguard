.PHONY: help install install-dev install-docs install-llm install-security install-all test test-cov lint format type-check check-deps security-check docs serve clean

# Colors
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

TARGET_MAX_CHAR_NUM=20

## Show help
default: help

help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

## Install the package in development mode
install:
	@poetry install --only main

## Install development dependencies
install-dev:
	@poetry install --with dev

## Install documentation dependencies
install-docs:
	@poetry install --with docs

## Install LLM dependencies
install-llm:
	@poetry install --with llm

## Install security dependencies
install-security:
	@poetry install --with security

## Install all dependencies
install-all:
	@poetry install --all-extras

## Run tests
test:
	@poetry run pytest tests/ -v

## Run tests with coverage report
test-cov:
	@poetry run pytest --cov=taskguard --cov-report=term-missing tests/

## Run linter
lint:
	@echo "${YELLOW}Running flake8...${RESET}"
	@poetry run flake8 taskguard tests/
	@echo "${YELLOW}Running black...${RESET}"
	@poetry run black --check taskguard tests/

## Format code
format:
	@poetry run black taskguard tests/
	@poetry run isort taskguard tests/

## Run type checking
type-check:
	@poetry run mypy taskguard/

## Check for security vulnerabilities
security-check:
	@echo "${YELLOW}Running bandit...${RESET}"
	@poetry run bandit -r taskguard/
	@echo "${YELLOW}Running safety check...${RESET}"
	@poetry run safety check

## Build documentation
docs:
	@poetry run mkdocs build --clean

## Serve documentation locally
serve:
	@poetry run mkdocs serve

## Clean up build artifacts
clean:
	@rm -rf build/ dist/ *.egg-info .pytest_cache/ .mypy_cache/ .coverage htmlcov/ site/

## Run all checks
check: lint type-check test-cov security-check

## Prepare for commit (format, lint, test)
pre-commit: format lint test

## Install pre-commit hooks
install-hooks:
	@poetry run pre-commit install

## Update dependencies
update:
	@poetry update

## Show outdated dependencies
outdated:
	@poetry show --outdated

## Build package
build:
	@poetry build

## Publish to PyPI
publish:
	@poetry publish --build

## Run the application
run:
	@poetry run taskguard

## Show package info
info:
	@poetry show taskguard
	@poetry version

## Show environment info
env:
	@echo "${YELLOW}Python:${RESET} $(shell poetry run python --version)"
	@echo "${YELLOW}Poetry:${RESET} $(shell poetry --version)"
	@echo "${YELLOW}Pip:${RESET} $(shell poetry run pip --version)"

## Show help
debug:
	@echo "${YELLOW}Debug information:${RESET}"
	@echo "PYTHONPATH: ${PYTHONPATH}"
	@echo "VIRTUAL_ENV: ${VIRTUAL_ENV}"
	@echo "POETRY_ACTIVE: ${POETRY_ACTIVE}"
	@echo "POETRY_ENV: $(shell poetry env info --path)"

## Show this help message
help:
	@echo "${YELLOW}Available targets:${RESET}"
	@echo "  ${GREEN}install${RESET}         - Install the package in development mode"
	@echo "  ${GREEN}install-dev${RESET}     - Install development dependencies"
	@echo "  ${GREEN}install-docs${RESET}    - Install documentation dependencies"
	@echo "  ${GREEN}install-llm${RESET}     - Install LLM dependencies"
	@echo "  ${GREEN}install-security${RESET} - Install security dependencies"
	@echo "  ${GREEN}install-all${RESET}     - Install all dependencies"
	@echo "  ${GREEN}test${RESET}            - Run tests"
	@echo "  ${GREEN}test-cov${RESET}        - Run tests with coverage report"
	@echo "  ${GREEN}lint${RESET}            - Run linter"
	@echo "  ${GREEN}format${RESET}          - Format code"
	@echo "  ${GREEN}type-check${RESET}      - Run type checking"
	@echo "  ${GREEN}security-check${RESET}  - Check for security vulnerabilities"
	@echo "  ${GREEN}docs${RESET}            - Build documentation"
	@echo "  ${GREEN}serve${RESET}           - Serve documentation locally"
	@echo "  ${GREEN}clean${RESET}           - Clean up build artifacts"
	@echo "  ${GREEN}check${RESET}           - Run all checks (lint, type-check, test, security)"
	@echo "  ${GREEN}pre-commit${RESET}      - Prepare for commit (format, lint, test)"
	@echo "  ${GREEN}install-hooks${RESET}   - Install pre-commit hooks"
	@echo "  ${GREEN}update${RESET}          - Update dependencies"
	@echo "  ${GREEN}outdated${RESET}        - Show outdated dependencies"
	@echo "  ${GREEN}build${RESET}           - Build package"
	@echo "  ${GREEN}publish${RESET}         - Publish to PyPI"
	@echo "  ${GREEN}run${RESET}             - Run the application"
	@echo "  ${GREEN}info${RESET}            - Show package info"
	@echo "  ${GREEN}env${RESET}             - Show environment info"
	@echo "  ${GREEN}debug${RESET}           - Show debug information"
	@echo "  ${GREEN}help${RESET}            - Show this help message"

# Default target
.DEFAULT_GOAL := help
