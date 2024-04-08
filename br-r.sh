#!/bin/bash
nmcli con modify Проводное\ подключение\ 1 ipv6.method manual ipv6.addresses 2024:2::2/64
nmcli con modify Проводное\ подключение\ 1 ipv6.method manual ipv6.gateway 2024:2::1
nmcli con modify Проводное\ подключение\ 1 ipv4.method manual ipv4.addresses 2.2.2.2/30
nmcli con modify Проводное\ подключение\ 1 ipv4.method manual ipv4.gateway 2.2.2.1

nmcli con modify Проводное\ подключение\ 2 ipv6.method manual ipv6.addresses FD24:192::1/124
nmcli con modify Проводное\ подключение\ 2 ipv4.method manual ipv4.addresses 192.168.100.1/28





