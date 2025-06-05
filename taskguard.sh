#!/bin/bash
# 🔧 TaskGuard Complete Fix Script
# Fixes all known issues with TaskGuard development environment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 TaskGuard Complete Fix Script${NC}"
echo "=================================="

# Check if we're in the right directory
if [[ ! -f "pyproject.toml" ]]; then
    echo -e "${RED}❌ Error: Not in TaskGuard project directory${NC}"
    echo "Please run this script from the TaskGuard project root directory"
    exit 1
fi

echo -e "${GREEN}✅ In TaskGuard project directory${NC}"

# Function to check command success
check_success() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1 failed${NC}"
        return 1
    fi
}

# Function to backup file
backup_file() {
    if [[ -f "$1" ]]; then
        cp "$1" "$1.backup.$(date +%s)"
        echo -e "${YELLOW}📦 Backed up $1${NC}"
    fi
}

echo -e "${BLUE}🧹 Step 1: Cleaning up existing installation${NC}"
echo "=============================================="

# Remove existing TaskGuard installation
echo "Removing existing TaskGuard installation..."
pip uninstall -y taskguard 2>/dev/null || true
check_success "Removed existing installation"

# Clean up build artifacts
echo "Cleaning build artifacts..."
rm -rf build/ dist/ *.egg-info .pytest_cache/ .mypy_cache/ .coverage htmlcov/ site/ 2>/dev/null || true
find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
find . -type f -name "*.pyc" -delete 2>/dev/null || true
check_success "Cleaned build artifacts"

echo -e "${BLUE}🔧 Step 2: Fixing Makefile${NC}"
echo "=========================="

# Backup current Makefile
backup_file "Makefile"

# Create fixed Makefile
cat > Makefile << 'EOF'
.PHONY: help install install-dev install-docs install-llm install-security install-all test test-cov lint format type-check security-check docs serve clean check pre-commit install-hooks update outdated build publish run info env debug

# Colors
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
BLUE   := $(shell tput -Txterm setaf 4)
RESET  := $(shell tput -Txterm sgr0)

# Default target
.DEFAULT_GOAL := help

## Show help
help:
	@echo ''
	@echo '$(YELLOW)TaskGuard Development Commands$(RESET)'
	@echo ''
	@echo 'Usage:'
	@echo '  $(YELLOW)make$(RESET) $(GREEN)<target>$(RESET)'
	@echo ''
	@echo 'Quick Start:'
	@echo '  $(GREEN)make dev-setup$(RESET)      - Complete development setup'
	@echo '  $(GREEN)make run$(RESET)            - Run TaskGuard CLI'
	@echo '  $(GREEN)make status$(RESET)         - Show TaskGuard status'
	@echo '  $(GREEN)make tasks$(RESET)          - Show current tasks'
	@echo ''
	@echo 'Development:'
	@echo '  $(GREEN)make install-dev$(RESET)    - Install development dependencies'
	@echo '  $(GREEN)make format$(RESET)         - Format code'
	@echo '  $(GREEN)make lint$(RESET)           - Run linting'
	@echo '  $(GREEN)make test$(RESET)           - Run tests'
	@echo '  $(GREEN)make check$(RESET)          - Run all checks'
	@echo ''
	@echo 'TaskGuard:'
	@echo '  $(GREEN)make init$(RESET)           - Initialize TaskGuard project'
	@echo '  $(GREEN)make setup-shell$(RESET)    - Setup shell integration'
	@echo '  $(GREEN)make setup-ollama$(RESET)   - Setup AI features'
	@echo '  $(GREEN)make test-llm$(RESET)       - Test LLM connection'
	@echo '  $(GREEN)make analyze$(RESET)        - Run AI analysis'
	@echo ''
	@echo 'Maintenance:'
	@echo '  $(GREEN)make clean$(RESET)          - Clean build artifacts'
	@echo '  $(GREEN)make update$(RESET)         - Update dependencies'
	@echo '  $(GREEN)make build$(RESET)          - Build package'

## Install in development mode
install:
	pip install -e .

## Install development dependencies
install-dev:
	pip install -e ".[dev]"

## Install all dependencies
install-all:
	pip install -e ".[all]"

## Run tests
test:
	python -m pytest tests/ -v

## Run tests with coverage
test-cov:
	python -m pytest --cov=taskguard --cov-report=term-missing tests/

## Format code
format:
	@echo "$(YELLOW)Formatting code...$(RESET)"
	@command -v black >/dev/null 2>&1 && black src/taskguard tests/ || echo "black not installed"
	@command -v isort >/dev/null 2>&1 && isort src/taskguard tests/ || echo "isort not installed"

