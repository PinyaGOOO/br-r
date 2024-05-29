#!/bin/bash
dnf remove -y git
dnf install -y frr
dnf install -y nftables
dnf install -y chrony

nmcli con modify ens18 ipv4.method manual ipv4.addresses 2.2.2.2/30
nmcli con modify ens18 ipv4.gateway 2.2.2.1
nmcli con modify ens18 ipv4.dns 8.8.8.8


nmcli con modify Проводное\ подключение\ 1 ipv4.method manual ipv4.addresses 192.168.100.1/28

echo -e "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

echo -e 'table inet my_nat {\n\tchain my_masquerade {\n\ttype nat hook postrouting priority srcnat;\n\toifname "ens18" masquerade\n\t}\n}' > /etc/nftables/br-r.nft
echo 'include "/etc/nftables/br-r.nft"' >> /etc/sysconfig/nftables.conf
systemctl enable --now nftables

nmcli con add type ip-tunnel ifname tun1 mode gre remote 1.1.1.2 local 2.2.2.2
nmcli con modify ip-tunnel-tun1 ipv4.method manual ipv4.addresses 10.10.10.2/30
nmcli connection modify ip-tunnel-tun1 ip-tunnel.ttl 64
sed -i '11i\parent=ens18' /etc/NetworkManager/system-connections/ip-tunnel-tun1.nmconnection
sed -i '/id=ip-tunnel-tun1/d' /etc/NetworkManager/system-connections/ip-tunnel-tun1.nmconnection
sed -i '2i\id=tun1' /etc/NetworkManager/system-connections/ip-tunnel-tun1.nmconnection


sed -i '/ospfd=no/d' /etc/frr/daemons
sed -i '18i\ospfd=yes' /etc/frr/daemons
sed -i '/ospf6d=no/d' /etc/frr/daemons
sed -i '19i\ospf6d=yes' /etc/frr/daemons
systemctl restart frr
systemctl enable --now frr

vtysh -c "configure terminal" \
    -c "router ospf" \
    -c "passive-interface default" \
    -c "network 192.168.100.0/28 area 0" \
    -c "network 10.10.10.0/30 area 0" \
    -c "exit" \
    -c "interface tun1" \
    -c "no ip ospf network broadcast" \
    -c "no ip ospf passive" \
    -c "exit" \
    -c "do write" 

useradd -c "Branch admin" Branch_admin -U
echo "Branch_admin:P@ssw0rd" | chpasswd
useradd -c "Network Admin" Network_admin -U
echo "Network_admin:P@ssw0rd" | chpasswd

timedatectl set-timezone Europe/Moscow
sed -i '3s/^/#/' /etc/chrony.conf
sed -i '4s/^/#/' /etc/chrony.conf
sed -i '5s/^/#/' /etc/chrony.conf
sed -i '6s/^/#/' /etc/chrony.conf
sed -i '7a\server 172.16.100.1 iburst prefer' /etc/chrony.conf

systemctl enable --now chronyd
systemctl restart chronyd
chronyc sources

mkdir /var/backup-script/

hostnamectl set-hostname BR-R; exec bash


