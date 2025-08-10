# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a NixOS configuration repository for a homelab setup with the following architecture:

- **Flake-based configuration**: Uses `flake.nix` as the entry point with inputs for nixpkgs, agenix (secrets), disko (disk partitioning), and a private secrets repository
- **Host configuration**: Currently supports one host called "ipanema" located in `hosts/ipanema/`
- **Homelab services**: Container-based services managed through systemd and Podman, defined in `homelab/services/`
- **User configurations**: User-specific settings in `users/lazycat/`
- **Secrets management**: Uses agenix for encrypted secrets stored in `secrets/`

## Common Commands

The repository uses Just as a task runner. Available commands from `justfile`:

### Development and Deployment
- `just update` - Update flake inputs
- `just check` - Validate flake configuration
- `just dry-run <host>` - Preview changes without applying them
- `just deploy <host>` - Deploy configuration to specified host
- `just copy <host>` - Sync repository to remote host

### System Management
- `nixos-rebuild switch --flake .#<hostname>` - Apply configuration locally
- `nix flake update` - Update all flake inputs
- `nix flake check` - Validate flake structure and dependencies

### Useful NixOS Commands
- `sudo nix-env --delete-generations +5 --profile /nix/var/nix/profiles/system` - Keep only last 5 system generations
- `journalctl -fu podman-<service>.service --since yesterday` - Check container service logs
- `systemctl start cryptsetup.target` - Start encrypted disk services

## Architecture

### Host Structure
- `hosts/common/` - Shared configuration across hosts
- `hosts/<hostname>/` - Host-specific configuration including:
  - `default.nix` - Main host configuration
  - `disko.nix` - Disk partitioning configuration
  - `homelab/` - Host-specific homelab overrides
  - `secrets/` - Host-specific secrets
  - `assets/` - Static assets (fonts, icons, images) served by Caddy

### Homelab Services
The homelab module (`homelab/default.nix`) provides:
- **Options system**: Configurable base domain, timezone, credentials
- **Service management**: Container orchestration via Podman
- **Reverse proxy**: Caddy with automatic ACME/Let's Encrypt certificates
- **Asset serving**: Static file serving with caching headers

Current services in `homelab/services/`:
- **AdGuard Home**: DNS filtering and ad blocking
- **AdGuard Home Sync**: Synchronization between AdGuard instances  
- **Calibre Web**: Web-based ebook library interface
- **Homepage**: Dashboard for homelab services

### Network Configuration
- Uses systemd-networkd for network management
- MACVLAN setup for AdGuard Home to have dedicated IP
- Firewall configuration per interface
- SSH access with key-based authentication only

### Security Features
- Encrypted secrets via agenix
- Automatic security updates enabled
- SSH hardening (no password auth, no root login)
- DNS over TLS configuration
- ACME certificates with DNS challenge via IONOS

## File Organization

```
├── flake.nix              # Main flake configuration
├── justfile              # Task runner commands
├── hosts/
│   ├── common/           # Shared host configuration
│   └── ipanema/         # Host-specific configuration
├── homelab/             # Homelab services and configuration
│   └── services/        # Individual service definitions
├── users/               # User-specific configurations
└── secrets/             # Encrypted secrets (agenix)
```

## Development Workflow

1. Make configuration changes locally
2. Test with `just dry-run <host>` to preview changes
3. Deploy with `just deploy <host>` to apply changes
4. Check services with systemd/journalctl commands as needed

## Important Notes

- The repository uses a private secrets repository for sensitive data
- Host "ipanema" is configured with static IP 10.55.66.21/24
- Services run in Podman containers with systemd integration
- Automatic updates are scheduled for Saturdays at 06:00 with randomized delay
- Garbage collection runs weekly, keeping 30 days of history