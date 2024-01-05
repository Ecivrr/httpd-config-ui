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

#		echo "${LISTENIP}"
#		echo "${ADMINEMAIL}"
#		echo "${SERVERNAME}"
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
