.PHONY: help install install-dev install-docs install-llm install-security install-all test test-cov lint format type-check check-deps security-check docs serve clean check pre-commit install-hooks update outdated build publish run info env debug

# Colors
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

TARGET_MAX_CHAR_NUM=20

# Default target
.DEFAULT_GOAL := help

## Show help
help:
	@echo ''
	@echo '${YELLOW}TaskGuard Development Commands${RESET}'
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

## Install the package in development mode
install:
	pip install -e .

## Install development dependencies
install-dev:
	pip install -e ".[dev]"

## Install documentation dependencies
install-docs:
	pip install -e ".[docs]"

## Install LLM dependencies
install-llm:
	pip install -e ".[llm]"

## Install security dependencies
install-security:
	pip install -e ".[security]"

## Install all dependencies
install-all:
	pip install -e ".[all]"

## Run tests
test:
	python -m pytest tests/ -v

## Run tests with coverage report
test-cov:
	python -m pytest --cov=taskguard --cov-report=term-missing --cov-report=html tests/

## Run linter
lint:
	@echo "${YELLOW}Running flake8...${RESET}"
	flake8 src/taskguard tests/
	@echo "${YELLOW}Running black check...${RESET}"
	black --check src/taskguard tests/
	@echo "${YELLOW}Running isort check...${RESET}"
	isort --check-only src/taskguard tests/

## Format code
format:
	@echo "${YELLOW}Formatting code with black...${RESET}"
	black src/taskguard tests/
	@echo "${YELLOW}Sorting imports with isort...${RESET}"
	isort src/taskguard tests/

## Run type checking
type-check:
	@echo "${YELLOW}Running mypy...${RESET}"
	mypy src/taskguard/

## Check for security vulnerabilities
security-check:
	@echo "${YELLOW}Running bandit...${RESET}"
	bandit -r src/taskguard/
	@echo "${YELLOW}Running safety check...${RESET}"
	safety check

## Build documentation
docs:
	@echo "${YELLOW}Building documentation...${RESET}"
	@if command -v mkdocs >/dev/null 2>&1; then \
		mkdocs build --clean; \
	else \
		echo "${YELLOW}mkdocs not installed. Install with: pip install mkdocs mkdocs-material${RESET}"; \
	fi

## Serve documentation locally
serve:
	@echo "${YELLOW}Serving documentation at http://localhost:8000${RESET}"
	@if command -v mkdocs >/dev/null 2>&1; then \
		mkdocs serve; \
	else \
		echo "${YELLOW}mkdocs not installed. Install with: pip install mkdocs mkdocs-material${RESET}"; \
	fi

## Clean up build artifacts
clean:
	@echo "${YELLOW}Cleaning build artifacts...${RESET}"
	rm -rf build/ dist/ *.egg-info .pytest_cache/ .mypy_cache/ .coverage htmlcov/ site/
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

## Run all checks
check: lint type-check test-cov security-check
	@echo "${GREEN}All checks passed!${RESET}"

## Prepare for commit (format, lint, test)
pre-commit: format lint test
	@echo "${GREEN}Ready for commit!${RESET}"

## Install pre-commit hooks
install-hooks:
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit install; \
	else \
		echo "${YELLOW}pre-commit not installed. Installing...${RESET}"; \
		pip install pre-commit; \
		pre-commit install; \
	fi

## Update dependencies
update:
	pip install --upgrade pip
	pip install --upgrade -e ".[all]"

## Show outdated dependencies
outdated:
	pip list --outdated

## Build package
build:
	@echo "${YELLOW}Building package...${RESET}"
	python -m build

