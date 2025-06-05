#!/bin/bash
set -e

# Start all test containers
echo "🚀 Starting test containers..."
docker-compose up -d

# Wait for containers to be ready
echo "⏳ Waiting for containers to be ready..."
sleep 10

# Create Ansible inventory
cat > inventory.ini <<EOL
[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_user=tester
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[ubuntu]
test-ubuntu-20.04 ansible_host=test-ubuntu-20.04
test-ubuntu-22.04 ansible_host=test-ubuntu-22.04

[debian]
test-debian-bullseye ansible_host=test-debian-bullseye

[centos]
test-centos-7 ansible_host=test-centos-7
test-centos-8 ansible_host=test-centos-8

[alpine]
test-alpine-3.16 ansible_host=test-alpine-3.16
test-alpine-3.17 ansible_host=test-alpine-3.17

[archlinux]
test-archlinux ansible_host=test-archlinux
EOL

# Run Ansible playbook
echo "🔧 Running tests with Ansible..."
ansible-playbook -i inventory.ini tests/docker/playbooks/run_tests.yml

echo "✅ All tests completed!"
