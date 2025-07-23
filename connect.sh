#!/bin/bash

sudo systemctl start openvpn-client@$1
echo "Connecting to: $1"
sed -i "s/^\(VPN_COUNTRY=\).*/\1$1/" "/home/$USER/.env"