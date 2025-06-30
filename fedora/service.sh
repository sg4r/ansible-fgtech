#!/bin/bash

# A script to manually replicate the core action of `systemctl enable`.
# WARNING: This is for educational purposes. Always prefer using
# `systemctl` in a real environment as it handles more edge cases.

# Check if a service name was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <service-name>"
  echo "Example: $0 httpd.service"
  exit 1
fi

SERVICE_NAME=$1
SYSTEMD_UNIT_PATH="/usr/lib/systemd/system"
SYSTEMD_CONFIG_PATH="/etc/systemd/system"

# Find the service unit file
UNIT_FILE_PATH="${SYSTEMD_UNIT_PATH}/${SERVICE_NAME}"
if [ ! -f "$UNIT_FILE_PATH" ]; then
  echo "Error: Service unit file not found at ${UNIT_FILE_PATH}"
  exit 1
fi

echo "Found service file: ${UNIT_FILE_PATH}"

# Parse the [Install] section to find the "WantedBy=" target
# We use awk for more robust parsing than grep.
TARGET=$(awk -F= '/^\[Install\]/ {f=1} f==1 && /^WantedBy=/ {print $2; exit}' "$UNIT_FILE_PATH")

if [ -z "$TARGET" ]; then
  echo "Error: No 'WantedBy=' directive found in the [Install] section of ${SERVICE_NAME}."
  echo "This service might not be designed to be enabled."
  exit 1
fi

echo "Service is 'WantedBy': ${TARGET}"

# Construct the path for the symbolic link
LINK_DIR="${SYSTEMD_CONFIG_PATH}/${TARGET}.wants"
LINK_PATH="${LINK_DIR}/${SERVICE_NAME}"

# Ensure the target's .wants directory exists
echo "Ensuring directory exists: ${LINK_DIR}"
mkdir -p "$LINK_DIR"

# Create the symbolic link if it doesn't already exist
if [ -L "$LINK_PATH" ]; then
  echo "Link already exists at ${LINK_PATH}. Nothing to do."
else
  echo "Creating symlink: ${LINK_PATH} -> ${UNIT_FILE_PATH}"
  ln -s "$UNIT_FILE_PATH" "$LINK_PATH"
  if [ $? -eq 0 ]; then
    echo "Successfully enabled ${SERVICE_NAME}."
    echo "Run 'systemctl daemon-reload' for changes to be recognized if systemd is running."
  else
    echo "Failed to create symlink. You might need root privileges."
    exit 1
  fi
fi

exit 0
