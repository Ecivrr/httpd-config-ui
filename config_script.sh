#!/bin/bash
#COMMIT BEFORE SUBMISSION
BASE_DIR=$(echo $0 | sed 's/\(.*httpd-config-ui\).*/\1/')
USER=$(id -u)

. "$BASE_DIR"/library/whip.sh
. "$BASE_DIR"/library/configs.sh

if [ "${USER}" != 0 ]; then
    msg "RUN AS ROOT" "PLEASE RUN SCRIPT AS ROOT"
	exit 0
fi

EXITSTATUS="main"
while [ "${EXITSTATUS}" == "main" ]; do
	main_menu

	if [ "${MAIN_MENU}" == "CONFIGURE" ]; then
		EXITSTATUS="config"
	elif [ "${MAIN_MENU}" == "INSTALL" ]; then
		if dnf list --installed | grep -q httpd && dnf list --installed | grep -q mod_ssl; then
			msg "INSTALL" "HTTPD IS ALREADY INSTALLED"
		else
			dnf install -y httpd mod_ssl
			systemctl enable httpd
			msg "INSTALL SUCCESS" "httpd and mod_ssl installed successfully"
			if whiptail --title "FIREWALLD" --yesno "Do you want to open ports 80 and 443 in firewalld?" 10 78; then
				firewall-cmd --permanent --zone=public --add-port=80/tcp
				firewall-cmd --permanent --zone=public --add-port=443/tcp
				systemctl restart firewalld
			fi
		fi

	elif [ "${MAIN_MENU}" == "HELP" ]; then
		whiptail --textbox "$BASE_DIR/library/help" 25 78
	else
		EXITSTATUS="exit"
	fi
	
	while [ "${EXITSTATUS}" == "config" ]; do
		config_menu

		if [ "${CONFIG_MENU}" == "<-- BACK" ]; then
			EXITSTATUS="main"
			break
		elif [ "${CONFIG_MENU}" == "HTTPD" ]; then
			input "Configure the httpd.conf file" "Input specific listen IP 'address:port', or only port number."
			if [ $? == 1 ]; then
				EXITSTATUS="config"
				continue
			fi
			input_data "LISTENIP"

			input "Configure the httpd.conf file" "Input the admins email."
			if [ $? == 1 ]; then
				EXITSTATUS="config"
				continue
			fi
			input_data "ADMINEMAIL"

			input "Configure the httpd.conf file" "Input the server name or IP address (NO MASK)."
			if [ $? == 1 ]; then
				EXITSTATUS="config"
				continue
			fi
			input_data "SERVERNAME"

			httpd_sed

		elif [ "${CONFIG_MENU}" == "VIRTUAL HOSTS" ]; then
			if [ ! -e "/etc/httpd/vhost.d" ]; then
				mkdir "/etc/httpd/vhost.d"
			fi

			EXITSTATUS="vhost"

			while [ "${EXITSTATUS}" == "vhost" ]; do
				vhost_menu

				if [ "${VHOST_MENU}" == "<-- BACK" ]; then
					EXITSTATUS="config"
					break
				elif [ "${VHOST_MENU}" == "ADD" ]; then
					input "Add a virtual host" "Input the domain."
					if [ $? == 1 ]; then
						EXITSTATUS="vhost"
						continue
					fi
					input_data "DOMAIN"

					input "Add a virtual host" "Input the admins email."
					if [ $? == 1 ]; then
						EXITSTATUS="vhost"
						continue
					fi					
					input_data "ADMINEMAIL"

					if [ ! -e "/var/www/vhost/${DOMAIN}" ]; then
						mkdir -p /var/www/vhost/${DOMAIN}/docroot
						touch /var/www/vhost/${DOMAIN}/docroot/index.html
					fi
					vhost_sed

				elif [ "${VHOST_MENU}" == "REMOVE" ]; then
					input "Remove a virtual host" "Input the domain of the virtual host."
					if [ $? == 1 ]; then
						EXITSTATUS="vhost"
						continue
					fi						
					input_data "DOMAIN"
		
					if [ -e "/etc/httpd/vhost.d/${DOMAIN}.conf" ];then
						if whiptail --title "Remove a virtual host" --yesno "Are you sure you want to remove ${DOMAIN}?" 10 78; then
							rm -f /etc/httpd/vhost.d/${DOMAIN}.conf*
							rm -rf /var/www/vhost/${DOMAIN}

						else
							msg "DON'T REMOVE" "Virtual Host not removed."
						fi
					else
						msg "DOESN'T EXIST" "Virtual Host does not exist."

						EXITSTATUS="vhost"
					fi
				elif [ "${VHOST_MENU}" == "HTTPS" ]; then
					EXITSTATUS="https"

					while [ "${EXITSTATUS}" == "https" ]; do
						https_menu

						if [ "${HTTPS_MENU}" == "<-- BACK" ]; then
							EXITSTATUS="vhost"
							continue
						elif [ "${HTTPS_MENU}" == "ENABLE" ]; then
							input "Enable https forcing" "Input the domain of the virtual host."
							if [ $? == 1 ]; then
								EXITSTATUS="https"
								continue
							fi						
							input_data "DOMAIN"

							if [ -e "/etc/httpd/vhost.d/${DOMAIN}.conf" ];then
								if grep -q "#" "/etc/httpd/vhost.d/${DOMAIN}.conf"; then
									sed -i 's/#Redirect/Redirect/' /etc/httpd/vhost.d/${DOMAIN}.conf
								else
									msg "ALREADY ENABLED" "Https forcing is already enabled."
									EXITSTATUS="https"
								fi
							else
								msg "DOESN'T EXIST" "Virtual Host does not exist."

								EXITSTATUS="https"
							fi
						elif [ "${HTTPS_MENU}" == "DISABLE" ]; then
							input "Disable https forcing" "Input the domain of the virtual host."
							if [ $? == 1 ]; then
								EXITSTATUS="https"
								continue
							fi						
							input_data "DOMAIN"

							if [ -e "/etc/httpd/vhost.d/${DOMAIN}.conf" ];then
								if ! grep -q "#" "/etc/httpd/vhost.d/${DOMAIN}.conf"; then
									sed -i 's/Redirect/#Redirect/' /etc/httpd/vhost.d/${DOMAIN}.conf
								else
									msg "ALREADY DISABLED" "Https forcing is already disabled."
									EXITSTATUS="https"
								fi
							else
								msg "DOESN'T EXIST" "Virtual Host does not exist."

								EXITSTATUS="https"
							fi
						else
							EXITSTATUS="exit"
						fi
					done
				else
					EXITSTATUS="exit"
					break
				fi
			done

		elif [ "${CONFIG_MENU}" == "SSL/TLS" ]; then
			EXITSTATUS="ssl"

			while [ "${EXITSTATUS}" == "ssl" ]; do
				ssl_menu

				if [ "${SSL_MENU}" == "<-- BACK" ]; then
					EXITSTATUS="config"
					break
				elif [ "${SSL_MENU}" == "SELFSIGNED" ]; then
					input "Create SSL/TLS certificate" "Input the domain."
					if [ $? == 1 ]; then
						EXITSTATUS="ssl"
    		    		continue
    				fi	
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
							openssl req -new -x509 -nodes -subj "/C=CZ/ST=Czech Republic/L=Prague/CN=SELFSIGNED" -days 3650 -key /root/cert/ca.key -out /root/cert/ca.crt
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

						if grep -q "SSLCertificateFile" "/etc/httpd/vhost.d/${DOMAIN}.conf"; then
							sed -i "34,37d" "/etc/httpd/vhost.d/${DOMAIN}.conf"
							ssl_template
						else
							ssl_template
						fi
					else
						msg "DOESN'T EXIST" "Domain does not exist."

						EXITSTATUS="ssl"
						continue
					fi

				elif [ "${SSL_MENU}" == "OWN" ]; then
					if [ ! -e "/etc/httpd/ssl" ]; then
						mkdir /etc/httpd/ssl
					fi

					if whiptail --title "Certificate directory" --yesno "Is your certificate saved in the '/etc/httpd/ssl/' directory?" 10 78; then
						input "Include your own certificate" "Input the domain which the certificate is for."
						if [ $? == 1 ]; then
							EXITSTATUS="ssl"
    		    			continue
    					fi	
						input_data "DOMAIN"

						if [ ! -e "/etc/httpd/vhost.d/${DOMAIN}.conf" ]; then
							msg "DOESN'T EXIST" "Domain does not exist."

							EXITSTATUS="exit"
							break
						fi

						input "Include your own certificate" "Input the whole certificate name."
						if [ $? == 1 ]; then
							EXITSTATUS="ssl"
    		    			continue
    					fi	
						input_data "CRT"

						input "Include your own certificate" "Input the whole key name."
						if [ $? == 1 ]; then
							EXITSTATUS="ssl"
    		    			continue
    					fi							
						input_data "KEY"

						if [ -e "/etc/httpd/ssl/${CRT}" ] && [ -e "/etc/httpd/ssl/${KEY}" ]; then
							if grep -q "SSLCertificateFile" "/etc/httpd/vhost.d/${DOMAIN}.conf"; then
								sed -i "34,37d" "/etc/httpd/vhost.d/${DOMAIN}.conf"
								own_ssl_template
							else
								own_ssl_template
							fi
						else
							msg "DOESN'T EXIST" "Certificate does not exist."

							EXITSTATUS="exit"
							break
						fi
						EXITSTATUS="ssl"
						continue

					else
						msg "Certificate directory" "Please SAVE YOUR certificate in the '/etc/httpd/ssl/' directory."
						
						EXITSTATUS="exit"
						break						
					fi

				else
					EXITSTATUS="exit"
					break
				fi
			done
		elif [ "${CONFIG_MENU}" == "AUTHENTICATION" ]; then
			if [ ! -e "/etc/httpd/passwords" ]; then
				mkdir /etc/httpd/passwords
			fi

			EXITSTATUS="auth"
			while [ "${EXITSTATUS}" == "auth" ]; do
				auth_menu

				if [ "${AUTH_MENU}" == "<-- BACK" ]; then
					EXITSTATUS="config"
					break
				elif [ "${AUTH_MENU}" == "ENABLE" ]; then
					input "Enable authentication" "Input the domain you wish to enable authentication for."
					if [ $? == 1 ]; then
						EXITSTATUS="auth"
    		    		continue
    				fi	
					input_data "DOMAIN"

					if [ -e "/etc/httpd/vhost.d/${DOMAIN}.conf" ]; then
						if grep -q "AuthType" "/etc/httpd/vhost.d/${DOMAIN}.conf"; then
							msg "ALREADY ENABLED" "Authentication is already enabled."
						else
							if grep -q "SSLCertificateFile" "/etc/httpd/vhost.d/${DOMAIN}.conf"; then
								auth_enable
							else
								msg "ENABLE SSL and HTTPS" "SSL must be anbled when enabling authentication."
							fi
						fi
					else
						msg "DOES'T EXIST" "Domain does not exist."
					fi
				elif [ "${AUTH_MENU}" == "DISABLE" ]; then
					input "Disable authentication" "Input the domain you wish to disable authentication for."
					if [ $? == 1 ]; then
						EXITSTATUS="auth"
    		    		continue
    				fi	
					input_data "DOMAIN"

					if [ -e "/etc/httpd/vhost.d/${DOMAIN}.conf" ]; then
						if grep -q "AuthType" "/etc/httpd/vhost.d/${DOMAIN}.conf"; then
							sed -i "26,29d" "/etc/httpd/vhost.d/${DOMAIN}.conf"
							sed -i "59,62d" "/etc/httpd/vhost.d/${DOMAIN}.conf"
						else
							msg "ALREADY DISABLED" "Authentication is already disabled."
						fi
					else
						msg "DOES'T EXIST" "Domain does not exist."
					fi
				elif [ "${AUTH_MENU}" == "ADD USER" ]; then
					input "Add user" "Input the domain."
					if [ $? == 1 ]; then
						EXITSTATUS="auth"
    		    		continue
    				fi	
					input_data "DOMAIN"

					if [ ! -e "/etc/httpd/vhost.d/${DOMAIN}.conf" ];then
						msg "DOES'T EXIST" "Domain does not exist."

						EXITSTATUS="auth"
    		    		continue
					fi

					input "Add user" "Input the username you want to authenticate."
					if [ $? == 1 ]; then
						EXITSTATUS="auth"
    		    		continue
    				fi	
					input_data "USER"

					if [ ! -e "/etc/httpd/passwords/${DOMAIN}" ]; then
						mkdir /etc/httpd/passwords/${DOMAIN}
						touch /etc/httpd/passwords/${DOMAIN}/passwd
					fi

					if grep -q "${USER}" "/etc/httpd/passwords/${DOMAIN}/passwd"; then
						if whiptail --title "Add user" --yesno "User already exists, do you want to update the password?" 10 78; then
							htpasswd /etc/httpd/passwords/${DOMAIN}/passwd "${USER}"
						else
							msg "NOT UPDATED" "Password was not updated."
						fi
					else
						htpasswd /etc/httpd/passwords/${DOMAIN}/passwd "${USER}"
					fi

				elif [ "${AUTH_MENU}"  == "REMOVE USER" ]; then
					input "Remove user" "Input the domain."
					if [ $? == 1 ]; then
						EXITSTATUS="auth"
    		    		continue
    				fi	
					input_data "DOMAIN"

					if [ ! -e "/etc/httpd/vhost.d/${DOMAIN}.conf" ];then
						msg "DOES'T EXIST" "Domain does not exist."

						EXITSTATUS="auth"
    		    		continue
					fi

					input "Remove user" "Input the username you want to remove."
					if [ $? == 1 ]; then
						EXITSTATUS="auth"
    		    		continue
    				fi	
					input_data "USER"

					if grep -q "${USER}" "/etc/httpd/passwords/${DOMAIN}/passwd"; then
						htpasswd -D /etc/httpd/passwords/${DOMAIN}/passwd "${USER}"
					else
						msg "DOESN'T EXIST" "User does not exist"
					fi
				else
					EXITSTATUS="exit"
					break
				fi	
			done
		else
			EXITSTATUS="exit"
			break
		fi
	done
done
