#!/usr/bin/env bash
#########################
# version: 0.1.0
# date: 3/5/26
# purpose: script that walks an operator through the initial configuration of a Linux server 
# created by bibi
#######################
set -euo pipefail

is_valid_ipv4() {
    echo "$1" | grep -qE '^([0-9]{1,3}\.){3}[0-9]{1,3}$'
}

configure_network() {
    local mode
    mode=$(whiptail --backtitle "$BACKTITLE" --title " Network Configuration " \
        --menu "Choose connection type:" "$H" "$W" 2 \
        "DHCP" "Automatic IP assignment" \
        "Static" "Manual IP assignment" \
        3>&1 1>&2 2>&3) || return

    if [[ "$mode" == "DHCP" ]]; then
        apply_netplan_config "dhcp"
    else
        local ip mask gw
        ip=$(whiptail --inputbox "Enter Static IP (e.g. 192.168.1.50):" 10 60 3>&1 1>&2 2>&3) || return
        mask=$(whiptail --inputbox "Enter CIDR Prefix (e.g. 24):" 10 60 "24" 3>&1 1>&2 2>&3) || return
        gw=$(whiptail --inputbox "Enter Gateway IP:" 10 60 3>&1 1>&2 2>&3) || return

        if ! is_valid_ipv4 "$ip" || ! is_valid_ipv4 "$gw"; then
            show_error "Invalid IP format detected."
            return 1
        fi

        apply_netplan_config "static" "$ip" "$mask" "$gw"
    fi
}

apply_netplan_config() {
    local type=$1
    local interface
    interface=$(ip route | grep default | awk '{print $5}' | head -n1)
    local config_file="/etc/netplan/01-netcfg.yaml"

    # Backup existing config
    cp "$config_file" "${config_file}.bak"

    if [[ "$type" == "dhcp" ]]; then
        cat <<EOF > "$config_file"
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
      dhcp4: true
EOF
    else
        cat <<EOF > "$config_file"
network:
  version: 2
  renderer: networkd
  ethernets:
    $interface:
      addresses: [$2/$3]
      routes:
        - to: default
          via: $4
EOF
    fi

    # The Timeout Logic: netplan try
    # If the user doesn't confirm in 120 seconds, it rolls back
    if whiptail --backtitle "$BACKTITLE" --yesno "Apply changes with 120s safety timeout?" 10 60; then
        if netplan try --timeout 120; then
            whiptail --msgbox "Network configuration applied successfully." 10 60
        else
            whiptail --msgbox "Netplan timed out or was rejected. Configuration rolled back." 10 60
        fi
    else
        mv "${config_file}.bak" "$config_file"
        whiptail --msgbox "Changes discarded." 10 60
    fi
}
