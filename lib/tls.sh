#!/usr/bin/env bash
#########################
# version: 0.1.0
# date: 3/5/26
# purpose: script that walks an operator through the initial configuration of a Linux server 
# created by bibi
#######################
configure_tls() {
    # Check if a webserver is actually installed first
    local server=""
    if [[ -f /usr/sbin/nginx ]]; then
        server="nginx"
    elif [[ -f /usr/sbin/apache2 ]]; then
        server="apache2"
    else
        show_error "No supported web server (Nginx/Apache) detected. Install one first."
        return 1
    fi

    # Collect Certificate Metadata
    local common_name org org_unit country days
    common_name=$(whiptail --backtitle "$BACKTITLE" --inputbox "Common Name (FQDN/IP):" 10 60 "localhost" 3>&1 1>&2 2>&3) || return
    org=$(whiptail --backtitle "$BACKTITLE" --inputbox "Organization Name:" 10 60 "Automation Corp" 3>&1 1>&2 2>&3) || return
    org_unit=$(whiptail --backtitle "$BACKTITLE" --inputbox "Organizational Unit:" 10 60 "Systems" 3>&1 1>&2 2>&3) || return
    country=$(whiptail --backtitle "$BACKTITLE" --inputbox "Country Code (2 letters):" 10 60 "US" 3>&1 1>&2 2>&3) || return
    days=$(whiptail --backtitle "$BACKTITLE" --inputbox "Validity Period (Days):" 10 60 "365" 3>&1 1>&2 2>&3) || return

    if whiptail --yesno "Generate self-signed certificate for $common_name?" 10 60; then
        local key_path="/etc/ssl/private/server.key"
        local cert_path="/etc/ssl/certs/server.crt"

        # Generate Key and Cert using OpenSSL
        openssl req -x509 -nodes -days "$days" -newkey rsa:2048 \
            -keyout "$key_path" \
            -out "$cert_path" \
            -subj "/C=$country/O=$org/OU=$org_unit/CN=$common_name" 2>/dev/null

        apply_webserver_tls "$server" "$key_path" "$cert_path"
    fi
}

apply_webserver_tls() {
    local server=$1
    local key=$2
    local cert=$3

    {
        echo 20; printf 'XXX\n Configuring %s for HTTPS... \nXXX\n' "$server"; sleep 1
        
        if [[ "$server" == "nginx" ]]; then
            local conf="/etc/nginx/sites-available/default"
            # Use sed to uncomment SSL lines and point to new certs
            # This logic assumes the default Nginx config structure
            sed -i "s|# listen 443 ssl default_server;|listen 443 ssl default_server;|g" "$conf"
            sed -i "s|# include snippets/snakeoil.conf;|ssl_certificate $cert;\n\tssl_certificate_key $key;|g" "$conf"
        else
            # Apache logic
            a2enmod ssl > /dev/null 2>&1
            local conf="/etc/apache2/sites-available/default-ssl.conf"
            sed -i "s|SSLCertificateFile.*|SSLCertificateFile $cert|g" "$conf"
            sed -i "s|SSLCertificateKeyFile.*|SSLCertificateKeyFile $key|g" "$conf"
            a2ensite default-ssl.conf > /dev/null 2>&1
        fi

        echo 70; printf 'XXX\n Reloading %s... \nXXX\n' "$server"; sleep 1
        systemctl restart "$server"
        echo 100
    } | whiptail --backtitle "$BACKTITLE" --gauge "Applying TLS Configuration..." 10 60 0

    whiptail --msgbox "HTTPS configured. Access via: https://$common_name" 10 60
}
