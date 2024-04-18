#!/bin/bash

RESET='\033[0m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'

LOG_FILE="/var/log/user_manager.log"
USERNAME_REGEX="^[a-zA-Z0-9_-]+$"
PASSWORD_REGEX="^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#%^&*()_+\-=\[\]{};:'\"\\|,.<>/?]).{8,}$"

log_event() {
    local message="$1"
    echo "$(date) - $message" >> "$LOG_FILE"
}

validate_username() {
    local username="$1"

    if [[ ! $username =~ $USERNAME_REGEX ]]; then
        echo -e "${RED}Invalid username. Use alphanumeric characters, underscores, or hyphens.${RESET}"
        return 1
    fi

    if id "$username" &>/dev/null; then
        echo -e "${RED}Username '$username' already exists.${RESET}"
        return 1
    fi

    return 0
}

validate_password() {
    local password="$1"

    if [[ ! $password =~ $PASSWORD_REGEX ]]; then
        echo -e "${RED}Invalid password. Must be at least 8 characters long with an uppercase letter, lowercase letter, number, and special character.${RESET}"
        return 1
    fi

    return 0
}

send_email() {
    local subject="$1"
    local recipient="$2"
    local body="$3"

    if ! command -v mail &>/dev/null; then
        echo -e "${RED}Command 'mail' not found. Please install it.${RESET}"
        return 1
    fi

    echo "$body" | mail -s "$subject" "$recipient"
}

add_user() {
    local username="$1"

    if ! validate_username "$username"; then
        return 1
    fi

    read -sp "Enter password: " password
    echo

    if ! validate_password "$password"; then
        return 1
    fi

    encrypted_password=$(openssl passwd -6 "$password")
    useradd -m -p "$encrypted_password" "$username"

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to create user '$username'.${RESET}"
        log_event "Failed to create user '$username'."
        return 1
    fi

    chown -R "$username":"$username" "/home/$username"

    log_event "User '$username' created."
    send_email "User '$username' created" "$username" "Your account has been created. Please change your password on first login."

    echo -e "${GREEN}User '$username' created successfully.${RESET}"
    return 0
}

delete_user() {
    echo -e "${BLUE}Current users:${RESET}"
    awk -F: '{print $1}' /etc/passwd | column

    read -p "Enter username to delete: " username

    if ! id "$username" &>/dev/null; then
        echo -e "${RED}User '$username' does not exist.${RESET}"
        return 1
    fi

    read -p "Are you sure you want to delete user '$username'? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo "Operation canceled."
        return 1
    fi

    userdel -r "$username"

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to delete user '$username'.${RESET}"
        log_event "Failed to delete user '$username'."
        return 1
    fi

    log_event "User '$username' deleted."
    echo -e "${GREEN}User '$username' deleted successfully.${RESET}"
    return 0
}

lock_user() {
    echo -e "${BLUE}Current users:${RESET}"
    awk -F: '{print $1}' /etc/passwd | column

    read -p "Enter username to lock: " username

    if ! id "$username" &>/dev/null; then
        echo -e "${RED}User '$username' does not exist.${RESET}"
        return 1
    fi

    read -p "Are you sure you want to lock user '$username'? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        echo "Operation canceled."
        return 1
    fi

    passwd -l "$username"

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to lock user '$username'.${RESET}"
        log_event "Failed to lock user '$username'."
        return 1
    fi

    log_event "User '$username' locked."
    echo -e "${GREEN}User '$username' locked successfully.${RESET}"
    return 0
}

update_password() {
    echo -e "${BLUE}Current users:${RESET}"
    awk -F: '{print $1}' /etc/passwd | column

    read -p "Enter username to update password: " username

    if ! id "$username" &>/dev/null; then
        echo -e "${RED}User '$username' does not exist.${RESET}"
        return 1
    fi

    read -sp "Enter new password: " new_password
    echo

    if ! validate_password "$new_password"; then
        return 1
    fi

    encrypted_password=$(openssl passwd -6 "$new_password")
    echo "$new_password" | passwd --stdin "$username"

    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to update password for user '$username'.${RESET}"
        log_event "Failed to update password for user '$username'."
        return 1
    fi

    log_event "Password for user '$username' updated."
    echo -e "${GREEN}Password for user '$username' updated successfully.${RESET}"
    return 0
}

main_menu() {
    while true; do
        echo -e "${YELLOW}------------------------------------${RESET}"
        echo -e "${YELLOW}User Management System${RESET}"
        echo -e "${YELLOW}------------------------------------${RESET}"
        echo "1. Add User"
        echo "2. Delete User"
        echo "3. Lock User"
        echo "4. Update Password"
        echo "5. Exit"
        echo -e "${YELLOW}------------------------------------${RESET}"
        read -p "Choose an option [1-5]: " option

        case "$option" in
            1)
                read -p "Enter username to add: " new_username
                add_user "$new_username"
                ;;
            2)
                delete_user
                ;;
            3)
                lock_user
                ;;
            4)
                update_password
                ;;
            5)
                echo -e "${YELLOW}Exiting.${RESET}"
                break
                ;;
            *)
                echo -e "${RED}Invalid option. Please try again.${RESET}"
                ;;
        esac
    done
}

main_menu
