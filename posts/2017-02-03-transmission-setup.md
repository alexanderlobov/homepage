---
title: How to setup Transmission torrent client with web interface and logging
tags: transmission,tutorial
language: english
---

This tutorial is about installing and configuring Transmission on Ubuntu 14.04.

## Installing

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
