#!/bin/bash
# 🧠 TaskGuard Smart Installer
# One script to rule them all

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧠 TaskGuard Smart Installer${NC}"
echo "=============================="

# Detect system
OS="unknown"
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    OS="windows"
fi

echo -e "🖥️  Detected OS: ${GREEN}$OS${NC}"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}⚠️  Python3 not found. Installing...${NC}"

    if [[ "$OS" == "linux" ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y python3 python3-pip
        elif command -v yum &> /dev/null; then
            sudo yum install -y python3 python3-pip
        elif command -v pacman &> /dev/null; then
            sudo pacman -S python python-pip
        fi
    elif [[ "$OS" == "macos" ]]; then
        if command -v brew &> /dev/null; then
            brew install python3
        else
            echo -e "${RED}❌ Please install Homebrew first: https://brew.sh${NC}"
            exit 1
        fi
    fi
fi

echo -e "✅ Python3: ${GREEN}$(python3 --version)${NC}"

# Install TaskGuard
echo -e "${BLUE}📦 Installing TaskGuard...${NC}"
pip3 install taskguard

# Check if user wants AI features
echo -e "${YELLOW}🤖 Do you want AI features? (Y/n):${NC}"
read -t 10 -n 1 -r ai_choice || ai_choice="y"
echo

if [[ $ai_choice =~ ^[Yy]$ ]] || [[ -z $ai_choice ]]; then
    echo -e "${BLUE}🧠 Installing Ollama + AI model...${NC}"

    # Install Ollama
    if [[ "$OS" == "linux" || "$OS" == "macos" ]]; then
        curl -fsSL https://ollama.ai/install.sh | sh

        # Start Ollama in background
        ollama serve &
        OLLAMA_PID=$!

        # Wait for Ollama to start
        sleep 5

        # Pull model
        echo -e "${BLUE}📡 Downloading AI model (llama3.2:3b - ~2GB)...${NC}"
        ollama pull llama3.2:3b

        echo -e "✅ AI features: ${GREEN}Ready${NC}"
    else
        echo -e "${YELLOW}⚠️  Ollama not supported on Windows yet. Skipping AI features.${NC}"
    fi
fi

# Detect project type
PROJECT_TYPE="basic"
if [[ -f "requirements.txt" || -f "pyproject.toml" || -f "setup.py" ]]; then
    PROJECT_TYPE="python"
elif [[ -f "package.json" ]]; then
    PROJECT_TYPE="javascript"
elif [[ -d ".git" && $(find . -name "*.py" | wc -l) -gt 5 ]]; then
    PROJECT_TYPE="python"
elif [[ -d ".git" && $(find . -name "*.js" -o -name "*.ts" | wc -l) -gt 5 ]]; then
    PROJECT_TYPE="javascript"
fi

echo -e "🎯 Detected project type: ${GREEN}$PROJECT_TYPE${NC}"

# Initialize TaskGuard
echo -e "${BLUE}🚀 Initializing TaskGuard...${NC}"
if [[ "$PROJECT_TYPE" != "basic" ]]; then
    taskguard init --template "$PROJECT_TYPE"
else
    taskguard init
fi

# Setup shell integration
echo -e "${BLUE}🔧 Setting up shell integration...${NC}"
taskguard setup shell

# Add to shell profile
SHELL_NAME=$(basename "$SHELL")
if [[ "$SHELL_NAME" == "bash" ]]; then
    PROFILE_FILE="$HOME/.bashrc"
elif [[ "$SHELL_NAME" == "zsh" ]]; then
    PROFILE_FILE="$HOME/.zshrc"
else
    PROFILE_FILE="$HOME/.profile"
fi

if ! grep -q "llmtask_shell.sh" "$PROFILE_FILE" 2>/dev/null; then
    echo "source ~/.llmtask_shell.sh" >> "$PROFILE_FILE"
    echo -e "✅ Added to ${GREEN}$PROFILE_FILE${NC}"
fi

# Load shell functions for current session
source ~/.llmtask_shell.sh

# Test installation
echo -e "${BLUE}🧪 Testing installation...${NC}"

# Test basic commands
if command -v show_tasks &> /dev/null; then
    echo -e "✅ Shell functions: ${GREEN}Working${NC}"
else
    echo -e "❌ Shell functions: ${RED}Failed${NC}"
fi

# Test AI if installed
if [[ $ai_choice =~ ^[Yy]$ ]] || [[ -z $ai_choice ]]; then
    if taskguard test-llm &>/dev/null; then
        echo -e "✅ AI features: ${GREEN}Working${NC}"
    else
        echo -e "⚠️ AI features: ${YELLOW}Not ready (Ollama may need time to start)${NC}"
    fi
fi

# Show success message
echo
echo -e "${GREEN}🎉 TaskGuard Installation Complete!${NC}"
echo "====================================="
echo
echo -e "${BLUE}🚀 Quick Start:${NC}"
echo "  show_tasks              # List current tasks"
echo "  start_task 1            # Start working on task 1"
echo "  smart_analysis          # AI project analysis (if AI enabled)"
echo "  tg_help                 # Show all commands"
echo
echo -e "${BLUE}📚 Examples:${NC}"
echo "  add_task 'Fix login bug' bugfix high"
echo "  best_practices auth.py"
echo "  focus_status"
echo
echo -e "${YELLOW}💡 Pro Tip:${NC} Type 'overview' for project status"

# Cleanup
if [[ -n "$OLLAMA_PID" ]]; then
    # Keep Ollama running
    disown $OLLAMA_PID
fi

echo
echo -e "${GREEN}Happy intelligent coding! 🧠✨${NC}"
