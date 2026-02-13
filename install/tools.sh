#!/bin/bash

##############################################################################
# Common Tools Module
# - Install tmux
# - Install oh-my-zsh (non-interactive)
# - Set zsh as default shell
##############################################################################

install_tools() {
    # Ensure apt cache is updated
    ${SUDO} apt-get update -qq > /dev/null 2>&1

    # Install tmux
    info "Installing tmux..."
    ${SUDO} apt-get install -y tmux > /dev/null 2>&1
    success "tmux installed: $(tmux -V)"

    # Install zsh
    info "Installing zsh..."
    ${SUDO} apt-get install -y zsh > /dev/null 2>&1
    success "zsh installed"

    # Install oh-my-zsh non-interactively
    info "Installing oh-my-zsh..."
    if [ ! -d "${HOME}/.oh-my-zsh" ]; then
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null 2>&1 || \
        RUNZSH=no CHSH=no sh -c "$(wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null 2>&1
        success "oh-my-zsh installed"
    else
        warn "oh-my-zsh already installed, skipping..."
    fi

    # Set zsh as default shell for the current user
    if [ "$(basename "${SHELL}")" != "zsh" ]; then
        info "Setting zsh as default shell..."
        ${SUDO} chsh -s "$(command -v zsh)" "$(whoami)" 2>/dev/null || \
            chsh -s "$(command -v zsh)" 2>/dev/null || \
            warn "Could not change default shell (please run: chsh -s \$(which zsh))"
        success "zsh set as default shell (changes apply on next login)"
    else
        success "zsh is already the default shell"
    fi

    # For root user, also set zsh as default
    if [ "$(id -u)" -ne 0 ] && [ -n "${SUDO}" ]; then
        if ${SUDO} [ "$(basename "${SHELL}")" != "zsh" ]; then
            info "Setting zsh as default shell for root..."
            ${SUDO} chsh -s "$(command -v zsh)" root 2>/dev/null || true
        fi
    fi

    separator
    success "Common tools installation completed!"
    separator
}
