#!/usr/bin/env bash
#########################
# version: 0.1.0
# date: 3/5/26
# purpose: script that walks an operator through the initial configuration of a Linux server 
# created by bibi
#######################
set -euo pipefail
install_webserver() {
    local server
    server=$(whiptail --backtitle "$BACKTITLE" --title "Web Server" \
        --radiolist "Select software:" 10 60 2 \
        "nginx" "High performance proxy" ON \
        "apache2" "Robust HTTP server" OFF \
        3>&1 1>&2 2>&3) || return

    (
        echo 20; sleep 1; apt-get update -y > /dev/null 2>&1
        echo 50; apt-get install -y "$server" > /dev/null 2>&1
        echo 80; systemctl enable --now "$server" > /dev/null 2>&1
        echo 100; sleep 1
    ) | whiptail --backtitle "$BACKTITLE" --gauge "Installing $server..." 10 60 0
    whiptail --msgbox "$server installed and started." 10 60
}