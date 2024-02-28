#!/bin/bash
#COMMIT BEFORE SUBMISSION
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
		"VIRTUAL HOSTS" "Add, remove or manage your virtual hosts." \
		"SSL/TLS" "Create a selfsigned certificate, or supply your own." \
		"AUTHENTICATION" "Manage user authentication."  3>&1 1>&2 2>&3)
}
vhost_menu() {
	VHOST_MENU=$(whiptail --title "Configure Virtual Hosts" --menu "Choose an option" 25 78 16 \
		"<-- BACK" "Return to CONFIG MENU." \
		"ADD" "Add a Virtual Host." \
		"REMOVE" "Remove a Virtual Host." \
		"HTTPS" "Enable or Disable https forcing." 3>&1 1>&2 2>&3)
}
ssl_menu() {
	SSL_MENU=$(whiptail --title "Configure SSL" --menu "Choose an option" 25 78 16 \
		"<-- BACK" "Return to CONFIG MENU." \
		"SELFSIGNED" "Create a selfsigned certificate." \
		"OWN" "Add a path to your own certificate." 3>&1 1>&2 2>&3)
}
auth_menu() {
	AUTH_MENU=$(whiptail --title "Configure Authentication" --menu "Choose an option" 25 78 16 \
		"<-- BACK" "Return to CONFIG MENU." \
		"ENABLE" "Enable authentication for a domain." \
		"DISABLE" "Disable authentication for a domain." \
		"ADD USER" "Add authenticated user for a domain." \
		"REMOVE USER" "Remove authetnicated user for a domain." 3>&1 1>&2 2>&3 )
}
https_menu(){
	HTTPS_MENU=$(whiptail --title "Https Forcing" --menu "Choose an option" 25 78 16 \
		"<-- BACK" "Return to CONFIG MENU." \
		"ENABLE" "Enable https forcing." \
		"DISABLE" "Disable https forcing." 3>&1 1>&2 2>&3 )

}
input_data() {
	local variable_name="$1"
	eval "${variable_name}=${USER_INPUT}"
}