## Publish to PyPI (test)
publish-test:
	@echo "${YELLOW}Publishing to Test PyPI...${RESET}"
	python -m twine upload --repository testpypi dist/*

## Publish to PyPI
publish:
	@echo "${YELLOW}Publishing to PyPI...${RESET}"
	python -m twine upload dist/*

## Run the application
run:
	@echo "${YELLOW}Running TaskGuard...${RESET}"
	python -m taskguard.cli

## Run TaskGuard with arguments
run-args:
	@echo "${YELLOW}Running TaskGuard with args: $(ARGS)${RESET}"
	python -m taskguard.cli $(ARGS)

## Show package info
info:
	@echo "${YELLOW}Package Information:${RESET}"
	@python -c "import taskguard; print(f'Version: {taskguard.__version__}')"
	@python -c "import taskguard; print(f'Description: {taskguard.__description__}')"
	@python -c "import taskguard; taskguard.system_info()"

## Show environment info
env:
	@echo "${YELLOW}Environment Information:${RESET}"
	@echo "Python: $(shell python --version)"
	@echo "Pip: $(shell pip --version)"
	@echo "Python Path: $(shell which python)"
	@echo "TaskGuard installed: $(shell pip show taskguard >/dev/null 2>&1 && echo 'Yes' || echo 'No')"

## Show debug information
debug:
	@echo "${YELLOW}Debug Information:${RESET}"
	@echo "PYTHONPATH: $(PYTHONPATH)"
	@echo "PWD: $(PWD)"
	@echo "Shell: $(SHELL)"
	@echo "User: $(USER)"
	@echo "Python executable: $(shell which python)"
	@echo "Pip executable: $(shell which pip)"
	@echo "TaskGuard module location:"
	@python -c "try: import taskguard; print(taskguard.__file__); except ImportError: print('Not installed')"

## Initialize TaskGuard project
init:
	@echo "${YELLOW}Initializing TaskGuard project...${RESET}"
	python -m taskguard.cli init

## Setup shell integration
setup-shell:
	@echo "${YELLOW}Setting up shell integration...${RESET}"
	python -m taskguard.cli setup shell
	@echo "${GREEN}Shell integration ready! Run: source ~/.llmtask_shell.sh${RESET}"

## Setup with Ollama
setup-ollama:
	@echo "${YELLOW}Setting up Ollama...${RESET}"
	python -m taskguard.cli setup ollama

## Test LLM connection
test-llm:
	@echo "${YELLOW}Testing LLM connection...${RESET}"
	python -m taskguard.cli test-llm

## Show TaskGuard status
status:
	@echo "${YELLOW}TaskGuard Status:${RESET}"
	python -m taskguard.cli status

## Show TaskGuard tasks
tasks:
	@echo "${YELLOW}Current Tasks:${RESET}"
	python -m taskguard.cli show-tasks

## Run smart analysis
analyze:
	@echo "${YELLOW}Running AI analysis...${RESET}"
	python -m taskguard.cli smart-analysis

## Show TaskGuard help
taskguard-help:
	python -m taskguard.cli --help

## Development setup (install + setup shell + test)
dev-setup: install-dev setup-shell
	@echo "${GREEN}Development environment ready!${RESET}"
	@echo "Next steps:"
	@echo "1. source ~/.llmtask_shell.sh"
	@echo "2. make tasks"
	@echo "3. Start coding!"

## Production setup (install + setup everything)
prod-setup: install-all setup-shell setup-ollama
	@echo "${GREEN}Production environment ready!${RESET}"

## Full test suite
test-all: clean install-dev test-cov lint type-check security-check
	@echo "${GREEN}All tests completed!${RESET}"

## Release preparation
prepare-release: clean test-all build
	@echo "${GREEN}Release ready!${RESET}"
	@echo "Next: make publish-test or make publish"

## Quick development cycle
dev: format test
	@echo "${GREEN}Development cycle complete!${RESET}"

## Emergency clean (nuclear option)
nuke: clean
	@echo "${YELLOW}Nuclear clean...${RESET}"
	pip uninstall -y taskguard
	rm -rf ~/.llmtask_shell.sh ~/.llmcontrol.yaml .llmstate.json TODO.yaml CHANGELOG.md
	@echo "${GREEN}Everything cleaned!${RESET}"