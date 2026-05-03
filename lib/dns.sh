#!/usr/bin/env bash
#########################
# version: 0.1.0
# date: 3/5/26
# purpose: script that walks an operator through the initial configuration of a Linux server 
# created by bibi
#######################
set -euo pipefail
configure_dns() {
    local dns_input
    dns_input=$(whiptail --backtitle "$BACKTITLE" \
        --title " DNS Configuration " \
        --inputbox "Enter DNS servers (e.g., 8.8.8.8, 1.1.1.1):" \
        10 60 3>&1 1>&2 2>&3) || return
    local sanitized
    sanitized=$(echo "$dns_input" | sed 's/,/ /g' | awk '$1=$1')

    if [[ -z "$sanitized" ]]; then
        show_error "DNS input cannot be empty."
        return 1
    fi

    for ip in $sanitized; do
        if ! echo "$ip" | grep -qE '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
            show_error "Invalid IP address detected: $ip"
            return 1
        fi
    done

    if whiptail --backtitle "$BACKTITLE" --yesno "Update DNS settings to: $sanitized?" 10 60; then
        apply_dns_netplan "$sanitized"
    fi
}

apply_dns_netplan() {
    local dns_list=$1
    local interface
    interface=$(ip route | grep default | awk '{print $5}' | head -n1)
    local config_file="/etc/netplan/01-netcfg.yaml"

    local yaml_array
    yaml_array=$(echo "$dns_list" | awk '{ printf "["; for (i=1; i<=NF; i++) printf "\"%s\"%s", $i, (i==NF ? "" : ", "); printf "]" }')

    if [[ -f "$config_file" ]]; then
        # Check if nameservers block exists; if not, we append it to the interface block
        if ! grep -q "nameservers:" "$config_file"; then
            sed -i "/$interface:/a \      nameservers:\n        addresses: $yaml_array" "$config_file"
        else
            # If it exists, update the addresses line
            sed -i "/nameservers:/!b;n;c\        addresses: $yaml_array" "$config_file"
        fi
        
        if netplan try --timeout 60; then
            whiptail --msgbox "DNS configuration updated successfully." 10 60
        else
            whiptail --msgbox "Netplan apply failed. Rolled back DNS changes." 10 60
        fi
    else
        show_error "Netplan configuration file not found at $config_file"
    fi
}