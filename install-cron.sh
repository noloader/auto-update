#!/usr/bin/env bash

export PATH=/sbin:/usr/sbin:/bin:/usr/bin

if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

if [[ ! -d "/etc/cron.daily" ]]; then
    echo "Failed to find cron.daily"
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
        cp -T auto-update.dnf /etc/cron.daily/auto-update
        ;;
    "fedora")
        echo "Installing on Fedora"
        cp -T auto-update.dnf /etc/cron.daily/auto-update
        ;;
    "red*hat")
        echo "Installing on Red Hat"
        cp -T auto-update.dnf /etc/cron.daily/auto-update
        ;;

    "armbian")
        echo "Installing on Armbian"
        cp -T auto-update.apt /etc/cron.daily/auto-update
        ;;
    "debian")
        echo "Installing on Debian"
        cp -T auto-update.apt /etc/cron.daily/auto-update
        ;;
    "ubuntu")
        echo "Installing on Ubuntu"
        cp -T auto-update.apt /etc/cron.daily/auto-update
        ;;
    "zorin")
        echo "Installing on Zorin"
        cp -T auto-update.apt /etc/cron.daily/auto-update
        ;;
    *)
        echo "Unkown operating system"
        exit 1
esac

chmod u+rwx /etc/cron.daily/auto-update
chown root:root /etc/cron.daily/auto-update

# Delete Systemd specific commands
sed -i '/systemd-run/d' /etc/cron.daily/auto-update

# Uncomment shutdown command
sed -i 's/# shutdown/shutdown/g' /etc/cron.daily/auto-update

echo "Installed service"
exit 0
