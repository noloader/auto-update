#!/usr/bin/env bash

if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

if [[ -z $(command -v systemctl) ]]; then
    echo "Systemd not found"
    exit 1
fi

if [[ ! -d /etc/systemd/system ]]; then
    echo "Systemd not found"
    exit 1
fi

if [[ -n $(command -v lsb_release) ]]; then
    lsb_name=$(lsb_release -a | awk -F ':' '$1 == "Distributor ID" {print $2}')
    os_name=$(echo "$lsb_name" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
elif [[ -e /etc/os-release ]]; then
    lsb_name=$(awk -F '=' '$1 == "ID" {print $2}' < /etc/os-release 2>/dev/null)
    os_name=$(echo "$lsb_name" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
elif [[ -e /etc/redhat-release ]]; then
    os_name="redhat"
elif [[ -e /etc/fedora-release ]]; then
    os_name="fedora"
elif [[ -e /etc/centos-release ]]; then
    os_name="centos"
else
    os_name="Unknown"
fi

echo "Operating system: $os_name"

case "$os_name" in
    "centos")
        echo "Installing on CentOS"
        ;;
    "fedora")
        echo "Installing on Fedora"
        ;;
    "red*hat")
        echo "Installing on Red Hat"
        ;;

    "armbian")
        echo "Installing on Armbian"
        ;;
    "debian")
        echo "Installing on Debian"
        ;;
    "raspbian")
        echo "Installing on Raspbian"
        ;;
    "ubuntu")
        echo "Installing on Ubuntu"
        ;;
    "zorin")
        echo "Installing on Zorin"
        ;;
    *)
        echo "Unkown operating system"
        exit 1
esac

cp auto-update.service /etc/systemd/system
cp auto-update.timer /etc/systemd/system
cp -T auto-update.apt /usr/sbin/auto-update

systemctl disable auto-update.service &>/dev/null
systemctl disable auto-update.timer &>/dev/null

#if ! systemctl enable auto-update.service; then
#    echo "Failed to enable auto-update.service"
#    exit 1
#fi

if ! systemctl enable auto-update.timer; then
    echo "Failed to enable auto-update.timer"
    exit 1
fi

if ! systemctl start auto-update.timer; then
    echo "Failed to start auto-update.timer"
    exit 1
fi

# Is this needed?
systemctl enable auto-update.service &>/dev/null

if ! systemctl daemon-reload 2>/dev/null; then
    echo "Failed to daemon-reload"
fi

if ! systemctl reset-failed; then
    echo "Failed to reset-failed"
fi

echo "Installed services"
exit 0
