#!/bin/bash

# Function to prompt for user input
prompt_for_input() {
    local prompt="$1"
    local variable_name="$2"
    local default_value="$3"
    local input

    while true; do
        printf "%s [%s]: " "$prompt" "$default_value"
        read input
        # Use default value if input is empty
        input="${input:-$default_value}"
        if [[ -z "$input" ]]; then
            printf "Input cannot be empty. Please provide a valid input.\n" >&2
        else
            eval "$variable_name='$input'"
            break
        fi
    done
}

# Function to prompt for a password with confirmation
prompt_for_password() {
    local prompt="$1"
    local variable_name="$2"
    local password password_confirm

    while true; do
        printf "%s: " "$prompt"
        read -s password
        printf "\n"

        printf "Confirm %s: " "$prompt"
        read -s password_confirm
        printf "\n"

        if [[ "$password" != "$password_confirm" ]]; then
            printf "Passwords do not match. Please try again.\n" >&2
        elif [[ -z "$password" ]]; then
            printf "Password cannot be empty. Please try again.\n" >&2
        else
            eval "$variable_name='$password'"
            break
        fi
    done
}


# Function to install Samba
install_samba() {
    if ! dpkg -s samba &>/dev/null; then
        printf "Samba not found. Attempting to install Samba...\n"
        apt-get update || { printf "Failed to update packages list\n" >&2; return 1; }
        apt-get install -y samba || { printf "Failed to install Samba\n" >&2; return 1; }
    else
        printf "Samba is already installed.\n"
    fi
}

# Function to add a Samba user
add_samba_user() {
    local samba_user="$1"
    local samba_password="$2"

    # Add the system user without login shell and home directory
    useradd -M -s /usr/sbin/nologin "$samba_user" || { printf "Failed to add system user\n" >&2; return 1; }
    # Add the user to Samba
    (echo "$samba_password"; echo "$samba_password") | smbpasswd -a "$samba_user" || { printf "Failed to add Samba user\n" >&2; return 1; }
    smbpasswd -e "$samba_user" || { printf "Failed to enable Samba user\n" >&2; return 1; }
}

# Function to configure Samba share with authentication
configure_share() {
    local share_name="$1"
    local share_path="$2"
    local samba_user="$3"
    local samba_config="/etc/samba/smb.conf"

    # Ensure the directory exists
    if [[ ! -d "$share_path" ]]; then
        printf "Creating directory: %s\n" "$share_path"
        mkdir -p "$share_path" || { printf "Failed to create directory: %s\n" "$share_path" >&2; return 1; }
    fi

    # Adding new share configuration to the smb.conf
    {
        printf "\n[%s]\n" "$share_name"
        printf "   path = %s\n" "$share_path"
        printf "   valid users = %s\n" "$samba_user"
        printf "   browsable = yes\n"
        printf "   writable = yes\n"
        printf "   read only = no\n"
    } >> "$samba_config"

    # Change ownership to the Samba user
    chown "$samba_user":"$samba_user" "$share_path"
    chmod 0770 "$share_path"
    printf "Samba configuration added for '%s'.\n" "$share_name"
}

# Function to restart Samba service
restart_samba() {
    printf "Restarting Samba service...\n"
    systemctl restart smbd || { printf "Failed to restart Samba service\n" >&2; return 1; }
    printf "Samba service restarted successfully.\n"
}

# Main function to orchestrate steps
main() {
    local share_name
    local share_path
    local samba_user
    local samba_password

    prompt_for_input "Please enter the Samba share name" "share_name" "dropbox"
    prompt_for_input "Please enter the path for the Samba share" "share_path" "/home/dropbox"
    prompt_for_input "Please enter the Samba user name" "samba_user" "samba"
    prompt_for_password "Please enter the Samba user password" "samba_password"

    install_samba || return 1
    add_samba_user "$samba_user" "$samba_password" || return 1
    configure_share "$share_name" "$share_path" "$samba_user" || return 1
    restart_samba || return 1

    printf "Samba share '%s' at '%s' created and configured with user authentication successfully.\n" "$share_name" "$share_path"
}

# Execute the main function
main
