#!/usr/bin/env bash

# TODO - Check if requirements are met
# TODO - Upload the compressed file to Cloud Storage using rclone
# TODO - Email the log file
# TODO - Create Systemd Service Unit and Timer

# Writes arguments to the end of log file
write_log() {
    timestamp=$(date +"%Y%m%d")
    log_file="${export_path}/${timestamp}.log"
    if [ ! -f "${log_file}" ]; then
        touch "${log_file}"
    fi
    printf "$(date -u) : $1\n" >> "$log_file"
}

# Function to pause the container
pause_container() {
    write_log "Pausing container ${1} for backup"
    /usr/bin/podman pause "${1}"
}

# Function to export the Podman Volume
export_volume() {
    write_log "Exporting Podman Volume: ${1}..."
    /usr/bin/podman volume export "${1}" --output "${export_path}/${1}-${timestamp}".tar
    # Check if the podman volume export was successful
    if [ $? -ne 0 ]; then
        write_log "An error occurred while exporting podman volume ${1}"
        exit 1
    fi
}

# Function to unpause the container
unpause_container() {
    write_log "Resuming container ${1}"
    /usr/bin/podman unpause "${1}"
}

# Function to compress the exported Podman Volume
compress_volume() {
    write_log "Compressing volume: ${1}"
    /usr/bin/xz -ze "${export_path}/${1}-${timestamp}.tar"
    # Check if the tar command was successful
    if [ $? -eq 0 ]; then
        write_log "Archiving successful."
    else
        write_log "An error occurred during volume compression."
        exit 1
    fi
}

# Function to upload the compressed files to Cloud Storage using rclone
upload_to_cloud() {
    # TODO: Implement upload logic with rclone
    write_log "Uploading compressed files to Cloud Storage using rclone..."
    # Placeholder for upload logic
}

# Function to remove exported files after successful upload
remove_files() {
    write_log "Archiving successful, removing files"
    find "${export_path}" -maxdepth 1 -type f ! --name "*.log" -exec rm -f {} \;
}

# Main function
main() {
    # Set volume export path
    export_path=~/podman_exports

    # Set volume name
    volume="transmission"

    # Set timestamp for unique filename
    timestamp=$(date +"%Y%m%d")

    # Pause the container
    pause_container "${volume}"

    # Export the Podman Volume
    export_volume "${volume}"

    # Unpause the container
    unpause_container "${volume}"

    # Compress the exported Podman Volume
    compress_volume "${volume}"

    # Upload the compressed files to Cloud Storage using rclone
    upload_to_cloud

    # Remove exported files after successful upload
    remove_files

    write_log "Backup Complete"
    exit 0
}

# Call the main function
main
exit 0