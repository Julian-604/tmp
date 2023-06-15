#!/bin/bash

# Global credentials for all switches
username="your_username"
password="your_password"
enable_password="your_enable_password"

# TFTP server details
tftp_server="tftp.example.com"
tftp_directory="/path/to/backup/folder"

# List of switches to backup
switches=(
    "192.168.1.1"
    "192.168.1.2"
    "192.168.1.3"
    # Add more switches if needed
)

# Loop through each switch
for switch_ip in "${switches[@]}"; do
    # Generate a unique backup filename
    backup_file="${switch_ip}_backup.txt"

    # SSH into the switch and execute commands
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$username@$switch_ip" <<EOF
        enable
        $enable_password
        terminal length 0
        show running-config
EOF
    # Save the output to a local backup file
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$username@$switch_ip" "show running-config" > "$backup_file"

    # Send the backup file to the TFTP server
    tftp "$tftp_server" <<-EOF
        put "$backup_file" "$tftp_directory/$backup_file"
        quit
EOF

    # Clean up the local backup file
    rm "$backup_file"

    echo "Backup of $switch_ip created and sent to $tftp_server"
done
