#!/bin/bash

#BASE_DIR=$(echo $0 | sed 's/\(.*httpd-config-ui\/\).*/\1/')

#echo $BASE_DIR
USER=$(id -u)

if [ "${USER}" != 0 ]; then
    echo "not root"
else
    echo "root"
fi
