#!/usr/bin/env bash

if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root"
    [[ "$0" = "${BASH_SOURCE[0]}" ]] && exit 1 || return 1
fi

if lsb_release -a | grep -q 'Fedora'
then
    echo "Installing on Fedora"
    cp auto-update.service /etc/systemd/system
    cp auto-update.timer /etc/systemd/system
    cp -T auto-update.dnf /usr/sbin/auto-update
elif lsb_release -a | grep -q 'Debian'
then
    echo "Installing on Debian"
    cp auto-update.service /etc/systemd/system
    cp auto-update.timer /etc/systemd/system
    cp -T auto-update.apt /usr/sbin/auto-update
else
    echo "Unkown operating system"
    [[ "$0" = "${BASH_SOURCE[0]}" ]] && exit 1 || return 1
fi

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

[[ "$0" = "${BASH_SOURCE[0]}" ]] && exit 0 || return 0
