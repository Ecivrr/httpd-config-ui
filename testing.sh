#!/bin/bash
#{
#   for ((i = 0 ; i <= 100 ; i+=1)); do
#        sleep 0.1
#        echo $i
#    done
#} | whiptail --gauge "Please wait while we are sleeping..." 8 78 0

#{
#	sleep 0.5
#	echo -e "XXX\n0\ndnf remove epel-release\nXXX"
#	dnf remove epel-release
#	sleep 2
#	echo -e "XXX\n0\ndnf remove epel-release DONE.\nXXX"
#	sleep 0.5
#} | whiptail --title "Dnf removal" --gauge "Please whit while removing" 8 78 0

#menu() {
#	whiptail --title "${1}" --menu "${2}" 25 78 16 \
#	"${3}" "${4}" \
#	"${5}" "${6}"\
#	"${7}" "${8}"
#}

#menu "pokus" "pokus" "ppokus1" "pokus2" "pokus3" "ppokus1"

#whiptail --title "pokus" --menu "pokus" 25 78 16 \

#cp /opt/httpd_config_ui/templates/httpd_template /tmp/httpd.conf

#TOMAIN="httpd.conf"
#eval_dif(){

#    if [ -e "${1}" ]; then
#        DIFF=$(diff "${2}" "${1}")
#        if [ "${DIFF}" ]; then
#            DATE=$(date +%y%m%d%H%M%S)
#            mv "${1}" "${1}".backup_${DATE}
#            mv "${2}" "${1}"
#        else
#            rm -f "${2}"
#        fi
#   else
#        mv "${2}" "${1}"
#    fi
#}

#eval_dif "/etc/httpd/conf/${TOMAIN}" "/tmp/${TOMAIN}"

#main_menu() {
#    local menu_options=("$@")

    # Convert array to a format suitable for whiptail
#    local whiptail_options=()
#    for ((i = 0; i < ${#menu_options[@]}; i += 2)); do
#        whiptail_options+=("$((i / 2 + 1))" "${menu_options[i + 1]}")
#    done

#    MAIN_MENU=$(whiptail --title "Welcome - This is a tool for HTTPD management" \
#       --menu "Choose an option" 25 78 16 "${whiptail_options[@]}" 3>&1 1>&2 2>&3)
#}

# Example usage:
#options=("CONFIGURE" "Configure and manage HTTPD, Virtual Hosts, SSL and more." \
#         "INSTALL" "Install HTTPD." \
#         "HELP" "HTTPD config and usage help.")

#main_menu "${options[@]}"

#echo ${MAIN_MENU}
#ssl_menu() {
#	VHOST=$(whiptail --title "Configure Virtual Hosts" --menu "Choose an option" 25 78 16 \
#		"<-- BACK" "Return to MAIN MENU." \
#		"ADD" "Add a Virtual Host." \
#		"REMOVE" "Remove a Virtual Host." 3>&1 1>&2 2>&3)
#}
#ssl_menu
#DOMAIN="fifth.com"
#if [ -e "/etc/httpd/vhost.d/${DOMAIN}.conf" ]; then
#				if [ ! -e "/root/cert" ]; then
#					mkdir /root/cert
#				fi
#				if [ ! -e "/etc/httpd/ssl" ]; then
#					mkdir /etc/httpd/ssl
#				fi			
#
#				openssl genrsa 2048 > /root/cert/ca.key
#				openssl req -new -x509 -nodes -subj "/C=CZ/ST=Czech Republic/L=Prague/CN=${DOMAIN}" -days 3650 -key /root/cert/ca.key -out /root/cert/ca.crt
#
#				if [ -e /root/cert/serial.txt ]; then
#					SERIAL=$(cat /root/cert/serial.txt)
#					SERIAL=$((SERIAL+1))
#				else
#					SERIAL=1
#				fi
#
#				openssl req -newkey rsa:2048 -nodes -subj "/C=CZ/ST=Czech Republic/L=Prague/CN=${DOMAIN}" -keyout /root/cert/${DOMAIN}.key -out /root/cert/${DOMAIN}-req.crt
#				openssl x509 -req -in /root/cert/${DOMAIN}-req.crt -days 365 -CA /root/cert/ca.crt -CAkey /root/cert/ca.key -set_serial ${SERIAL} -out /root/cert/${DOMAIN}.crt
#			
#				cp -f /root/cert/${DOMAIN}.crt /etc/httpd/ssl/
#				cp -f /root/cert/${DOMAIN}.key /etc/httpd/ssl/
#
#				echo ${SERIAL} > /root/cert/serial.txt
#
#				cp /opt/httpd_config_ui/templates/vhost_ssl_template /tmp/vhost_ssl_template
#				sed -i "s/_DOMAIN_/${DOMAIN}/g" /tmp/vhost_ssl_template
#				sed -i "33r /tmp/vhost_ssl_template" "/etc/httpd/vhost.d/${DOMAIN}.conf"
#				rm -f /tmp/vhost_ssl_template
#			else
#				echo "domain doesnt exist"
#				exti 0
#			fi
if ! grep -q "SSLEngine on" "/etc/httpd/vhost.d/fifth.com.conf"; then
	echo "string doesnt exist"
fi
