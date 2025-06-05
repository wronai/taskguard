#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print section headers
section() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Function to print status messages
status() {
    echo -e "${BLUE}[+] $1${NC}"
}

# Function to print success messages
success() {
    echo -e "${GREEN}[✓] $1${NC}"
}

# Function to print warnings
warn() {
    echo -e "${YELLOW}[!] $1${NC}" >&2
}

# Function to print error messages
error() {
    echo -e "${RED}[✗] ERROR: $1${NC}" >&2
    exit 1
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    error "Docker is not running. Please start Docker and try again."
fi

# Check if docker-compose is installed
if ! command_exists docker-compose; then
    error "docker-compose is not installed. Please install it and try again."
fi

# Check if jq is installed (for JSON parsing)
if ! command_exists jq; then
    warn "jq is not installed. Installing..."
    if command_exists apt-get; then
        sudo apt-get update && sudo apt-get install -y jq
    elif command_exists yum; then
        sudo yum install -y jq
    elif command_exists dnf; then
        sudo dnf install -y jq
    elif command_exists pacman; then
        sudo pacman -S --noconfirm jq
    elif command_exists apk; then
        sudo apk add --no-cache jq
    else
        warn "Could not install jq automatically. Please install it manually and try again."
        exit 1
    fi
fi

# Clean up any existing containers
section "Cleaning Up"
status "Removing any existing containers..."
docker-compose down -v >/dev/null 2>&1 || true

# Start all test containers
section "Starting Test Environment"
status "Building and starting Docker containers..."
if ! docker-compose up -d --build; then
    error "Failed to start containers. Check the output above for details."
fi

# Function to check if container is healthy
container_healthy() {
    local container=$1
    local state=$(docker inspect -f '{{.State.Health.Status}}' "$container" 2>/dev/null || echo "unknown")
    [ "$state" = "healthy" ]
}

# Function to get container status
container_status() {
    local container=$1
    docker inspect -f '{{.State.Status}}' "$container" 2>/dev/null || echo "unknown"
}

# Function to wait for container to be ready
wait_for_container() {
    local container=$1
    local max_attempts=30
    local attempt=1
    
    status "Waiting for $container to be ready..."
    
    while [ $attempt -le $max_attempts ]; do
        local status=$(container_status "${container}_1")
        
        if [ "$status" != "running" ]; then
            warn "Container $container is not running (status: $status)"
            docker-compose logs "$container"
            return 1
        fi
        
        if container_healthy "${container}_1"; then
            success "$container is ready!"
            return 0
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            warn "Timed out waiting for $container to be ready"
            docker-compose logs "$container"
            return 1
        fi
        
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    return 1
}

# Wait for containers to be ready
section "Container Status"
containers=(
    "test-ubuntu-20.04"
    "test-ubuntu-22.04"
    "test-debian-bullseye"
    "test-centos-7"
    "test-centos-8"
    "test-alpine-3.16"
    "test-alpine-3.17"
    "test-archlinux"
)

# Group containers by OS type
declare -A os_groups=(
    [ubuntu]="test-ubuntu-20.04 test-ubuntu-22.04"
    [debian]="test-debian-bullseye"
    [centos]="test-centos-7 test-centos-8"
    [alpine]="test-alpine-3.16 test-alpine-3.17"
    [archlinux]="test-archlinux"
)

# Check container statuses
all_healthy=true
for container in "${containers[@]}"; do
    if ! wait_for_container "$container"; then
        warn "Container $container failed to start properly"
        all_healthy=false
    fi
done

if ! $all_healthy; then
    warn "Some containers failed to start properly. Continuing with available containers..."
fi

# Create Ansible inventory
section "Setting Up Test Environment"
status "Creating Ansible inventory..."

# Start with inventory header
cat > inventory.ini <<EOL
[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_user=tester
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_ssh_private_key_file=/dev/null
ansible_connection=docker
ansible_become=yes
ansible_become_method=sudo

EOL

# Add containers to inventory
for container in "${containers[@]}"; do
    # Only add container if it's running
    if [ "$(container_status "${container}_1")" = "running" ]; then
        echo "$container" >> inventory.ini
    fi
done

# Add OS groups to inventory
echo -e "\n# OS Groups" >> inventory.ini
for group in "${!os_groups[@]}"; do
    echo -e "\n[$group]" >> inventory.ini
    for container in ${os_groups[$group]}; do
        if [ "$(container_status "${container}_1")" = "running" ]; then
            echo "$container" >> inventory.ini
        fi
    done
done

# Show inventory
status "Generated inventory:"
cat inventory.ini

# Run Ansible playbook
section "Running Tests"
status "Starting test execution with Ansible..."

# Create test results directory
TEST_RESULTS_DIR="$(pwd)/test_results"
mkdir -p "$TEST_RESULTS_DIR"

if ! ansible-playbook -i inventory.ini playbooks/run_tests.yml \
    -e "test_results_dir=$TEST_RESULTS_DIR" \
    -e "src_dir=$(pwd)/../../src"; then
    error "Test execution failed. Check the output above for details."
fi

# Print completion message
section "Test Execution Complete"
if [ -f "$TEST_RESULTS_DIR/report.html" ]; then
    success "Test report generated: $TEST_RESULTS_DIR/report.html"
fi

# Show quick summary
status "Container Status:"
docker-compose ps

# Show test results
if [ -f "$TEST_RESULTS_DIR/summary.txt" ]; then
    echo -e "\n${GREEN}=== Test Summary ===${NC}"
    cat "$TEST_RESULTS_DIR/summary.txt"
fi

echo -e "\n✅ ${GREEN}All tests completed successfully!${NC}"
