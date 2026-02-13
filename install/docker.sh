#!/bin/bash

##############################################################################
# Docker Module
# - Add Docker GPG key
# - Add Docker apt repository
# - Install Docker CE, CLI, containerd, docker-compose plugin
# - Start and enable docker service
# - Add current user to docker group
##############################################################################

install_docker() {
    # Check if Docker is already installed
    if command -v docker &> /dev/null; then
        warn "Docker is already installed: $(docker --version)"
        read -p "Reinstall Docker? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi

    info "Updating apt cache..."
    ${SUDO} apt-get update -qq > /dev/null 2>&1

    # Install prerequisites
    info "Installing Docker prerequisites..."
    ${SUDO} apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        > /dev/null 2>&1

    # Add Docker's official GPG key
    info "Adding Docker GPG key..."
    ${SUDO} install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | ${SUDO} gpg --dearmor -o /etc/apt/keyrings/docker.gpg > /dev/null 2>&1
    ${SUDO} chmod a+r /etc/apt/keyrings/docker.gpg
    success "Docker GPG key added"

    # Set up Docker repository
    info "Adding Docker apt repository..."
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      ${SUDO} tee /etc/apt/sources.list.d/docker.list > /dev/null
    success "Docker repository added"

    # Update apt cache
    ${SUDO} apt-get update -qq > /dev/null 2>&1

    # Install Docker packages
    info "Installing Docker packages..."
    ${SUDO} apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin \
        > /dev/null 2>&1
    success "Docker installed"

    # Start and enable Docker service
    info "Starting Docker service..."
    ${SUDO} systemctl start docker
    ${SUDO} systemctl enable docker > /dev/null 2>&1
    success "Docker service started and enabled"

    # Verify Docker installation
    ${SUDO} docker run --rm hello-world > /dev/null 2>&1
    success "Docker verification successful"

    # Add current user to docker group
    if [ "$(id -u)" -ne 0 ]; then
        CURRENT_USER=$(whoami)
        if ! groups "${CURRENT_USER}" | grep -q docker; then
            info "Adding user '${CURRENT_USER}' to docker group..."
            ${SUDO} usermod -aG docker "${CURRENT_USER}"
            success "User '${CURRENT_USER}' added to docker group"
            warn "Log out and log back in for group changes to take effect"
        else
            success "User '${CURRENT_USER}' is already in docker group"
        fi
    fi

    separator
    success "Docker installation completed!"
    echo ""
    info "Docker version: $(docker --version)"
    info "Compose version: $(docker compose version)"
    separator
}
