httpd_sed() {
    cp /opt/httpd_config_ui/templates/httpd_template /tmp/httpd.conf
    sed -i "s/_LISTENIP_/${LISTENIP}/g" /tmp/httpd.conf
    sed -i "s/_ADMINMAIL_/${ADMINEMAIL}/g" /tmp/httpd.conf
    sed -i "s/_SERVERNAME_/${SERVERNAME}/g" /tmp/httpd.conf
    
    if [ -e "/etc/httpd/conf/httpd.conf" ]; then
        DIFF=$(diff /tmp/httpd.conf /etc/httpd/conf/httpd.conf)
        if [ "${DIFF}" ]; then
            DATE=$(date +%y%m%d%H%M%S)
            mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.backup_${DATE}
            mv /tmp/httpd.conf /etc/httpd/conf/httpd.conf
        else
            rm -f /tmp/httpd.conf
        fi
    else
        mv /tmp/httpd.conf /etc/httpd/conf/httpd.conf
    fi
}
vhost_sed(){
    cp /opt/httpd_config_ui/templates/vhost_template /tmp/${DOMAIN}.conf
    sed -i "s/_DOMAIN_/${DOMAIN}/g" /tmp/${DOMAIN}.conf
    sed -i "s/_ADMINEMAIL_/${ADMINEMAIL}/g" /tmp/${DOMAIN}.conf
    #sed -i "1s/^/This is your ${DOMAIN} Virtual host\n/" /var/www/vhost/${DOMAIN}/docroot/index.html
    echo "This is your ${DOMAIN} Virtual host" > /var/www/vhost/${DOMAIN}/docroot/index.html

    if [ -e "/etc/httpd/vhost.d/${DOMAIN}.conf" ]; then
        DIFF=$(diff /tmp/${DOMAIN}.conf /etc/httpd/vhost.d/${DOMAIN}.conf)
        if [ "${DIFF}" ]; then
            DATE=$(date +%y%m%d%H%M%S)
            mv /etc/httpd/vhost.d/${DOMAIN}.conf /etc/httpd/vhost.d/${DOMAIN}.backup_${DATE}
            mv /tmp/${DOMAIN}.conf /etc/httpd/vhost.d/${DOMAIN}.conf
        else
            rm -f /tmp/${domain.conf}
        fi
    else
        mv /tmp/${DOMAIN}.conf /etc/httpd/vhost.d/${DOMAIN}.conf
    fi
}
