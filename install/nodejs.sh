#!/bin/bash

##############################################################################
# Node.js Module
# - Install Node.js 22.x using NodeSource repository
# - Install PM2 globally via npm
# - Configure PM2 startup script
##############################################################################

install_nodejs() {
    NODE_VERSION="22"

    # Check if Node.js is already installed
    if command -v node &> /dev/null; then
        INSTALLED_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        warn "Node.js is already installed: $(node -v)"
        if [ "${INSTALLED_VERSION}" = "${NODE_VERSION}" ]; then
            read -p "Reinstall Node.js ${NODE_VERSION}.x? [y/N]: " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                # Still check PM2
                install_pm2
                return
            fi
        fi
    fi

    info "Updating apt cache..."
    ${SUDO} apt-get update -qq > /dev/null 2>&1

    # Install prerequisites
    info "Installing Node.js prerequisites..."
    ${SUDO} apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        > /dev/null 2>&1

    # Add NodeSource GPG key and repository
    info "Adding NodeSource repository for Node.js ${NODE_VERSION}.x..."
    ${SUDO} mkdir -p /etc/apt/keyrings
    curl -fsSL "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" | \
        ${SUDO} gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg > /dev/null 2>&1

    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION}.x nodistro main" | \
        ${SUDO} tee /etc/apt/sources.list.d/nodesource.list > /dev/null
    success "NodeSource repository added"

    # Update apt cache
    ${SUDO} apt-get update -qq > /dev/null 2>&1

    # Install Node.js
    info "Installing Node.js ${NODE_VERSION}.x..."
    ${SUDO} apt-get install -y nodejs > /dev/null 2>&1
    success "Node.js installed"

    # Verify installation
    NODE_VERSION_OUTPUT=$(node -v)
    NPM_VERSION_OUTPUT=$(npm -v)
    info "Node.js version: ${NODE_VERSION_OUTPUT}"
    info "npm version: ${NPM_VERSION_OUTPUT}"

    # Configure npm to use a non-root directory if running as non-root
    if [ "$(id -u)" -ne 0 ]; then
        info "Configuring npm for non-root user..."
        mkdir -p "${HOME}/.npm-global"
        npm config set prefix "${HOME}/.npm-global" > /dev/null 2>&1 || true

        # Add npm global to PATH in .bashrc and .zshrc
        if ! grep -q "npm-global" "${HOME}/.bashrc" 2>/dev/null; then
            echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "${HOME}/.bashrc"
        fi
        if [ -f "${HOME}/.zshrc" ] && ! grep -q "npm-global" "${HOME}/.zshrc"; then
            echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "${HOME}/.zshrc"
        fi
    fi

    # Install PM2
    install_pm2

    separator
    success "Node.js installation completed!"
    separator
}

install_pm2() {
    # Check if PM2 is already installed
    if command -v pm2 &> /dev/null; then
        warn "PM2 is already installed: $(pm2 --version)"
        read -p "Reinstall PM2? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi

    info "Installing PM2..."
    if [ "$(id -u)" -eq 0 ]; then
        npm install -g pm2 > /dev/null 2>&1
    else
        npm install -g pm2 > /dev/null 2>&1
    fi
    success "PM2 installed: $(pm2 --version)"

    # Configure PM2 startup
    info "Configuring PM2 startup script..."
    if command -v envsubst &> /dev/null; then
        # Generate startup script but don't execute it
        pm2 startup | head -n 1 > /dev/null 2>&1 || true
        success "PM2 startup script configured (run 'pm2 save' after adding apps)"
    else
        warn "Could not configure PM2 startup (envsubst not available)"
        warn "Run: pm2 startup"
    fi

    info "PM2 commands:"
    echo "  - pm2 start <app.js>      - Start an application"
    echo "  - pm2 list                 - List all processes"
    echo "  - pm2 logs                 - View logs"
    echo "  - pm2 stop <app|id>        - Stop a process"
    echo "  - pm2 restart <app|id>     - Restart a process"
    echo "  - pm2 save                 - Save process list"
}
