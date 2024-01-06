input_data() {
    local variable_name="$1"
    DIALOGSTATUS=$?

    if [ "${DIALOGSTATUS}" = 0 ]; then
        eval "${variable_name}=${USER_INPUT}"
    else
        echo "ABORTING"
        exit 0
    fi
}
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