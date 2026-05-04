# Guided System Configuration Tool

A modular, interactive TUI (Terminal User Interface) built with Bash and `whiptail` designed for automated Linux server initialization.

## Features
*   **Hostname Management:** RFC 1123 compliant validation and persistence.
*   **Network Orchestration:** Supports DHCP and Static IP configuration via Netplan with a 120-second safety rollback timer.
*   **DNS Configuration:** Multi-server support with automated YAML injection.
*   **Web Stack Deployment:** Automated installation of Nginx or Apache with real-time progress tracking.
*   **Secure TLS:** Automated 2048-bit RSA self-signed certificate generation and web server integration.

## Technical Requirements
*   **OS:** Ubuntu 22.04+ (or any distro using Netplan/Systemd).
*   **Privileges:** Must be run as `root`.
*   **Dependencies:** `whiptail`, `openssl`, `iproute2`, `netplan.io`.

## Project Structure
```text
.
├── configure.sh       # Main entry point (C-style logic)
├── lib/
│   ├── hostname.sh    # Hostname logic & /etc/hosts manipulation
│   ├── network.sh     # Netplan YAML generation & rollback logic
│   ├── dns.sh         # DNS validation & injection
│   ├── webserver.sh   # Package management & whiptail gauge
│   └── tls.sh         # OpenSSL orchestration & vhost config
└── README.md          # Documentation
Usage
Clone the repository.

Ensure the script and library files are executable:

Bash
chmod +x configure.sh lib/*.sh
Execute the tool:

Bash
sudo ./configure.sh
Interface Preview (ASCII)
Main Menu
Plaintext
┌─────────────────────────── Server Setup v1.0 ────────────────────────────┐
│ Select a configuration step:                                             │
│                                                                          │
│  1 Set System Hostname                                                   │
│  2 Configure IP Address (Netplan)                                        │
│  3 Configure DNS Servers                                                 │
│  4 Install Web Server (Nginx/Apache)                                     │
│  5 Generate Self-Signed TLS Certificate                                  │
│  6 Exit                                                                  │
│                                                                          │
│                  <Ok>                      <Cancel>                      │
└──────────────────────────────────────────────────────────────────────────┘
Installation Progress
Plaintext
┌─────────────────────────── Server Setup v1.0 ────────────────────────────┐
│ Installing nginx...                                                      │
│                                                                          │
│ ######################################## 80%                             │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
Engineering Design Decisions
POSIX Compliance: The script utilizes POSIX-standard sed, awk, and grep for string manipulation to ensure portability across environments.

Atomic Operations: Network changes utilize netplan try, ensuring that connectivity is restored automatically if the configuration is invalid or the operator is disconnected.

Re-entrancy: Logic uses idempotent sed filters to ensure that multiple executions update existing configuration lines rather than duplicating them.

Validation: All user inputs are passed through regex filters (e.g., IPv4 octet validation) before being committed to system files.

Standards
Passes shellcheck with zero warnings.

Uses set -euo pipefail for strict error handling.
