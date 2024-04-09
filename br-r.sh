#!/bin/bash
nmcli con modify ens18 ipv6.method manual ipv6.addresses 2024:2::2/64
nmcli con modify ens18 ipv6.gateway 2024:2::1
nmcli con modify ens18 ipv4.method manual ipv4.addresses 2.2.2.2/30
nmcli con modify ens18 ipv4.gateway 2.2.2.1
nmcli con modify ens18 ipv4.dns 8.8.8.8

nmcli con modify Проводное\ подключение\ 1 ipv6.method manual ipv6.addresses FD24:192::1/124
nmcli con modify Проводное\ подключение\ 1 ipv4.method manual ipv4.addresses 192.168.100.1/28

echo -e "net.ipv4.ip_forward=1\nnet.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf
sysctl -p

dnf install -y nftables
echo -e 'table inet my_nat {\n\tchain my_masquerade {\n\ttype nat hook postrouting priority srcnat;\n\toifname "ens18" masquerade\n\t}\n}' > /etc/nftables/br-r.nft
echo 'include "/etc/nftables/br-r.nft"' >> /etc/sysconfig/nftables.conf
systemctl enable --now nftables

nmcli con add type ip-tunnel ifname tun1 mode gre remote 1.1.1.2 local 2.2.2.2
nmcli con modify ip-tunnel-tun1 ipv4.method manual ipv4.addresses 10.10.10.2/30
nmcli con modify ip-tunnel-tun1 ipv6.method manual ipv6.addresses FD24:10::2/64
nmcli connection modify ip-tunnel-tun1 ip-tunnel.ttl 64
sed -i '11i\parent=ens18' /etc/NetworkManager/system-connections/ip-tunnel-tun1.nmconnection
sed -i '/id=ip-tunnel-tun1/d' /etc/NetworkManager/system-connections/ip-tunnel-tun1.nmconnection
sed -i '2i\id=tun1' /etc/NetworkManager/system-connections/ip-tunnel-tun1.nmconnection




