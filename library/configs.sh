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
    #sed -i "1s/^/This is your ${DOMAIN} Virtual host\n/" /var/www/vhost/${DOMAIN}/docroot/index.html
    echo "This is your ${DOMAIN} Virtual host" > /var/www/vhost/${DOMAIN}/docroot/index.html

    eval_diff "/etc/httpd/vhost.d/${DOMAIN}.conf" "/tmp/${DOMAIN}.conf"
}