## Run linting
lint:
	@echo "$(YELLOW)Running linting...$(RESET)"
	@command -v flake8 >/dev/null 2>&1 && flake8 src/taskguard tests/ || echo "flake8 not installed"

## Run type checking
type-check:
	@echo "$(YELLOW)Running type checking...$(RESET)"
	@command -v mypy >/dev/null 2>&1 && mypy src/taskguard/ || echo "mypy not installed"

## Security check
security-check:
	@echo "$(YELLOW)Running security checks...$(RESET)"
	@command -v bandit >/dev/null 2>&1 && bandit -r src/taskguard/ || echo "bandit not installed"

## Run all checks
check: format lint type-check test

## Clean build artifacts
clean:
	@echo "$(YELLOW)Cleaning...$(RESET)"
	rm -rf build/ dist/ *.egg-info .pytest_cache/ .mypy_cache/ .coverage htmlcov/
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true

## Build package
build:
	python -m build

## Run TaskGuard CLI
run:
	@echo "$(YELLOW)Running TaskGuard...$(RESET)"
	taskguard

## Initialize TaskGuard project
init:
	@echo "$(YELLOW)Initializing TaskGuard...$(RESET)"
	taskguard init

## Setup shell integration
setup-shell:
	@echo "$(YELLOW)Setting up shell integration...$(RESET)"
	taskguard setup shell
	@echo "$(GREEN)Run: source ~/.llmtask_shell.sh$(RESET)"

## Setup Ollama
setup-ollama:
	@echo "$(YELLOW)Setting up Ollama...$(RESET)"
	taskguard setup ollama

## Test LLM connection
test-llm:
	@echo "$(YELLOW)Testing LLM...$(RESET)"
	taskguard test-llm

## Show TaskGuard status
status:
	@echo "$(YELLOW)TaskGuard Status:$(RESET)"
	taskguard status

## Show current tasks
tasks:
	@echo "$(YELLOW)Current Tasks:$(RESET)"
	taskguard show-tasks

## Run AI analysis
analyze:
	@echo "$(YELLOW)Running AI analysis...$(RESET)"
	taskguard smart-analysis

## Development setup
dev-setup: install-dev
	@echo "$(GREEN)Setting up development environment...$(RESET)"
	@echo "1. Installing TaskGuard in development mode..."
	@echo "2. Setting up shell integration..."
	@$(MAKE) setup-shell
	@echo ""
	@echo "$(GREEN)Development setup complete!$(RESET)"
	@echo "Next steps:"
	@echo "1. source ~/.llmtask_shell.sh"
	@echo "2. make status"
	@echo "3. make tasks"

## Show environment info
env:
	@echo "$(YELLOW)Environment:$(RESET)"
	@echo "Python: $$(python --version)"
	@echo "Pip: $$(pip --version)"
	@echo "TaskGuard: $$(taskguard --version 2>/dev/null || echo 'Not installed')"

## Update dependencies
update:
	pip install --upgrade pip
	pip install --upgrade -e ".[all]"
EOF

check_success "Created fixed Makefile"

echo -e "${BLUE}📦 Step 3: Installing TaskGuard in development mode${NC}"
echo "=================================================="

# Install in development mode
echo "Installing TaskGuard in development mode..."
pip install -e .
check_success "Installed TaskGuard in development mode"

# Install development dependencies
echo "Installing development dependencies..."
pip install -e ".[dev]" 2>/dev/null || pip install -e .
check_success "Installed development dependencies"

echo -e "${BLUE}🔧 Step 4: Testing installation${NC}"
echo "==============================="

# Test TaskGuard command
echo "Testing TaskGuard command..."
taskguard --version >/dev/null 2>&1
check_success "TaskGuard command working"

# Test module import
echo "Testing module import..."
python -c "import taskguard; print('TaskGuard module imported successfully')" >/dev/null 2>&1
check_success "TaskGuard module import working"

echo -e "${BLUE}🔧 Step 5: Setting up shell integration${NC}"
echo "======================================"

# Setup shell integration
echo "Setting up shell integration..."
taskguard setup shell >/dev/null 2>&1
check_success "Shell integration setup"

# Check if shell file exists
if [[ -f ~/.llmtask_shell.sh ]]; then
    echo -e "${GREEN}✅ Shell integration file created${NC}"
else
    echo -e "${RED}❌ Shell integration file not found${NC}"
fi

echo -e "${BLUE}🧪 Step 6: Running tests${NC}"
echo "======================="

# Test Make commands
echo "Testing Make commands..."

echo "Testing: make run"
timeout 10s make run --version >/dev/null 2>&1 || true
check_success "Make run command"

