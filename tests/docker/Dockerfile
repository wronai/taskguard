# Base image with multiple Python versions and common tools
FROM ubuntu:22.04

# Set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install common dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    curl \
    wget \
    vim \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -s /bin/bash tester && \
    echo 'tester ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set working directory
WORKDIR /app

# Copy test files
COPY . /app/

# Set the user
USER tester

# Create a virtual environment
RUN python3 -m venv /home/tester/venv
ENV PATH="/home/tester/venv/bin:$PATH"

# Install TaskGuard in development mode
RUN pip install -e .[dev]

# Default command
CMD ["/bin/bash"]
