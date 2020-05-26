#!/usr/bin/env bash

export PATH=/sbin:/usr/sbin:/bin:/usr/bin

if [[ "$EUID" -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

cron_dir=
if [[ -d "/etc/cron.daily" ]]; then
    cron_dir="$cron_dir"
elif [[ -d "/var/spool/cron/crontabs" ]]; then
    cron_dir="/var/spool/cron/crontabs"
	# Crontab file is /var/spool/cron/crontabs
	# https://docs.oracle.com/cd/E23824_01/html/821-1451/sysrescron-1.html
fi

if [[ -z "$cron_dir" ]]; then
    echo "Failed to find cron.daily"
    exit 1
fi

if [[ -n $(command -v lsb_release) ]]; then
    os_name=$(lsb_release -a | awk -F ':' '$1 == "Distributor ID" {print $2}')
elif [[ -e /etc/os-release ]]; then
    os_name=$(awk -F '=' '$1 == "ID" {print $2}' < /etc/os-release 2>/dev/null)
elif [[ -e /etc/redhat-release ]]; then
    os_name="redhat"
elif [[ -e /etc/fedora-release ]]; then
    os_name="fedora"
elif [[ -e /etc/centos-release ]]; then
    os_name="centos"
elif [[ $(uname -s 2>/dev/null) == "SunOS" ]]; then
    os_name="solaris"
else
    os_name="Unknown"
fi

os_name=$(echo "$os_name" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
echo "Operating system: $os_name"

case "$os_name" in
    "centos")
        echo "Installing on CentOS"
        cp -T auto-update.dnf "$cron_dir/auto-update"
        ;;
    "fedora")
        echo "Installing on Fedora"
        cp -T auto-update.dnf "$cron_dir/auto-update"
        ;;
    "red*hat")
        echo "Installing on Red Hat"
        cp -T auto-update.dnf "$cron_dir/auto-update"
        ;;

    "armbian")
        echo "Installing on Armbian"
        cp -T auto-update.apt "$cron_dir/auto-update"
        ;;
    "debian")
        echo "Installing on Debian"
        cp -T auto-update.apt "$cron_dir/auto-update"
        ;;
    "ubuntu")
        echo "Installing on Ubuntu"
        cp -T auto-update.apt "$cron_dir/auto-update"
        ;;
    "zorin")
        echo "Installing on Zorin"
        cp -T auto-update.apt "$cron_dir/auto-update"
        ;;
    "linaro")
        echo "Installing on Linaro"
        cp -T auto-update.apt "$cron_dir/auto-update"
        ;;
    "solaris")
        echo "Installing on Solaris"
        cp auto-update.solaris "$cron_dir/auto-update"
        ;;
    *)
        echo "Unkown operating system"
        exit 1
esac

chmod u+rwx "$cron_dir/auto-update"
chown root:root "$cron_dir/auto-update"

# Delete Systemd specific commands
sed '/systemd-run/d' "$cron_dir/auto-update" > "$cron_dir/auto-update.new"
mv "$cron_dir/auto-update.new" "$cron_dir/auto-update"

# Uncomment shutdown command
sed 's/# shutdown/shutdown/g' "$cron_dir/auto-update" > "$cron_dir/auto-update.new"
mv "$cron_dir/auto-update.new" "$cron_dir/auto-update"

# Hack for Solaris
if [[ "$os_name" == "solaris" ]]; then
    mv "$cron_dir/auto-update" "/usr/sbin/auto-update"
	if [[ $(grep -i -c auto-update "$cron_dir/root") -eq 0 ]]
	then
	    echo "Adding crontab entry on Solaris"
		echo "0 4 * * * /bin/sh /usr/sbin/auto-update" >> "$cron_dir/root"
	fi
fi

echo "Installed service"
exit 0
