# Server Environment Initialization Script

A Debian 12+ server environment setup script with interactive menu for installing common development tools and services.

## Features

- System detection (Debian 12+ with version check)
- Root/sudo privilege detection
- Interactive menu for component selection
- Non-interactive mode with `--yes` flag

## Installable Components

1. **System Base Configuration**
   - Update apt cache
   - Install basic tools (curl, git, wget, vim)
   - Configure timezone (Asia/Shanghai)
   - Configure locale (en_US.UTF-8)

2. **Common Tools**
   - tmux terminal multiplexer
   - oh-my-zsh framework (non-interactive installation)
   - Set zsh as default shell

3. **Docker + Docker Compose**
   - Docker CE
   - Docker CLI
   - Containerd
   - Docker Compose plugin
   - Add current user to docker group

4. **Nginx**
   - Nginx web server
   - Auto-start and enable service
   - Basic configuration

5. **Node.js + PM2**
   - Node.js 22.x Current (via NodeSource)
   - PM2 process manager
   - PM2 startup configuration

## Usage

### Quick Start (One-liner)

Run directly on your server without downloading files:

```bash
# Interactive mode
curl -fsSL https://raw.githubusercontent.com/zsjie/server-init-script/main/init.sh | bash

# Non-interactive mode (install all components automatically)
curl -fsSL https://raw.githubusercontent.com/zsjie/server-init-script/main/init.sh | bash -s -- --yes
```

Or with wget:

```bash
# Interactive mode
wget -qO- https://raw.githubusercontent.com/zsjie/server-init-script/main/init.sh | bash

# Non-interactive mode
wget -qO- https://raw.githubusercontent.com/zsjie/server-init-script/main/init.sh | bash -s -- --yes
```

### Local Execution

Clone or download the repository first:

#### Interactive Mode

```bash
./init.sh
```

This will display a menu allowing you to select which components to install.

#### Non-Interactive Mode

```bash
./init.sh --yes
# or
./init.sh -y
```

This will automatically install all components without prompts.

## Requirements

- Debian 12 or higher
- Root privileges or sudo access
- Internet connection

## File Structure

```
server-init-script/
├── init.sh          # Main script entry point
├── install/         # Installation modules
│   ├── system.sh    # System detection and base configuration
│   ├── tools.sh     # Common tools (tmux, oh-my-zsh)
│   ├── docker.sh    # Docker installation
│   ├── nginx.sh     # Nginx installation
│   └── nodejs.sh    # Node.js and PM2 installation
└── README.md        # This file
```

## Verification

After installation, verify the installed services:

```bash
# Docker
docker --version
docker compose version

# Nginx
nginx -v
systemctl status nginx

# Node.js
node --version
npm --version

# PM2
pm2 --version

# Tools
tmux -V
zsh --version
```

## Notes

- All `apt` operations run with `-y` flag to avoid interactive prompts
- oh-my-zsh is installed with `RUNZSH=no` for non-interactive setup
- Changes to default shell require logout/login to take effect
- Docker group changes require logout/login to take effect
- For production use, review and customize configurations as needed

## Troubleshooting

### Permission Denied

If you get permission errors, ensure the script is executable:

```bash
chmod +x init.sh
chmod +x install/*.sh
```

### Docker Permission Denied After Installation

If you get permission errors running Docker, log out and log back in, or run:

```bash
newgrp docker
```

### Nginx Port Already in Use

If Nginx fails to start due to port conflicts, check which service is using port 80:

```bash
ss -tlnp | grep :80
```

## License

MIT
