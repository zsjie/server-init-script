#!/bin/bash

##############################################################################
# Nginx Module
# - Install nginx
# - Start and enable nginx service
# - Basic configuration
##############################################################################

install_nginx() {
    # Check if Nginx is already installed
    if command -v nginx &> /dev/null; then
        warn "Nginx is already installed: $(nginx -v 2>&1)"
        read -p "Reinstall Nginx? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi

    info "Updating apt cache..."
    ${SUDO} apt-get update -qq > /dev/null 2>&1

    # Install Nginx
    info "Installing Nginx..."
    ${SUDO} apt-get install -y nginx > /dev/null 2>&1
    success "Nginx installed"

    # Start and enable Nginx service
    info "Starting Nginx service..."
    ${SUDO} systemctl start nginx
    ${SUDO} systemctl enable nginx > /dev/null 2>&1
    success "Nginx service started and enabled"

    # Basic configuration - set worker processes to auto
    info "Applying basic Nginx configuration..."
    ${SUDO} sed -i 's/worker_processes\s\+.*;/worker_processes auto;/' /etc/nginx/nginx.conf 2>/dev/null || true

    # Test Nginx configuration
    if ${SUDO} nginx -t > /dev/null 2>&1; then
        ${SUDO} systemctl reload nginx > /dev/null 2>&1 || true
        success "Nginx configuration validated"
    else
        warn "Nginx configuration test failed, using default configuration"
    fi

    separator
    success "Nginx installation completed!"
    echo ""
    info "Nginx version: $(nginx -v 2>&1)"
    info "Nginx is listening on ports:"
    ${SUDO} ss -tlnp | grep nginx || echo "  (unable to detect listening ports)"
    separator
}
