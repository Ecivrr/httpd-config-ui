httpd_sed() {
    cp /opt/httpd_config_ui/templates/httpd_template /tmp/httpd.conf
    sed -i "s/_LISTENIP_/${LISTENIP}/g" /tmp/httpd.conf
    sed -i "s/_ADMINMAIL_/${ADMINEMAIL}/g" /tmp/httpd.conf
    sed -i "s/_SERVERNAME_/${SERVERNAME}/g" /tmp/httpd.conf
    
    if [ -e "/etc/httpd/conf/httpd.conf" ]; then
        DIFF=$(diff /tmp/httpd.conf /etc/httpd/conf/httpd.conf)
        if [ "${DIFF}" ]; then
            DATE=$(date +%y%m%d%H%M%S)
            mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.backup_${DATE}
            mv /tmp/httpd.conf /etc/httpd/conf/httpd.conf
        else
            rm -f /tmp/httpd.conf
        fi
    else
        mv /tmp/httpd.conf /etc/httpd/conf/httpd.conf
    fi
}
vhost_sed(){
    #vhost_template hodit do vhost.d
    #do index.html pripsat ze je to testovaci virtualhost??
}
