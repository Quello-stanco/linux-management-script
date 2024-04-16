### Advanced Data Backup: Creates backups of important data with retention management for older versions.
### Automated Maintenance: Cleans up old temporary files and restarts critical services.
### System Monitoring: Checks disk and memory usage and sends notifications via email or Slack if thresholds are exceeded.
### Automatic System Updates: Automatically updates system packages and reports any errors.
### Detailed System Reporting: Generates comprehensive reports on system status, including resource usage and top resource-consuming processes.

# **Usage Notes:**

### Configuration: Before running the script, ensure you customize the configuration file (config.file) with your own settings such as BACKUP_PATH, ADMIN_EMAIL, WARNING_THRESHOLD, and other variables.
### Execution: You can run the script by invoking it directly from the command line.
### Testing: It is recommended to test the script in a safe environment before using it in production to ensure it works correctly.
### Compatibility: The script is expected to work on modern Linux distributions that support Bash.
### Usage Examples:
### Backup: Schedule the script to run periodically (e.g., daily) to perform backups of important data.
### Maintenance: The script can regularly clean up temporary files and restart critical services to ensure system stability.
### Monitoring: The script continuously monitors disk and memory usage, sending alerts if thresholds are exceeded.
### Updates: Schedule the script to run periodically for automatic system package updates.
### Reporting: The script provides comprehensive reports on system status that can be shared with administrators or support teams.
