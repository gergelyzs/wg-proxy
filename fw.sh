#! /bin/bash
 
IPTABLES=/usr/sbin/iptables

if [[ ! -e /tmp/$WG_HOST ]]; then
        touch /tmp/$WG_HOST
fi

HOMEIP=$(/usr/bin/dig +short A $WG_HOST)
OLD_HOMEIP=$(cat /tmp/$WG_HOST)
if [[ "$HOMEIP" == "$OLD_HOMEIP" ]];
then
        exit 0
fi

echo $HOMEIP >/tmp/$WG_HOST


$IPTABLES -D FORWARD -d $OLD_HOMEIP -p udp --dport $WG_PORT -j ACCEPT
$IPTABLES -D FORWARD -s $OLD_HOMEIP -p udp --sport $WG_PORT -j ACCEPT
$IPTABLES -A FORWARD -d $HOMEIP -p udp --dport $WG_PORT -j ACCEPT
$IPTABLES -A FORWARD -s $HOMEIP -p udp --sport $WG_PORT -j ACCEPT
$IPTABLES -t nat -D PREROUTING -p udp --dport $WG_PORT -j DNAT --to-destination $OLD_HOMEIP:$WG_PORT
$IPTABLES -t nat -D POSTROUTING -d $OLD_HOMEIP -p udp --dport $WG_PORT -j MASQUERADE
$IPTABLES -t nat -A PREROUTING -p udp --dport $WG_PORT -j DNAT --to-destination $HOMEIP:$WG_PORT
$IPTABLES -t nat -A POSTROUTING -d $HOMEIP -p udp --dport $WG_PORT -j MASQUERADE
