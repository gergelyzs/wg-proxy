#! /bin/bash
 
IPTABLES=/usr/sbin/iptables

HOMEIP=$(/usr/bin/dig +short A $WG_HOST)
OLD_HOMEIP=$(cat /tmp/homeip)
if [[ "$HOMEIP" == "$OLD_HOMEIP" ]];
then
	exit 0
fi

echo $HOMEIP >/tmp/homeip

echo "1" > /proc/sys/net/ipv4/ip_forward

$IPTABLES -F 

$IPTABLES -A FORWARD -d $HOMEIP -p udp --dport $WG_PORT -j ACCEPT
$IPTABLES -A FORWARD -s $HOMEIP -p udp --sport $WG_PORT -j ACCEPT
$IPTABLES -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -P FORWARD DROP

if [ -n $BACKUP_SSH ]; then
    $IPTABLES -A INPUT -p tcp --dport $BACKUP_SSH -j ACCEPT
fi
$IPTABLES -A INPUT -s $HOMEIP -p tcp --dport 22 -j ACCEPT
$IPTABLES -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
$IPTABLES -A INPUT -m conntrack --ctstate INVALID -j DROP
$IPTABLES -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT
$IPTABLES -P INPUT DROP

$IPTABLES -t nat -F 
$IPTABLES -t nat -A PREROUTING -p udp --dport $WG_PORT -j DNAT --to-destination $HOMEIP:$WG_PORT
$IPTABLES -t nat -A POSTROUTING -d $HOMEIP -p udp --dport $WG_PORT -j MASQUERADE
