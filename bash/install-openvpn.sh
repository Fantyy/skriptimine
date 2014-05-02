#!/bin/bash
#
# installs openvpn + configures ip masquerading on a vps
#

set -e

if [ $# -ne 4 ]; then
    echo "use: $0 client-hostname vpn-subnet dns-server external-ip"
    echo "example:"
    echo "$0 my-client 10.0.100.0 8.8.8.8 30.120.30.256"
    echo ""
    echo "ip addresses of connected interfaces:"
    ifconfig | grep "inet addr:" | cut -d":" -f2 | cut -d" " -f1 | grep -v -E "^127."
    exit 1
fi

SERVER=$(hostname)
CLIENT=$1
SUBNET=$2
DNS=$3
EXTERNAL=$4

[ -f /etc/openvpn/openvpn.conf ] && {
    echo "/etc/openvpn/openvpn.conf already exists. delete it if you want to continue"
    exit 2; }
[ -d /etc/openvpn/keys ] && {
    echo "/etc/openvpn/keys already exists. delete it if you want to continue"
    exit 2; }
[ -d /etc/openvpn/2.0 ] && {
    echo "/etc/openvpn/2.0 already exists. delete it if you want to continue"
    exit 2; }

yum repolist | grep -E ^rpmforge || {
    echo "rpmforge repo not installed, installing"
    rpm http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.i686.rpm; }
yum list installed | grep -E ^openvpn || {
    echo "openvpn not installed, installing"
    yum -y install openvpn; }
yum list installed | grep -E ^git || {
    echo "git not installed, installing"
    yum -y install git; }

cd ~
git clone https://github.com/OpenVPN/easy-rsa.git -b release/2.x
mv easy-rsa/easy-rsa/2.0/ /etc/openvpn/
rm -rf easy-rsa/
cd /etc/openvpn/2.0
ln -s openssl-1.0.0.cnf openssl.cnf
source ./vars
./clean-all
./build-ca
./build-key-server $SERVER
./build-dh
./build-key $CLIENT
mv /etc/openvpn/2.0/keys/ /etc/openvpn/
cd ~

cat > /etc/openvpn/openvpn.conf << EOF
port 1194
proto udp
dev tap
ca keys/ca.crt
cert keys/$SERVER.crt
key keys/$SERVER.key
dh keys/dh2048.pem
server $SUBNET 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS $DNS"
keepalive 10 120
comp-lzo
max-clients 10
user openvpn
group openvpn
persist-key
persist-tun
log-append openvpn-log
status openvpn-status.log
verb 3
mute 10
EOF

cat /etc/sysctl.conf | grep -E ^"net.ipv4.ip_forward\s*=\s*0" &&
{   echo "net.ipv4.ip_forward set to 0, setting to 1"
    sed -i "/^net.ipv4.ip_forward\s*=\s*0/c\net.ipv4.ip_forward = 1" /etc/sysctl.conf
    sysctl -p; }

iptables -t nat -A POSTROUTING -s $SUBNET -j SNAT --to $EXTERNAL
iptables -t nat -A POSTROUTING -j SNAT --to-source $EXTERNAL
echo "the following iptables rules have been added:"
echo "iptables -t nat -A POSTROUTING -s $SUBNET -j SNAT --to $EXTERNAL"
echo "iptables -t nat -A POSTROUTING -j SNAT --to-source $EXTERNAL"

service openvpn start

echo "all done."
echo "clients need ca.crt/client.crt/client.key"