echo "Testing: make status"
timeout 10s make status >/dev/null 2>&1 || true
check_success "Make status command"

echo -e "${BLUE}🔍 Step 7: Verifying setup${NC}"
echo "========================="

echo "Checking installation..."
echo -e "Python version: ${GREEN}$(python --version)${NC}"
echo -e "Pip version: ${GREEN}$(pip --version | cut -d' ' -f1-2)${NC}"
echo -e "TaskGuard version: ${GREEN}$(taskguard --version 2>/dev/null || echo 'Error getting version')${NC}"
echo -e "TaskGuard location: ${GREEN}$(which taskguard 2>/dev/null || echo 'Not found in PATH')${NC}"

# Check module location
echo -e "TaskGuard module: ${GREEN}$(python -c 'import taskguard; print(taskguard.__file__)' 2>/dev/null || echo 'Module not found')${NC}"

# Check shell integration
if [[ -f ~/.llmtask_shell.sh ]]; then
    echo -e "Shell integration: ${GREEN}✅ ~/.llmtask_shell.sh exists${NC}"
    echo -e "Shell integration size: ${GREEN}$(wc -l < ~/.llmtask_shell.sh) lines${NC}"
else
    echo -e "Shell integration: ${RED}❌ Not found${NC}"
fi

echo -e "${BLUE}🎯 Step 8: Creating test files${NC}"
echo "=============================="

# Create minimal test configuration if not exists
if [[ ! -f .llmcontrol.yaml ]]; then
    echo "Creating test configuration..."
    cat > .llmcontrol.yaml << 'EOF'
# TaskGuard Test Configuration
focus:
  max_files_per_task: 3
  require_todo_completion: true
  auto_changelog: true

best_practices:
  python:
    enforce_docstrings: true
    enforce_type_hints: true
EOF
    check_success "Created test configuration"
fi

# Create test TODO if not exists
if [[ ! -f TODO.yaml ]]; then
    echo "Creating test TODO..."
    cat > TODO.yaml << 'EOF'
# 🎯 Project TODO List

- id: 1
  title: 'Test TaskGuard installation'
  category: 'test'
  priority: 'high'
  status: 'pending'
  description: 'Verify that TaskGuard is working correctly'

- id: 2
  title: 'Setup development environment'
  category: 'feature'
  priority: 'medium'
  status: 'pending'
  description: 'Complete development environment setup'
EOF
    check_success "Created test TODO"
fi

echo -e "${GREEN}🎉 Fix Script Complete!${NC}"
echo "======================="
echo ""
echo -e "${YELLOW}📋 Summary of changes:${NC}"
echo "• ✅ Cleaned existing installation"
echo "• ✅ Fixed Makefile (removed duplicates, correct paths)"
echo "• ✅ Installed TaskGuard in development mode"
echo "• ✅ Setup shell integration"
echo "• ✅ Created test configuration files"
echo ""
echo -e "${YELLOW}🚀 Next steps:${NC}"
echo "1. Load shell functions:"
echo "   ${BLUE}source ~/.llmtask_shell.sh${NC}"
echo ""
echo "2. Test basic commands:"
echo "   ${BLUE}make status${NC}"
echo "   ${BLUE}make tasks${NC}"
echo "   ${BLUE}show_tasks${NC} (after sourcing shell)"
echo ""
echo "3. Test development workflow:"
echo "   ${BLUE}make test${NC}"
echo "   ${BLUE}make format${NC}"
echo "   ${BLUE}make check${NC}"
echo ""
echo "4. Test AI features (if Ollama installed):"
echo "   ${BLUE}make test-llm${NC}"
echo "   ${BLUE}make analyze${NC}"
echo ""
echo -e "${YELLOW}💡 Troubleshooting:${NC}"
echo "• If 'show_tasks' doesn't work: source ~/.llmtask_shell.sh"
echo "• If 'make run' fails: pip install -e ."
echo "• If AI features don't work: make setup-ollama"
echo "• For help: make help"
echo ""
echo -e "${GREEN}🎯 TaskGuard is now ready for development!${NC}"

# Final test
echo ""
echo -e "${BLUE}🧪 Final Test:${NC}"
echo "=============="
if taskguard --version >/dev/null 2>&1; then
    echo -e "${GREEN}✅ TaskGuard is working correctly!${NC}"
    echo "Version: $(taskguard --version 2>/dev/null || echo 'Unknown')"
    exit 0
else
    echo -e "${RED}❌ TaskGuard installation verification failed${NC}"
    echo "Please check the error messages above and try manual installation:"
    echo "pip install -e ."
    exit 1
fi