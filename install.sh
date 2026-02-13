#!/bin/bash

##############################################################################
# Bootstrap Installation Script
# Downloads the repository and runs the main initialization script
##############################################################################

set -e

# Repository URL
REPO_URL="https://github.com/zsjie/server-init-script.git"
REPO_DIR="${HOME}/server-init-script"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1" >&2; }
info() { echo -e "${BLUE}ℹ${NC} $1"; }

echo ""
echo "========================================================================"
echo "          Server Environment Initialization - Bootstrap"
echo "========================================================================"
echo ""

# Check prerequisites
if ! command -v git &> /dev/null; then
    error "git is not installed."
    error "Please run the following command first:"
    echo ""
    echo "  apt update && apt install -y git curl"
    exit 1
fi

# Parse command line arguments
INSTALL_ARGS=""
for arg in "$@"; do
    case $arg in
        --yes|-y)
            INSTALL_ARGS="--yes"
            ;;
    esac
done

# Clone or update the repository
if [ -d "${REPO_DIR}" ]; then
    info "Updating existing repository..."
    cd "${REPO_DIR}"
    git pull --ff-only > /dev/null 2>&1 || {
        warn "Could not update, removing and re-cloning..."
        cd "${HOME}"
        rm -rf "${REPO_DIR}"
        git clone "${REPO_URL}" "${REPO_DIR}"
    }
    success "Repository updated"
else
    info "Cloning repository..."
    git clone "${REPO_URL}" "${REPO_DIR}"
    success "Repository cloned"
fi

# Run the main script
echo ""
info "Starting installation..."
echo ""

cd "${REPO_DIR}"
chmod +x init.sh

if [ -n "$INSTALL_ARGS" ]; then
    ./init.sh $INSTALL_ARGS
else
    ./init.sh
fi
