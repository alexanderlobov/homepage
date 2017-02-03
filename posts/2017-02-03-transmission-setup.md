---
title: How to setup Transmission torrent client with web interface and logging
tags: transmission,tutorial
language: english
---

This tutorial is about installation and configuration of Transmission torrent
client on Ubuntu 14.04.

## Installation

First, install [Transmission](https://transmissionbt.com/):

    sudo apt-get install transmission-daemon

After that, Transmission web interface should be available on localhost:9091.

Next, I want web interface to be available from other computers in my local
network. My network is very simple: it is just a router that shares Internet via
Wi-Fi. In this case,

1.  configure your router to reserve ip address for the computer with
    Tranmission run. For example, 192.168.1.101. In my case (TP-Link router) it is
    configured in DHCP -> Address Reservation section.


2.  Add a line to /etc/hosts on machines you use to access the web interface:

        192.168.1.101 <desired hostname>

    After that it is possible to use this hostname instead of ip.

3. Change default Transmission password. First, stop the daemon:

        sudo service transmission-daemon stop
    If you do not stop the daemon, it will overwrite the config file and you will lost
    your changes.

    Edit the password

        sudo vim /var/lib/transmission-daemon/info/settings.json

    You need section "rpc-password".

4. Add ip addresses from your network to the white list (in the same config
file, settings.json), for example:

        "rpc-whitelist": "127.0.0.1,192.168.1.*"

5. Start the daemon

        sudo service transmission-daemon start

## Logging

It turns out that Transmission does not write any logs by default. If you want
to have logs, you need further configuration. If you do not want logs, you can
safely skip this section.

You can set log file and log level in transmission-daemon command line options.
As it is a daemon, we need to add this options to
`/etc/default/transmission-daemon` config file.

``` bash
LOGFILE="/var/log/transmission.log"

# Default options for daemon, see transmission-daemon(1) for more options
OPTIONS="--config-dir $CONFIG_DIR --logfile $LOGFILE --log-info"
```

Transmission can not create log file because of lack of rights. So, create log
file and change access rights.

``` bash
touch /var/log/transmission.log
sudo chown debian-transmission /var/log/transmission.log
```

### Log rotation

Add a file `/etc/logrotate.d/transmission` containing
```
/var/log/transmission.log {
        rotate 7
        daily
        missingok
        notifempty
        delaycompress
        compress
}
```

## Reference

Log configuration is based on [this article][log].

[log]: https://shpargalki.org.ua/162/logi-transmission
