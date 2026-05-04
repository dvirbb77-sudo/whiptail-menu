#!/usr/bin/env bash
#########################
# version: 0.1.0
# date: 3/5/26
# purpose: script that walks an operator through the initial configuration of a Linux server 
# created by bibi
#######################
set -euo pipefail

. ./lib/hostname.sh
. ./lib/network.sh
. ./lib/dns.sh
. ./lib/webserver.sh
. ./lib/tls.sh

readonly BACKTITLE="Server Setup v1.0 - Systems Automation"
readonly H=20
readonly W=75

show_error() {
    if [[ -n "$1" ]]; then
        whiptail --backtitle "$BACKTITLE" --title " Error " --msgbox "$1" 10 60
    fi
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        whiptail --title "Access Denied" --msgbox "This script must be run as root." 10 60
        exit 1
    fi
}
show_summary() {
    local msg="Configuration Summary:\n\n"
    msg="${msg}Hostname: $(hostname)\n"
    msg="${msg}Web Server: $(systemctl is-active nginx || systemctl is-active apache2)\n"
    msg="${msg}Cert Path: /etc/ssl/certs/server.crt\n"
    
    whiptail --backtitle "$BACKTITLE" --title " Final Report " --msgbox "$msg" 15 60
}
#########################################
# main -_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
#########################################
main() {
    check_root

    while :; do
        local choice
        choice=$(whiptail --backtitle "$BACKTITLE" --title " Main Menu " \
            --menu "Select a configuration step:" $H $W 6 \
            "1" "Set System Hostname" \
            "2" "Configure IP Address (Netplan)" \
            "3" "Configure DNS Servers" \
            "4" "Install Web Server (Nginx/Apache)" \
            "5" "Generate Self-Signed TLS Certificate" \
            "6" "Exit" \
            3>&1 1>&2 2>&3) || break

        case "$choice" in
            1) configure_hostname ;;
            2) configure_network ;;
            3) configure_dns ;;
            4) install_webserver ;;
            5) configure_tls ;;
            6) break ;;
            *) continue ;;
        esac
    done
    show_summary
    whiptail --backtitle "$BACKTITLE" --msgbox "Session Ended." 10 60
    clear
    return 0
}

main "$@"