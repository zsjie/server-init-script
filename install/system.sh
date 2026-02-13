#!/bin/bash

##############################################################################
# System Configuration Module
# - Update apt cache
# - Install basic tools
# - Configure timezone
# - Configure locale
##############################################################################

install_system_config() {
    info "Updating apt cache..."
    ${SUDO} apt-get update -qq

    # Install basic tools
    info "Installing basic tools..."
    ${SUDO} apt-get install -y \
        curl \
        git \
        wget \
        vim \
        ca-certificates \
        gnupg \
        lsb-release \
        software-properties-common \
        > /dev/null 2>&1
    success "Basic tools installed"

    # Configure timezone
    info "Configuring timezone to Asia/Shanghai..."
    ${SUDO} timedatectl set-timezone Asia/Shanghai 2>/dev/null || \
        echo "Asia/Shanghai" | ${SUDO} tee /etc/timezone > /dev/null && \
        ${SUDO} dpkg-reconfigure -f noninteractive tzdata > /dev/null 2>&1
    success "Timezone set to Asia/Shanghai"

    # Configure locale
    info "Configuring locale..."
    ${SUDO} apt-get install -y locales > /dev/null 2>&1
    ${SUDO} sed -i '/^#.*en_US.UTF-8/s/^#//' /etc/locale.gen
    ${SUDO} locale-gen en_US.UTF-8 > /dev/null 2>&1
    ${SUDO} update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 > /dev/null 2>&1
    success "Locale configured to en_US.UTF-8"

    separator
    success "System base configuration completed!"
    separator
}
