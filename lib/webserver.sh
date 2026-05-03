#!/usr/bin/env bash
#########################
# version: 0.1.0
# date: 3/5/26
# purpose: script that walks an operator through the initial configuration of a Linux server 
# created by bibi
#######################
set -euo pipefail

install_webserver() {
    local choice
    choice=$(whiptail --backtitle "$BACKTITLE" --title " Web Server Installation " \
        --radiolist "Choose a web server to install:" $H $W 2 \
        "nginx" "Lightweight and high-performance" ON \
        "apache2" "Feature-rich and modular" OFF \
        3>&1 1>&2 2>&3) || return

    if whiptail --yesno "Are you sure you want to install $choice?" 10 60; then
        {
            echo 10; sleep 0.5
            echo "XXX\n Updating package lists... \nXXX"
            apt-get update -y > /dev/null 2>&1
            
            echo 40; sleep 0.5
            echo "XXX\n Installing $choice... \nXXX"
            apt-get install -y "$choice" > /dev/null 2>&1
            
            echo 80; sleep 0.5
            echo "XXX\n Starting service... \nXXX"
            systemctl enable --now "$choice" > /dev/null 2>&1
            
            echo 100; sleep 0.5
        } | whiptail --backtitle "$BACKTITLE" --gauge "Preparing installation..." 10 60 0
        
        whiptail --msgbox "$choice has been successfully installed and started." 10 60
    fi
}