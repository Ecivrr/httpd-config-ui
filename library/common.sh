#!/bin/bash

yesno() {
	whiptail --title "Welcome - This is a tool for web server configuration." --yesno "${1}" 10 78
}
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
