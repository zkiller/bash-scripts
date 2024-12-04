# Create Samba Share Script

This Bash script provides a quick and easy way to configure a secure Samba share on a Linux system. It automates the installation of Samba, the creation of a Samba user, the configuration of the share, and the restart of the service.

## Features

- Automatically installs Samba (if not already installed).
- Creates a Samba user with a secure password.
- Configures a shared directory with the necessary permissions.
- Restarts the Samba service to apply changes.

## Prerequisites

- A Debian-based Linux system (e.g., Ubuntu).
- Administrator privileges (*root* or via `sudo`).
- `wget` installed to download the script.

## Installation

1. Download the script from this GitHub repository:
    ```bash
    wget https://raw.githubusercontent.com/zkiller/bash-scripts/refs/heads/main/create_samba_share/create_samba_share.sh
    ```

2. Make it executable:
    ```bash
    chmod +x create_samba_share.sh
    ```

3. Run the script with administrator privileges:
    ```bash
    sudo ./create_samba_share.sh
    ```

## Usage

When executed, the script prompts you for information to configure the Samba share. Default values are provided to simplify the process:

| **Prompt**                                   | **Default Value**       |
|----------------------------------------------|--------------------------|
| Name of the Samba share                      | `dropbox`               |
| Path to the directory to share               | `/home/dropbox`         |
| Name of the Samba user                       | `samba`                 |
| Password for the Samba user                  | *(must be entered)*     |

### Example Run
```
Please enter the Samba share name [dropbox]:
Please enter the path for the Samba share [/home/dropbox]:
Please enter the Samba user name [samba]:
Please enter the Samba user password:
Confirm Please enter the Samba user password:
```
Once complete, you will see this message:

`Samba share 'dropbox' at '/home/dropbox' created and configured with user authentication successfully.`


The Samba share will be configured and ready to use.

## Detailed Workflow

1. **Samba Installation**:  
   If Samba is not already installed, the script installs it automatically using `apt-get`.

2. **Samba User Creation**:  
   A Samba user is created with a secure password you define. The password is hidden during input and requires confirmation.

3. **Share Configuration**:  
   A new share is added to the `/etc/samba/smb.conf` file. Permissions and ownership of the directory are set for the created Samba user.

4. **Service Restart**:  
   The Samba service (`smbd`) is restarted to apply the configuration.

## Security

- The Samba user password is hidden during input and does not appear in logs.
- Permissions for the shared directory are restricted to the created Samba user.

## Troubleshooting

If you encounter issues while running the script:
- Verify that you are running the script with administrator privileges.
- Ensure your system is connected to the Internet to download required packages.
- Check the Samba service logs to diagnose errors:
    ```bash
    sudo journalctl -u smbd
    ```

## Contribution

Contributions to improve this script are welcome! Feel free to submit an *issue* or a *pull request*.

## License

This project is licensed under the MIT License. You are free to use, modify, and redistribute it.
