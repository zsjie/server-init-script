#!/bin/bash

##############################################################################
# Server Environment Initialization Script
# For Debian 12+ systems
##############################################################################

set -e

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${SCRIPT_DIR}/install"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Auto confirm mode
AUTO_YES=false

##############################################################################
# Utility Functions
##############################################################################

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1" >&2
}

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

separator() {
    echo ""
    echo "========================================================================"
    echo ""
}

##############################################################################
# System Detection
##############################################################################

detect_system() {
    info "Detecting system..."

    # Check if running on Debian
    if [ ! -f /etc/debian_version ]; then
        error "This script is designed for Debian systems only."
        error "Current system: $(uname -s)"
        exit 1
    fi

    # Check Debian version
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        DEBIAN_VERSION=$(echo ${VERSION_ID} | cut -d. -f1)
        success "Detected: ${PRETTY_NAME}"
    else
        DEBIAN_VERSION=$(cat /etc/debian_version | cut -d. -f1)
        success "Detected: Debian ${DEBIAN_VERSION}"
    fi

    # Check Debian version >= 12
    if [ "${DEBIAN_VERSION}" -lt 12 ]; then
        error "Debian 12 or higher is required."
        error "Current version: ${DEBIAN_VERSION}"
        exit 1
    fi

    # Check root/sudo access
    if [ "$(id -u)" -eq 0 ]; then
        SUDO=""
        success "Running as root"
    else
        if command -v sudo &> /dev/null; then
            if sudo -n true 2>/dev/null; then
                SUDO="sudo"
                success "Running with sudo access"
            else
                SUDO="sudo"
                warn "Non-root user detected, will use sudo"
            fi
        else
            error "This script requires root privileges or sudo access."
            error "Please run as root or install sudo."
            exit 1
        fi
    fi

    separator
}

##############################################################################
# Load Install Modules
##############################################################################

source "${INSTALL_DIR}/system.sh" 2>/dev/null || { error "Failed to load system.sh"; exit 1; }
source "${INSTALL_DIR}/tools.sh" 2>/dev/null || { error "Failed to load tools.sh"; exit 1; }
source "${INSTALL_DIR}/docker.sh" 2>/dev/null || { error "Failed to load docker.sh"; exit 1; }
source "${INSTALL_DIR}/nginx.sh" 2>/dev/null || { error "Failed to load nginx.sh"; exit 1; }
source "${INSTALL_DIR}/nodejs.sh" 2>/dev/null || { error "Failed to load nodejs.sh"; exit 1; }

##############################################################################
# Interactive Menu
##############################################################################

show_menu() {
    clear
    separator
    echo "        Debian 12+ Server Environment Initialization"
    separator
    echo ""
    echo "  1) System Base Configuration (timezone, locale)"
    echo "  2) Common Tools (tmux, oh-my-zsh)"
    echo "  3) Docker + Docker Compose"
    echo "  4) Nginx Web Server"
    echo "  5) Node.js 22.x + PM2"
    echo "  6) Install All Components"
    echo ""
    echo "  q) Quit"
    separator
    echo -n "  Select option [1-6/q]: "
}

install_component() {
    case $1 in
        1)
            separator
            echo "Installing System Base Configuration..."
            separator
            install_system_config
            ;;
        2)
            separator
            echo "Installing Common Tools..."
            separator
            install_tools
            ;;
        3)
            separator
            echo "Installing Docker..."
            separator
            install_docker
            ;;
        4)
            separator
            echo "Installing Nginx..."
            separator
            install_nginx
            ;;
        5)
            separator
            echo "Installing Node.js and PM2..."
            separator
            install_nodejs
            ;;
        6)
            separator
            echo "Installing All Components..."
            separator
            install_all
            ;;
        q|Q)
            info "Exiting..."
            exit 0
            ;;
        *)
            error "Invalid option. Please try again."
            ;;
    esac
}

install_all() {
    install_system_config
    install_tools
    install_docker
    install_nginx
    install_nodejs

    separator
    success "All components installed successfully!"
    separator

    # Show versions
    info "Installation Summary:"
    echo ""
    [ -x "$(command -v docker)" ] && echo "  - Docker: $(docker --version)"
    [ -x "$(command -v nginx)" ] && echo "  - Nginx: $(nginx -v 2>&1)"
    [ -x "$(command -v node)" ] && echo "  - Node.js: $(node --version)"
    [ -x "$(command -v npm)" ] && echo "  - npm: $(npm --version)"
    [ -x "$(command -v pm2)" ] && echo "  - PM2: $(pm2 --version)"
    [ -x "$(command -v tmux)" ] && echo "  - tmux: $(tmux -V)"
    [ -x "$(command -v zsh)" ] && echo "  - zsh: $(zsh --version)"
    echo ""
}

##############################################################################
# Main
##############################################################################

# Parse command line arguments
for arg in "$@"; do
    case $arg in
        --yes|-y)
            AUTO_YES=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --yes, -y     Auto-confirm all prompts (non-interactive)"
            echo "  --help, -h    Show this help message"
            exit 0
            ;;
    esac
done

# Run system detection
detect_system

# Main loop
if [ "$AUTO_YES" = true ]; then
    info "Auto-confirm mode enabled, installing all components..."
    install_all
else
    while true; do
        show_menu
        read -r choice
        install_component "$choice"
        if [ "$choice" != "6" ]; then
            echo ""
            read -p "Press Enter to continue..."
        fi
    done
fi
