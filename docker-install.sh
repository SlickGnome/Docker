#!/usr/bin/env bash
# ------------------------------------------------------------------
# 
# Title:        docker-install.sh
# Description:  This script installs and configures Docker on Ubuntu 22.0.4
# Author:       mckinie
# License:      MIT
# License URL:  https://github.com/mckinie/Proxmox/raw/main/LICENSE
#
# ------------------------------------------------------------------

# Variables
CYAN=$(echo "\033[1;36m")
NC=$(echo "\033[m")
LINE="-"
LOG_FILE="docker-install.log"

set -euo pipefail
shopt -s inherit_errexit nullglob

# Utility Functions
log() {
    local msg="$1"
    echo -ne " ${LINE} ${CYAN}${msg}${NC}" | tee -a $LOG_FILE
}

# Install available updates
log "Updating packages (may take some time)"
apt-get update &>/dev/null
apt-get -y upgrade &>/dev/null
log "Complete\n"

# Remove any existing packages installed that may conflict
log "Removing any older conflicting packagages"
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do apt-get remove $pkg &>/dev/null; done
log "Complete!\n"

# Update the apt package index and install packages to allow apt to use a repository over HTTPS:
apt-get install ca-certificates curl gnupg
log "Required packages installed\n"

# Add Docker’s official GPG key:
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
log "Docker GPG Key imported\n"

# Use the following command to set up the repository:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
log "Docker repository added\n"

# Install Docker Engine, containerd, and Docker Compose
log "Installing Docker components"
apt-get update &>/dev/null
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin &>/dev/null
log "Complete!"