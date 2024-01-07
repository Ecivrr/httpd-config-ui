#!/bin/bash
. /opt/httpd_config_ui/library/common.sh
. /opt/httpd_config_ui/library/configs.sh

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
		echo "EXITING"
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

		httpd_sed
		exit 0

	elif [ "${CONFIG_MENU}" == "VIRTUAL HOSTS" ]; then
		if [ ! -e "/etc/httpd/vhost.d" ]; then
			mkdir "/etc/httpd/vhost.d"
		fi
		vhost_menu

		if [ "${VHOST_MENU}" == "<-- BACK" ]; then
			main_menu
		elif [ "${VHOST_MENU}" == "ADD" ]; then
			input "Add a virtual host" "Input the domain."
			input_data "DOMAIN"

			input "Add a virtual host" "Input the admins email."
			input_data "ADMINEMAIL"

			if [ ! -e "/var/www/vhost/${DOMAIN}" ]; then
				mkdir -p /var/www/vhost/${DOMAIN}/docroot
				touch /var/www/vhost/${DOMAIN}/docroot/index.html
			fi

			vhost_sed
			exit 0
		elif [ "${VHOST_MENU}" == "REMOVE" ]; then
			input "Remove a virtual host" "Input the domain of the virtual host"
			input_data "DOMAIN"
			
			if [ -e "/etc/httpd/vhost.d/${DOMAIN}.conf" ];then
				if whiptail --title "Remove a virtual host" --yesno "Are you sure you want to remove ${DOMAIN}?" 10 78; then
					rm -f /etc/httpd/vhost.d/${DOMAIN}.conf*
					rm -rf /var/www/vhost/${DOMAIN}
				else
					echo "DON'T REMOVE VIRTUAL HOST, ABORTING"
				fi
			else
				echo "VIRTUAL HOST DOESN'T EXIST"
			fi

			exit 0
		else
			EXITSTATUS="exit"
			echo "EXITING"
			exit 0
		fi

	elif [ "${CONFIG_MENU}" == "SSL/TLS" ]; then
		#nejdrive menu jestli chce vztvorit certifikat nebo jestli ma vlastni, pak pokud bude chtit vyotvorit certifikat tak se ulozi do /etc/httpd/ssl pokud chce vlastni certifakt tak zada cestu k tomu certifikatu (mohu vyzkouset ze svuj certifikat dam na random misto)
		ssl_menu

		if [ "${SSL_MENU}" == "<-- BACK" ]; then
			main_menu
		elif [ "${SSL_MENU}" == "SELFSIGNED" ]; then
			echo "selfsinged"
			exit 0
		elif [ "${SSL_MENU}" == "OWN" ]; then
			echo "own"
			exit 0
		else
			EXITSTATUS="exit"
			echo "EXITING"
			exit 0
		fi
	elif [ "${CONFIG_MENU}" == "AUTHENTICATION" ]; then
		echo "authentication"
		exit 0
	else
		EXITSTATUS="exit"
		echo "EXITING"
		exit 0
	fi
done
