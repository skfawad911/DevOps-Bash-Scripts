# Linux Server Security Audit and Hardening Script

## Overview

This script automates the security audit and hardening process of Linux servers. It is designed to be modular, allowing for easy deployment across multiple servers to ensure they meet stringent security standards. The script checks for common security vulnerabilities, implements hardening measures, and provides a detailed report of the findings.

## Features

- **User and Group Audits**: Identifies users with root privileges, checks for weak passwords, and lists all users and groups.
- **File and Directory Permissions**: Scans for insecure file permissions, especially on `.ssh` directories and executables with SUID/SGID bits set.
- **Service Audits**: Verifies the status of critical services and checks for unauthorized services.
- **Firewall and Network Security**: Ensures firewall rules are properly configured and checks for insecure network configurations.
- **IP and Network Configuration Checks**: Differentiates between public and private IP addresses and ensures that sensitive services are not exposed on public IPs.
- **Security Updates and Patching**: Reports available security updates and configures automatic updates.
- **Server Hardening Steps**: Implements measures such as SSH hardening, disabling IPv6 (if not required), securing the bootloader, and configuring automatic updates.
- **Custom Security Checks**: Easily extendable with custom checks and hardening steps.
- **Reporting and Alerting**: Generates detailed reports and can send email alerts if critical vulnerabilities are found.

## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/skfawad911/DevOps-Bash-Scripts.git
   cd security-audit-script


2. Make the Script Executable:
```
chmod +x security_audit.sh
```
3. Install Required Packages: Ensure you have the necessary packages installed. You can install them using apt or yum depending on your distribution.
```
sudo apt-get install -y curl wget net-tools
```

## Configurations

The script is highly configurable via the security_audit.conf file. This file allows you to customize security checks, hardening measures, firewall rules, and more.

1. Edit the Configuration File:
```bash
nano security_audit.conf
```
2. Configure General Settings:

- Enable or disable email alerts.
- Specify recipient email address for alerts.
- Choose whether to disable IPv6.
Example:
``` 
EMAIL_ALERTS="true"
EMAIL_RECIPIENT="admin@example.com"
DISABLE_IPV6="true"
```
3. Customize Critical Services:

Add or remove services that should be monitored.
Example:
```
 
CRITICAL_SERVICES=("sshd" "iptables" "ufw" "fail2ban")
```
4. Define Custom Firewall Rules:

Add your own firewall rules in the FIREWALL_RULES array.
Example:
```
 
FIREWALL_RULES=(
    "iptables -A INPUT -p tcp --dport 80 -j ACCEPT"  # Allow HTTP
    "iptables -A INPUT -p tcp --dport 443 -j ACCEPT" # Allow HTTPS
)
```
5. Add Custom Security Checks and Hardening Measures:

Define your own checks or hardening steps.
Example:
```
 
custom_check_ssh_ciphers() {
    log "Checking for weak SSH ciphers and MACs..."
    if grep -E "Ciphers.*(arcfour|cbc)" /etc/ssh/sshd_config; then
        log "Warning: Weak SSH ciphers detected!"
    fi
}
```
## Usage

Run the script with the following command:
```
./security_audit.sh
```
### Running Specific Checks or Hardening Steps
You can run specific modules of the script using command-line switches:

- Run Full Audit:
```
./security_audit.sh --full-audit
```
- Check Users and Groups:

```
./security_audit.sh --check-users
```
- Check File Permissions:
```
./security_audit.sh --check-permissions
```
- Run Custom Security Checks:

```
./security_audit.sh --custom-checks
```

### Generating Reports
After running the script, a detailed report will be generated and saved in the reports/ directory. The report will include all findings and any actions taken during the hardening process.

### Email Alerts
If email alerts are enabled in the security_audit.conf file, the script will send a summary of the audit and hardening results to the specified email address.
## Limitations

- The script is primarily designed for Debian-based distributions (e.g., Ubuntu). Some features may require adjustments for other distributions (e.g., CentOS, Red Hat).
- The script assumes that iptables or ufw is used as the firewall. Custom firewall solutions may require additional configuration.
- IPv6 hardening is limited to disabling IPv6 entirely if not needed. If your environment requires specific IPv6 configurations, additional customization may be necessary.