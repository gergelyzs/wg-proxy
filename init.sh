#! /bin/bash

IPTABLES=/usr/sbin/iptables
SSH_IP=78.131.56.193 

echo "1" > /proc/sys/net/ipv4/ip_forward

$IPTABLES -F

$IPTABLES -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -P FORWARD DROP

if [ -n "$BACKUP_SSH" ]; then
    $IPTABLES -A INPUT -p tcp --dport $BACKUP_SSH -j ACCEPT
fi
$IPTABLES -A INPUT -s $SSH_IP -p tcp --dport 22 -j ACCEPT
$IPTABLES -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -A INPUT -m conntrack --ctstate INVALID -j DROP
$IPTABLES -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT
$IPTABLES -P INPUT DROP

$IPTABLES -t nat -F 

exit 0
