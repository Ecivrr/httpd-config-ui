#!/bin/bash
if dnf list --installed | grep -q httpd && dnf list --installed | grep -q test; then
    echo "installed"
else
    echo "not"
fi