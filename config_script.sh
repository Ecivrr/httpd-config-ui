#!/bin/bash
. /opt/httpd_config_ui/library/whip.sh
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
		ssl_menu

		if [ "${SSL_MENU}" == "<-- BACK" ]; then
			main_menu
		elif [ "${SSL_MENU}" == "SELFSIGNED" ]; then
			input "Create SSL/TLS certificate" "Input the domain"
			input_data "DOMAIN"

			if [ -e "/etc/httpd/vhost.d/${DOMAIN}.conf" ]; then
				if [ ! -e "/root/cert" ]; then
					mkdir /root/cert
				fi
				if [ ! -e "/etc/httpd/ssl" ]; then
					mkdir /etc/httpd/ssl
				fi

				if [ ! -e "/root/cert/ca.key" ] && [ ! -e "/root/cert/ca.crt" ]; then
					openssl genrsa 2048 > /root/cert/ca.key
					openssl req -new -x509 -nodes -subj "/C=CZ/ST=Czech Republic/L=Prague/CN=${DOMAIN}" -days 3650 -key /root/cert/ca.key -out /root/cert/ca.crt
				fi

				if [ -e /root/cert/serial.txt ]; then
					SERIAL=$(cat /root/cert/serial.txt)
					SERIAL=$((SERIAL+1))
				else
					SERIAL=1
				fi

				if [ -e "/etc/httpd/ssl/${DOMAIN}.crt" ] && [ -e "/etc/httpd/ssl/${DOMAIN}.key" ]; then
					mv /etc/httpd/ssl/${DOMAIN}.crt /etc/httpd/ssl/${DOMAIN}.crt.old
					mv /etc/httpd/ssl/${DOMAIN}.key /etc/httpd/ssl/${DOMAIN}.key.old
					rm -f /root/cert/${DOMAIN}.crt
					rm -f /root/cert/${DOMAIN}.key
					rm -f /root/cert/${DOMAIN}-req.crt
					cert_gen
				else
					cert_gen
				fi

				cp -f /root/cert/${DOMAIN}.crt /etc/httpd/ssl/
				cp -f /root/cert/${DOMAIN}.key /etc/httpd/ssl/

				echo ${SERIAL} > /root/cert/serial.txt

				if ! grep -q "SSLEngine on" "/etc/httpd/vhost.d/${DOMAIN}.conf"; then
					cp /opt/httpd_config_ui/templates/vhost_ssl_template /tmp/vhost_ssl_template
					sed -i "s/_DOMAIN_/${DOMAIN}/g" /tmp/vhost_ssl_template
					sed -i "33r /tmp/vhost_ssl_template" "/etc/httpd/vhost.d/${DOMAIN}.conf"
					rm -f /tmp/vhost_ssl_template
				fi
			else
				echo "DOMAIN DOES NOT EXIST"
				exit 0
			fi

			exit 0
		elif [ "${SSL_MENU}" == "OWN" ]; then
			if [ ! -e "/etc/httpd/ssl" ]; then
				mkdir /etc/httpd/ssl
			fi
			if whiptail --title "Certificate directory" --yesno "Is your certificate saved in the '/etc/httpd/ssl/' directory?"; then
				input "Include your own certificate" "Input the domain which the certificate is for"
				input_data "DOMAIN"

				if [ ! -e "/etc/httpd/vhost.d/${DOMAIN}.conf" ]; then
					echo "THIS DOMAIN DOES NOT EXIST"
					exit 0
				fi

				input "Include your own certificate" "Input the whole certificate name"
				input_data "CRT"

				input "Include your own certificate" "Input the whole key name"
				input_data "KEY"

				if [ -e "/etc/httpd/ssl/${CRT}" ] && [ -e "/etc/httpd/ssl/${KEY}"]; then
					#sed na vhost template
				else
					#echo ze neexistujou
				fi
				exit 0

			else
				msg "Certificate directory" "Please SAVE YOUR certificate in the '/etc/httpd/ssl/' directory."
			fi

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
