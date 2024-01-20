eval_diff(){
    if [ -e "${1}" ]; then
        DIFF=$(diff "${2}" "${1}")
        if [ "${DIFF}" ]; then
            DATE=$(date +%y%m%d%H%M%S)
            mv "${1}" "${1}".backup_${DATE}
            mv "${2}" "${1}"
        else
            rm -f "${2}"
        fi
    else
        mv "${2}" "${1}"
    fi
}
httpd_sed() {
    cp /opt/httpd_config_ui/templates/httpd_template /tmp/httpd.conf
    sed -i "s/_LISTENIP_/${LISTENIP}/g" /tmp/httpd.conf
    sed -i "s/_ADMINMAIL_/${ADMINEMAIL}/g" /tmp/httpd.conf
    sed -i "s/_SERVERNAME_/${SERVERNAME}/g" /tmp/httpd.conf
    
    eval_diff "/etc/httpd/conf/httpd.conf" "/tmp/httpd.conf"
}
vhost_sed(){
    cp /opt/httpd_config_ui/templates/vhost_template /tmp/${DOMAIN}.conf
    sed -i "s/_DOMAIN_/${DOMAIN}/g" /tmp/${DOMAIN}.conf
    sed -i "s/_ADMINEMAIL_/${ADMINEMAIL}/g" /tmp/${DOMAIN}.conf
    echo "This is your ${DOMAIN} Virtual host" > /var/www/vhost/${DOMAIN}/docroot/index.html

    eval_diff "/etc/httpd/vhost.d/${DOMAIN}.conf" "/tmp/${DOMAIN}.conf"
}
cert_gen() {
    openssl req -newkey rsa:2048 -nodes -subj "/C=CZ/ST=Czech Republic/L=Prague/CN=${DOMAIN}" -keyout /root/cert/${DOMAIN}.key -out /root/cert/${DOMAIN}-req.crt
	openssl x509 -req -in /root/cert/${DOMAIN}-req.crt -days 365 -CA /root/cert/ca.crt -CAkey /root/cert/ca.key -set_serial ${SERIAL} -out /root/cert/${DOMAIN}.crt
}
ssl_template() {
    cp /opt/httpd_config_ui/templates/vhost_ssl_template /tmp/vhost_ssl_template
	sed -i "s/_DOMAIN_/${DOMAIN}/g" /tmp/vhost_ssl_template
	sed -i "34r /tmp/vhost_ssl_template" "/etc/httpd/vhost.d/${DOMAIN}.conf"
	rm -f /tmp/vhost_ssl_template
}
own_ssl_template() {
    cp /opt/httpd_config_ui/templates/vhost_own_ssl_template /tmp/vhost_own_ssl_template
	sed -i "s/_CRT_/${CRT}/g" /tmp/vhost_own_ssl_template
	sed -i "s/_KEY_/${KEY}/g" /tmp/vhost_own_ssl_template
	sed -i "34r /tmp/vhost_own_ssl_template" "/etc/httpd/vhost.d/${DOMAIN}.conf"
	rm -f /tmp/vhost_own_ssl_template
}
auth_enable() {
    cp /opt/httpd_config_ui/templates/auth_template /tmp/auth_template
    sed -i "s/_DOMAIN_/${DOMAIN}/g" /tmp/auth_template
    sed -i "25r /tmp/auth_template" "/etc/httpd/vhost.d/${DOMAIN}.conf"
    sed -i "63r /tmp/auth_template" "/etc/httpd/vhost.d/${DOMAIN}.conf"
    rm -f /tmp/auth_template
}
#27-31
#60-64
