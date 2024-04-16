#!/bin/bash

# Description: Advanced Bash script for system administration tasks:
# - Advanced data backup with retention management
# - Automated maintenance with cleanup and service restart
# - System monitoring with multi-channel notifications
# - Automatic system updates
# - Detailed system reporting
# - Logging for better auditing and error tracking

# Load configuration from external file
source /path/to/your/config.file

# Variables
LOG_FILE="/var/log/sysadmin_script.log"
BACKUP_RETENTION_DAYS=7
BACKUP_PATH="/backup"
DATA_TO_BACKUP="/var/www/html /etc /home"
WARNING_THRESHOLD=80
ADMIN_EMAIL="admin@example.com"
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/your/slack/webhook"

# Function to create a timestamp
create_timestamp() {
    date +'%Y%m%d%H%M'
}

# Function for advanced data backup with retention management
backup_data() {
    echo "$(date): Starting data backup..." | tee -a "$LOG_FILE"
    backup_file="$BACKUP_PATH/backup_$(create_timestamp).tar.gz"
    tar -czf "$backup_file" $DATA_TO_BACKUP
    if [ $? -eq 0 ]; then
        echo "$(date): Data backup completed: $backup_file" | tee -a "$LOG_FILE"
        manage_backup_retention
    else:
        echo "$(date): Data backup failed!" | tee -a "$LOG_FILE"
        send_notification "Backup Error" "Data backup failed on $(hostname)"
    fi
}

# Function to manage backup retention
manage_backup_retention() {
    echo "$(date): Managing backup retention..." | tee -a "$LOG_FILE"
    find "$BACKUP_PATH" -name "*.tar.gz" -mtime +$BACKUP_RETENTION_DAYS -exec rm -f {} \;
    echo "$(date): Backup retention managed." | tee -a "$LOG_FILE"
}

# Automated maintenance function
automate_maintenance() {
    echo "$(date): Automating maintenance tasks..." | tee -a "$LOG_FILE"
    # Cleanup temporary files older than 30 days
    find /tmp -type f -mtime +30 -exec rm -f {} \;
    echo "$(date): Cleaned up temporary files older than 30 days." | tee -a "$LOG_FILE"
    # Restart critical services
    for service in "${SERVICES_TO_RESTART[@]}"; do
        sudo systemctl restart "$service"
        echo "$(date): Restarted service: $service" | tee -a "$LOG_FILE"
    done
}

# System monitoring function with multi-channel notifications
monitor_system() {
    echo "$(date): Monitoring system..." | tee -a "$LOG_FILE"
    check_disk_usage
    check_memory_usage
    echo "$(date): System monitoring completed." | tee -a "$LOG_FILE"
}

# Function to check disk usage and send notifications if needed
check_disk_usage() {
    disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt "$WARNING_THRESHOLD" ]; then
        echo "$(date): Warning: Disk usage is over $WARNING_THRESHOLD%!" | tee -a "$LOG_FILE"
        send_notification "Disk Usage Alert" "Disk usage on $(hostname) is $disk_usage%."
    fi
}

# Function to check memory usage and send notifications if needed
check_memory_usage() {
    memory_usage=$(free | grep Mem | awk '{print ($3/$2) * 100.0}')
    if (( $(echo "$memory_usage > $WARNING_THRESHOLD" | bc -l) )); then
        echo "$(date): Warning: Memory usage is over $WARNING_THRESHOLD%!" | tee -a "$LOG_FILE"
        send_notification "Memory Usage Alert" "Memory usage on $(hostname) is $memory_usage%."
    fi
}

# Automatic system update function
auto_update_system() {
    echo "$(date): Updating system packages..." | tee -a "$LOG_FILE"
    # Update system packages
    sudo yum update -y
    if [ $? -eq 0 ]; then
        echo "$(date): System packages updated." | tee -a "$LOG_FILE"
    else:
        echo "$(date): System package update failed!" | tee -a "$LOG_FILE"
        send_notification "Update Error" "System package update failed on $(hostname)"
    fi
}

# Detailed system reporting function
generate_report() {
    echo "$(date): Generating system report..." | tee -a "$LOG_FILE"
    report_file="$BACKUP_PATH/system_report_$(date +'%Y%m%d').txt"
    {
        echo "Hostname: $(hostname)"
        echo "Date: $(date)"
        echo "Uptime: $(uptime)"
        echo "Disk Usage:"
        df -h
        echo "Memory Usage:"
        free -h
        echo "Top 10 Processes by CPU Usage:"
        ps aux --sort=-%cpu | head -10
        echo "Top 10 Processes by Memory Usage:"
        ps aux --sort=-%mem | head -10
    } > "$report_file"
    echo "$(date): System report saved to: $report_file" | tee -a "$LOG_FILE"
}

# Function to send multi-channel notifications (email and Slack)
send_notification() {
    subject=$1
    body=$2
    if [ "$NOTIFICATION_METHOD" == "email" ]; then
        echo "$body" | mail -s "$subject" "$ADMIN_EMAIL"
    elif [ "$NOTIFICATION_METHOD" == "slack" ]; then
        # Use Slack API to send message to a channel
        curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$body\"}" "$SLACK_WEBHOOK_URL"
    fi
}

# Run all functions
backup_data
automate_maintenance
monitor_system
auto_update_system
generate_report

echo "$(date): All tasks completed." | tee -a "$LOG_FILE"
