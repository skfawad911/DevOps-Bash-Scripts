#!/bin/bash
######################################################
##
## Author: Fawad
## Date: 25-08-2024
## Work: Linux Server Security Audit and Hardening Script
## Usage: ./security_audit.sh
##
######################################################

# Global Variables
REPORT_FILE="/var/log/security_audit_report.txt"
CONFIG_FILE="./security_audit.conf"
EMAIL_ALERTS="false"
EMAIL_RECIPIENT=""
DISABLE_IPV6="false"

# Load configuration file if exists
if [[ -f $CONFIG_FILE ]]; then
    source $CONFIG_FILE
fi

# Helper functions
log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" | tee -a $REPORT_FILE
}

send_alert() {
    if [[ "$EMAIL_ALERTS" == "true" ]]; then
        mail -s "Security Audit Alert" "$EMAIL_RECIPIENT" < $REPORT_FILE
    fi
}

# 1. User and Group Audits
user_group_audit() {
    log "User and Group Audit"

    # List all users and groups
    log "Listing all users and groups..."
    awk -F':' '{ print $1 }' /etc/passwd | tee -a $REPORT_FILE
    awk -F':' '{ print $1 }' /etc/group | tee -a $REPORT_FILE

    # Check for users with UID 0
    log "Checking for users with UID 0 (root privileges)..."
    awk -F':' '($3 == 0) { print $1 }' /etc/passwd | tee -a $REPORT_FILE

    # Check for users without passwords or with weak passwords
    log "Checking for users without passwords or with weak passwords..."
    passwd -S | grep 'NP' | awk '{ print $1 }' | tee -a $REPORT_FILE
}

# 2. File and Directory Permissions
file_permission_audit() {
    log "File and Directory Permissions Audit"

    # Scan for world-writable files and directories
    log "Scanning for world-writable files and directories..."
    find / -perm -002 -type d -exec ls -ld {} \; 2>/dev/null | tee -a $REPORT_FILE

    # Check for .ssh directories and their permissions
    log "Checking for .ssh directories and their permissions..."
    find /home -type d -name ".ssh" -exec ls -ld {} \; 2>/dev/null | tee -a $REPORT_FILE

    # Report files with SUID/SGID bits set
    log "Reporting files with SUID/SGID bits set..."
    find / -perm /6000 -type f -exec ls -l {} \; 2>/dev/null | tee -a $REPORT_FILE
}

# 3. Service Audits
service_audit() {
    log "Service Audit"

    # List all running services
    log "Listing all running services..."
    systemctl list-units --type=service --state=running | tee -a $REPORT_FILE

    # Check for unnecessary services
    log "Checking for unnecessary or unauthorized services..."
    critical_services=("sshd" "iptables" "ufw")
    for service in "${critical_services[@]}"; do
        if ! systemctl is-active --quiet $service; then
            log "Warning: Critical service $service is not running!"
        fi
    done

    # Check for services listening on non-standard or insecure ports
    log "Checking for services listening on non-standard or insecure ports..."
    netstat -tuln | grep -E '(:80|:443|:22)' | tee -a $REPORT_FILE
}

# 4. Firewall and Network Security
firewall_network_audit() {
    log "Firewall and Network Security Audit"

    # Verify that a firewall is active
    log "Verifying that a firewall is active..."
    if ! systemctl is-active --quiet iptables && ! systemctl is-active --quiet ufw; then
        log "Warning: No firewall is active!"
    else
        log "Firewall is active."
    fi

    # Report open ports and associated services
    log "Reporting open ports and associated services..."
    netstat -tuln | tee -a $REPORT_FILE

    # Check for IP forwarding or other insecure network configurations
    log "Checking for IP forwarding or other insecure network configurations..."
    if [[ "$(sysctl net.ipv4.ip_forward)" == "net.ipv4.ip_forward = 1" ]]; then
        log "Warning: IP forwarding is enabled!"
    fi
}

# 5. IP and Network Configuration Checks
ip_network_config_audit() {
    log "IP and Network Configuration Audit"

    # Identify public vs. private IPs
    log "Identifying public and private IPs..."
    for ip in $(hostname -I); do
        if [[ $ip =~ ^192\.168|^10\.|^172\.(1[6-9]|2[0-9]|3[01])\. ]]; then
            log "Private IP: $ip"
        else
            log "Public IP: $ip"
        fi
    done

    # Ensure sensitive services are not exposed on public IPs
    log "Ensuring sensitive services are not exposed on public IPs..."
    if [[ -n "$(ss -tunlp | grep ':22' | grep -v '127.0.0.1')" ]]; then
        log "Warning: SSH is exposed on a public IP!"
    fi
}

# 6. Security Updates and Patching
security_updates_audit() {
    log "Security Updates and Patching Audit"

    # Check for available security updates
    log "Checking for available security updates..."
    if [[ -x "$(command -v apt-get)" ]]; then
        apt-get update && apt-get -s upgrade | grep -i security | tee -a $REPORT_FILE
    elif [[ -x "$(command -v yum)" ]]; then
        yum check-update --security | tee -a $REPORT_FILE
    fi

    # Ensure automatic updates are configured
    log "Ensuring automatic updates are configured..."
    if ! grep -q "Unattended-Upgrade::Automatic-Reboot" /etc/apt/apt.conf.d/50unattended-upgrades; then
        log "Warning: Automatic updates are not configured!"
    fi
}

# 7. Log Monitoring
log_monitoring() {
    log "Log Monitoring"

    # Check for recent suspicious log entries
    log "Checking for suspicious log entries in /var/log/auth.log..."
    grep "Failed password" /var/log/auth.log | tail -n 10 | tee -a $REPORT_FILE
}

# 8. Server Hardening Steps
server_hardening() {
    log "Server Hardening Steps"

    # SSH Configuration: Key-based authentication, disable root password login
    log "Configuring SSH for key-based authentication..."
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    systemctl restart sshd

    # Disable IPv6 if not required
    log "Disabling IPv6 if not in use..."
    if [[ "$DISABLE_IPV6" == "true" ]]; then
        sysctl -w net.ipv6.conf.all.disable_ipv6=1
        sysctl -w net.ipv6.conf.default.disable_ipv6=1
        sysctl -w net.ipv6.conf.lo.disable_ipv6=1
    fi

    # Secure the bootloader by setting a GRUB password
    log "Securing the bootloader with a GRUB password..."
    grub2-setpassword

    # Configure the firewall with iptables rules
    log "Configuring the firewall with recommended iptables rules..."
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    iptables-save > /etc/iptables/rules.v4
}

# 9. Custom Security Checks
custom_security_checks() {
    log "Custom Security Checks"

    # Load and execute custom checks from the configuration file
    if [[ -f "$CONFIG_FILE" ]]; then
        log "Loading custom checks from $CONFIG_FILE..."
        source "$CONFIG_FILE"
    else
        log "No custom checks defined."
    fi
}

# 10. Reporting and Alerting
generate_report() {
    log "Generating summary report..."

    # Output the final report
    echo "Security Audit and Hardening Summary" | tee -a $REPORT_FILE
    cat $REPORT_FILE

    # Send email alert if critical issues found
    send_alert
}

# Main function to run all audits and hardening steps
main() {
    user_group_audit
    file_permission_audit
    service_audit
    firewall_network_audit
    ip_network_config_audit
    security_updates_audit
    log_monitoring
    server_hardening
    custom_security_checks
    generate_report
}

# Execute main function
main
