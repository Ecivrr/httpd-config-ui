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

cp /opt/httpd_config_ui/templates/httpd_template /tmp/httpd.conf

TOMAIN="httpd.conf"
eval_dif(){

    if [ -e "${1}" ]; then
        DIFF=$(diff "${2}" "${1}")
        if [ "${DIFF}" ]; then
            DATE=$(date +%y%m%d%H%M%S)
            mv "${1}" "${1}".backup_${DATE}
            mv "${2}" "${1}"
        else
            rm -f "${2}"
        fi
    else
        mv "${2}" "${1}"
    fi
}

eval_dif "/etc/httpd/conf/${TOMAIN}" "/tmp/${TOMAIN}"
