# Auto-Update

Auto-Update is a systemd service, systemd time and shell script to update the system and reboot the machine as required. It is intended to close the gap after "automatically install security updates", where other updates are not applied automatically.

We can partially sidestep users by automatically installing security updates. However, distros still prompt users for non-security updates, and many non-technical users don't know what the prompt is or what they should do. This is a usablity problem that many distros have not addressed.

In addition, some security updates are misclassified and not installed automatically. Misclassifying an update happens more often than you expect. Updates are labeled security if the vulnerability was obvious or someone provided a working exploit. Many design problems and memory errors are not investigated and lack an exploit, so they just get fixed and labeled as non-security. Those that are fixed without investigation must be installed manually by the user.

## Debian Setup

First, copy the files of interest to the specified location. Note that `auto-update.apt` is used for Debian-based systems.

```
cp auto-update.service /etc/systemd/system
cp auto-update.timer /etc/systemd/system
cp -T auto-update.apt /usr/sbin/auto-update
```

Second, enable the service and timer:

```
systemctl enable auto-update.service
systemctl enable auto-update.timer
systemctl start auto-update.timer
```

## Red Hat Setup

First, copy the files of interest to the specified location. Note that `auto-update.dnf` is used for Red Hat-based systems.

```
cp auto-update.service /etc/systemd/system
cp auto-update.timer /etc/systemd/system
cp -T auto-update.dnf /usr/sbin/auto-update
```

Second, enable the timer:

```
systemctl enable auto-update.timer
systemctl start auto-update.timer
```

## Service status

Once the files are copied and the service and timer are enabled, you can check the status with the following commands. The timer should show `enabled`.

```
$ systemctl status auto-update.timer
● auto-update.timer - Run auto-update.service once a day
   Loaded: loaded (/etc/systemd/system/auto-update.timer; enabled; vendor prese>
   Active: active (waiting) since Tue 2019-06-18 10:41:42 EDT; 6min ago
   Trigger: Wed 2019-06-19 05:02:25 EDT; 18h left
```

And `auto-update.service`. The service should show `enabled`.

```
$ systemctl status auto-update.service
● auto-update.service - Update the system once a day without user prompts
   Loaded: loaded (/etc/systemd/system/auto-update.service; enabled; vendor pre>
   Active: inactive (dead)
```

## Crontab

You should be able to schedule `/usr/sbin/auto-update` as a cron job under the system account.
