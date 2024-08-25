
# System Monitoring Dashboard Script



## Overview

Welcome to the System Monitoring Dashboard Script repository! This script is designed to provide real-time monitoring of various system resources in a dashboard format. It is highly customizable, efficient, and built with robust error handling to ensure seamless performance even in demanding environments.

This script was developed as part of an interview assignment, and it reflects my dedication to creating high-quality, reliable, and maintainable solutions.


## Features

- Real-Time Monitoring: Provides real-time updates of system resources, refreshed every few seconds.
- Modular Design: Allows users to view specific sections of the dashboard independently through command-line switches.
- Top Applications Monitoring: Displays the top 10 CPU and memory-consuming applications.
- Network Monitoring: Includes metrics for concurrent connections, packet drops, and network traffic (MB in/out).
- Disk Usage: Displays disk space usage for mounted partitions, highlighting those over 80% usage.
- System Load: Shows current load average and provides a detailed breakdown of CPU usage.
- Memory Usage: Provides insights into total, used, and free memory, including swap usage.
- Process Monitoring: Displays the number of active processes and highlights the top 5 processes by CPU and memory usage.
- Service Monitoring: Monitors the status of essential services like sshd, nginx/apache, and iptables.
- Error Handling: Ensures the script fails gracefully with meaningful error messages.


## Installation

1. Clone the Repository:
```
git clone https://github.com/skfawad911/DevOps-Bash-Scripts.git
cd system-monitoring-dashboard
```

2. Make the Script Executable:
```
chmod +x monitor.sh
```

3. Run the Script:
```
./monitor.sh [OPTIONS]
```


## Usage/Examples

The script can be used to monitor all system resources at once or individual sections based on your needs. Below are the available options:

### Monitor All System Resources
```
./monitor.sh -all
```
This option displays the entire dashboard, updating every few seconds with real-time data.

### Monitor Specific System Resources
You can monitor specific parts of the system by passing the relevant command-line switch:

1. Top Applications:
```
./monitor.sh -cpu
```
2. Network Monitoring:
 ```
./monitor.sh -network
```
3. Disk Usage:
```
./monitor.sh -disk
```
4. System Load:

 ```
./monitor.sh -load
```
5. Memory Usage:
```
 
./monitor.sh -memory
```
6. Process Monitoring:

 ```
./monitor.sh -process
```
7. Service Monitoring:

 ```
./monitor.sh -service
```
8. Help/Usage:

 ```
./monitor.sh -help
```

### Customizations

- Refresh Interval: You can modify the REFRESH_INTERVAL variable at the top of the script to change the time between updates.
```
REFRESH_INTERVAL=5  # Default is 5 seconds
```
- Service List: You can add or remove services in the services array within the service_monitoring function to monitor different services.
```
services=(sshd nginx iptables)  # Modify this array as needed
```


## Limitations

While this script provides comprehensive monitoring capabilities, there are a few limitations:

- Resource Usage: Since the script runs continuously with frequent updates, it may consume noticeable CPU and memory resources, especially on systems with limited capacity.
- Network-Specific Monitoring: This script does not currently support detailed network traffic analysis beyond basic packet drops and data transfer metrics.
- Service Monitoring: The script checks if services are running, but it doesn't provide detailed logs or error diagnostics for the services being monitored.
## Potential Enhancements

To further improve this script, the following enhancements could be considered:

- Alerting System: Implementing an alerting mechanism that notifies users via email or messaging when certain thresholds (e.g., CPU usage over 90%, disk usage over 80%) are breached.
- Integration with Monitoring Tools: Adding compatibility with monitoring tools like Prometheus or Grafana for more advanced data visualization and alerting.
- Detailed Network Monitoring: Integrating tools like iftop or nload to provide a more detailed analysis of network traffic.
- Historical Data Logging: Implementing a logging system to keep historical data that could be analyzed for trends or issues over time.


## Conclusion

This System Monitoring Dashboard Script is designed to provide a comprehensive, real-time overview of your server's performance. Its modular design, error handling, and efficiency make it a valuable tool for any DevOps engineer or system administrator.

Whether you need a quick snapshot of your system's health or detailed insights into specific metrics, this script has you covered.
