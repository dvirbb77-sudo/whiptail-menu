#!/usr/bin/env bash
#########################
# version: 0.1.0
# date: 3/5/26
# purpose: script that walks an operator through the initial configuration of a Linux server 
# created by bibi
#######################
set -euo pipefail

configure_hostname() {
    local new_host
    new_host=$(whiptail --backtitle "$BACKTITLE" --inputbox "Enter new hostname (RFC 1123):" 10 60 3>&1 1>&2 2>&3) || return

    if [[ -z "$new_host" ]] || echo "$new_host" | grep -qE '^[-]|[-]$|[^a-zA-Z0-9-]'; then
        show_error "Invalid hostname format."
        return 1
    fi

    if whiptail --yesno "Apply hostname '$new_host'?" 10 60; then
        hostnamectl set-hostname "$new_host"
        sed -i "s/127.0.1.1.*/127.0.1.1 $new_host/" /etc/hosts
        whiptail --msgbox "Hostname updated to $new_host" 10 60
    fi
}