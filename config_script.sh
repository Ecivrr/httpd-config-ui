#!/bin/bash
. /opt/httpd_config_ui/library/common.sh

#HTTPD_CHECK=$(dnf list --installed | grep httpd)
EXITSTATUS="continue"
main_menu

while [ "${EXITSTATUS}" == "continue" ]; do
	if [ "${MAIN_MENU}" == "CONFIGURE" ]; then
		config_menu
	elif [ "${MAIN_MENU}" == "INSTALL" ]; then
		echo "install"
		exit 0
	elif [ "${MAIN_MENU}" == "HELP" ]; then
		echo "help"
		exit 0
	else
		EXITSTATUS="exit"
		exit 0
	fi

	if [ "${CONFIG_MENU}" == "<-- BACK" ]; then
		main_menu
	elif [ "${CONFIG_MENU}" == "HTTPD" ]; then
		input "Configure the httpd.conf file" "Input specific listen IP 'address:port', or only port number."
		input_data "LISTENIP"

		input "Configure the httpd.conf file" "Input the admins email."
		input_data "ADMINEMAIL"

		input "Configure the httpd.conf file" "Input the server name or IP address."
		input_data "SERVERNAME"

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
		exit 0

	elif [ "${CONFIG_MENU}" == "VIRTUAL HOSTS" ]; then
		echo "virtual hosts"
		exit 0
	elif [ "${CONFIG_MENU}" == "SSL/TLS" ]; then
		echo "ssl/tls"
		exit 0
	elif [ "${CONFIG_MENU}" == "AUTHENTICATION" ]; then
		echo "authentication"
		exit 0
	else
		EXITSTATUS="exit"
		exit 0
	fi
done

exit 0
