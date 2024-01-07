#!/bin/bash

#yesno() {
#    local title="$1"
#	local yesno="$2"
#
#    if whiptail --title "$title" --yesno "$yesno" 10 78; then
#        echo "YES"
#    else
#        echo "NO"
#    fi
#}
msg() {
	whiptail --title "${1}" --msgbox "${2}" 10 78
}
input() {
	USER_INPUT=$(whiptail --title "${1}" --inputbox "${2}" 10 78 3>&1 1>&2 2>&3)
}
main_menu() {
	MAIN_MENU=$(whiptail --title "Welcome - This is a tool for HTTPD management" --menu "Choose an option" 25 78 16 \
		"CONFIGURE" "Configure and manage HTTPD, Virtual Hosts, SSL and more." \
		"INSTALL" "Install HTTPD." \
		"HELP" "HTTPD config and usage help." 3>&1 1>&2 2>&3)
}
config_menu() {
	CONFIG_MENU=$(whiptail --title "Welcome - This is a tool for HTTPD management" --menu "Choose an option" 25 78 16 \
		"<-- BACK" "Return to MAIN MENU." \
		"HTTPD" "Configure the httpd.conf file." \
		"VIRTUAL HOSTS" "Add, remove and manage virtual hosts." \
		"SSL/TLS" "Create your own, or add a provided certifcate." \
		"AUTHENTICATION" "Setup user authentication and authorization."  3>&1 1>&2 2>&3)
}
vhost_menu() {
	VHOST_MENU=$(whiptail --title "Configure Virtual Hosts" --menu "Choose an option" 25 78 16 \
		"<-- BACK" "Return to MAIN MENU." \
		"ADD" "Add a Virtual Host." \
		"REMOVE" "Remove a Virtual Host." 3>&1 1>&2 2>&3)
}
ssl_menu() {
	SSL_MENU=$(whiptail --title "Configure SSL" --menu "Choose an option" 25 78 16 \
		"<-- BACK" "Return to MAIN MENU." \
		"SELFSIGNED" "Create a selfsigned certificate." \
		"OWN" "Add a path to your own certificate." 3>&1 1>&2 2>&3)
}
input_data() {
    local variable_name="$1"
    DIALOGSTATUS=$?
    
    if [ "${DIALOGSTATUS}" = 0 ]; then
        eval "${variable_name}=${USER_INPUT}"
    else
		EXITSTATUS="exit"
        echo "EXITING"
        exit 0
    fi
}
