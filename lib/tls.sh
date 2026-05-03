configure_tls() {
    local cert_dir="/etc/ssl/certs"
    local key_dir="/etc/ssl/private"
    
    if whiptail --yesno "Generate 2048-bit self-signed certificate?" 10 60; then
        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout "$key_dir/server.key" \
            -out "$cert_dir/server.crt" \
            -subj "/C=US/ST=State/L=City/O=Org/OU=Unit/CN=localhost"
        
        whiptail --msgbox "Cert: $cert_dir/server.crt\nKey: $key_dir/server.key" 12 60
    fi
}