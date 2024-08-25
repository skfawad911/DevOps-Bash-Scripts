#!/bin/bash
######################################################
##
## Author: Fawad
## Date: 24-08-2024
## Work: Monitoring System Resources for a Proxy Server
## Usage: ./monitor.sh [OPTIONS]
##
######################################################

# Configuration: Customize these variables to tweak the behavior of the script
REFRESH_INTERVAL=5      # Time in seconds between updates
MAX_RETRIES=3           # Maximum number of retries for a command

# Function to handle errors gracefully
handle_error() {
    local exit_code=$?
    local message=$1
    if [ $exit_code -ne 0 ]; then
        echo "Error: $message. Exiting."
        exit $exit_code
    fi
}

# Top 10 Most Used Applications
top_apps() {
    echo "Top 10 Applications by CPU Usage:"
    ps aux --sort=-%cpu | head -n 11 || handle_error "Failed to retrieve top applications by CPU usage"

    echo -e "\nTop 10 Applications by Memory Usage:"
    ps aux --sort=-%mem | head -n 11 || handle_error "Failed to retrieve top applications by memory usage"
}

# Network Monitoring
network_monitoring() {
    echo "Network Monitoring:"
    echo "Concurrent Connections:"
    netstat -an | grep ESTABLISHED | wc -l || handle_error "Failed to count concurrent connections"

    echo -e "\nPacket Drops:"
    netstat -i | awk '{if ($5 != 0) print $1, "drop:", $5}' || handle_error "Failed to retrieve packet drop information"

    echo -e "\nNetwork Traffic (MB In/Out):"
    ifconfig | awk '/RX bytes/ {rx_sum += $2; tx_sum += $6} END {print "MB In:", rx_sum/1024/1024, "MB Out:", tx_sum/1024/1024}' || handle_error "Failed to retrieve network traffic data"
}

# Disk Usage
disk_usage() {
    echo "Disk Usage:"
    df -h | awk '$5 >= 80 {print "ALERT:", $0} $5 < 80 {print $0}' || handle_error "Failed to retrieve disk usage information"
}

# System Load
system_load() {
    echo "System Load:"
    uptime || handle_error "Failed to retrieve system load"

    echo -e "\nCPU Usage Breakdown:"
    mpstat | grep -A 5 "%idle" | tail -n 5 || handle_error "Failed to retrieve CPU usage breakdown"
}

# Memory Usage
memory_usage() {
    echo "Memory Usage:"
    free -h || handle_error "Failed to retrieve memory usage"

    echo -e "\nSwap Usage:"
    swapon --show || handle_error "Failed to retrieve swap usage"
}

# Process Monitoring
process_monitoring() {
    echo "Process Monitoring:"
    echo "Number of Active Processes:"
    ps -e --no-headers | wc -l || handle_error "Failed to count active processes"

    echo -e "\nTop 5 Processes by CPU Usage:"
    ps aux --sort=-%cpu | head -n 6 || handle_error "Failed to retrieve top processes by CPU usage"

    echo -e "\nTop 5 Processes by Memory Usage:"
    ps aux --sort=-%mem | head -n 6 || handle_error "Failed to retrieve top processes by memory usage"
}

# Service Monitoring
service_monitoring() {
    echo "Service Monitoring:"
    services=(sshd nginx iptables)
    for service in "${services[@]}"; do
        if systemctl is-active --quiet $service; then
            echo "$service is running"
        else
            echo "$service is not running"
        fi
    done || handle_error "Failed to check service statuses"
}

# Function to display usage/help
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -all        Show the entire dashboard"
    echo "  -cpu        Show top applications by CPU and memory usage"
    echo "  -network    Show network monitoring"
    echo "  -disk       Show disk usage"
    echo "  -load       Show system load"
    echo "  -memory     Show memory usage"
    echo "  -process    Show process monitoring"
    echo "  -service    Show service monitoring"
    echo "  -help       Show this help message"
}

# Function to update dashboard
update_dashboard() {
    clear
    case "$1" in
        -all)
            top_apps
            network_monitoring
            disk_usage
            system_load
            memory_usage
            process_monitoring
            service_monitoring
            ;;
        -cpu) top_apps ;;
        -network) network_monitoring ;;
        -disk) disk_usage ;;
        -load) system_load ;;
        -memory) memory_usage ;;
        -process) process_monitoring ;;
        -service) service_monitoring ;;
        -help|*) show_help ;;
    esac
}

# Main loop to refresh dashboard every few seconds
main() {
    if [ $# -eq 0 ]; then
        echo "No options provided. Use -help for usage information."
        exit 1
    fi

    while true; do
        update_dashboard "$1"
        sleep $REFRESH_INTERVAL
    done
}

# Run the script with the provided command-line option
main "$@"

