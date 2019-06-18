#!/usr/bin/env bash

if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root"
    [[ "$0" = "${BASH_SOURCE[0]}" ]] && exit 1 || return 1
fi

lsb_name=$(lsb_release -a | awk -F ':' '$1 == "Distributor ID" {print $2}')
os_name=$(echo $lsb_name | tr '[:upper:]' '[:lower:]')
echo "Operating system: $os_name"

case "$os_name" in
    "fedora")
        echo "Installing on Fedora"
        cp auto-update.service /etc/systemd/system
        cp auto-update.timer /etc/systemd/system
        cp -T auto-update.dnf /usr/sbin/auto-update
        ;;
    "red hat")
        echo "Installing on Fedora"
        cp auto-update.service /etc/systemd/system
        cp auto-update.timer /etc/systemd/system
        cp -T auto-update.dnf /usr/sbin/auto-update
        ;;
    "debian")
        echo "Installing on Fedora"
        cp auto-update.service /etc/systemd/system
        cp auto-update.timer /etc/systemd/system
        cp -T auto-update.apt /usr/sbin/auto-update
        ;;
    "ubuntu")
        echo "Installing on Fedora"
        cp auto-update.service /etc/systemd/system
        cp auto-update.timer /etc/systemd/system
        cp -T auto-update.apt /usr/sbin/auto-update
        ;;
    *)
        echo "Unkown operating system"
        [[ "$0" = "${BASH_SOURCE[0]}" ]] && exit 1 || return 1
esac

if ! systemctl enable auto-update.service; then
    echo "Failed to enable auto-update.service"
    [[ "$0" = "${BASH_SOURCE[0]}" ]] && exit 1 || return 1
fi

if ! systemctl enable auto-update.timer; then
    echo "Failed to enable auto-update.timer"
    [[ "$0" = "${BASH_SOURCE[0]}" ]] && exit 1 || return 1
fi

if ! systemctl start auto-update.timer; then
    echo "Failed to start auto-update.timer"
    [[ "$0" = "${BASH_SOURCE[0]}" ]] && exit 1 || return 1
fi

echo "Installed services"
[[ "$0" = "${BASH_SOURCE[0]}" ]] && exit 0 || return 0
