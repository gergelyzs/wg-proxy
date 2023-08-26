# wg-proxy

This is a small shell script to proxy a wireguard tunnel to dynamic IP endpoint, eg. residential broadbrand subscription. Of course, this needs to be set up on a static IP vps.

## history

Connecting to a dynamic-IP domain name caused regular issues, and the tunnel had to be restarted in case traffic stopped going through. 

Even larger issue was the lack of indication of a problem. If the tunnel stopped working, the issue would only be recognizable by the lack of regular notifications beyond actually not being able to access network resources.

Since the idea of having a vpn connection would be to safeguard personal data, the leak between turning it off and on is not acceptable.

## usage

Clone the repo, and copy the contents to `/root`. 

Add the following to the root users crontab by running `sudo crontab -e`:
```
* *  * * *     WG_HOST=some.dynamic.host WG_PORT=12345 /root/wg-proxy/fw.sh
@reboot        SSH_IP=x.x.x.x [BACKUP_SSH=12345] /root/wg-proxy/init.sh
```

Setting the BACKUP_SSH variable will open an alternative port for SSH, in case you are worried about looking yourself out of the vps. This needs to be added to sshd config as well.

Schedule the script in crontab as frequently as you need.
