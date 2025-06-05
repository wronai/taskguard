#!/bin/bash
set -e

# Function to print section headers
section() {
    echo -e "\n\033[1;33m=== $1 ===\033[0m"
}

# Function to print status messages
status() {
    echo -e "\033[1;34m[+] $1\033[0m"
}

# Function to print error messages
error() {
    echo -e "\033[1;31m[!] ERROR: $1\033[0m" >&2
    exit 1
}

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    error "Docker is not running. Please start Docker and try again."
fi

# Check if docker-compose is installed
if ! command -v docker-compose >/dev/null 2>&1; then
    error "docker-compose is not installed. Please install it and try again."
fi

# Start all test containers
section "Starting Test Environment"
status "Building and starting Docker containers..."
if ! docker-compose up -d --build; then
    error "Failed to start containers. Check the output above for details."
fi

# Wait for containers to be ready
status "Waiting for containers to initialize..."
for i in {1..10}; do
    if docker-compose ps | grep -q "Up (health"; then
        status "All containers are up and healthy!"
        break
    fi
    if [ $i -eq 10 ]; then
        error "Timed out waiting for containers to start. Check the logs with 'docker-compose logs'."
    fi
    echo -n "."
    sleep 5
done

# Function to check if container is healthy
container_healthy() {
    local container=$1
    local state=$(docker inspect -f '{{.State.Health.Status}}' "$container" 2>/dev/null || echo "unknown")
    [ "$state" = "healthy" ]
}

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

EOL

# Add each container to the inventory
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

# Add containers to inventory
for container in "${containers[@]}"; do
    echo "$container" >> inventory.ini
    
    # Wait for container to be healthy
    status "Waiting for $container to be ready..."
    for i in {1..20}; do
        if container_healthy "${container}_1"; then
            status "$container is ready!"
            break
        fi
        if [ $i -eq 20 ]; then
            error "Timed out waiting for $container to be ready"
        fi
        echo -n "."
        sleep 5
    done
done

# Add OS groups to inventory
echo -e "\n# OS Groups" >> inventory.ini
for group in "${!os_groups[@]}"; do
    echo -e "\n[$group]" >> inventory.ini
    for container in ${os_groups[$group]}; do
        echo "$container" >> inventory.ini
    done
done

# Run Ansible playbook
section "Running Tests"
status "Starting test execution with Ansible..."

if ! ansible-playbook -i inventory.ini tests/docker/playbooks/run_tests.yml; then
    error "Test execution failed. Check the output above for details."
fi

# Print completion message
section "Test Execution Complete"
status "All tests have been executed!"
status "Test report: /tmp/taskguard-test-report.html"

# Show quick summary
status "Container Status:"
docker-compose ps

echo -e "\n✅ \033[1;32mAll tests completed successfully!\033[0m"
