#!/bin/bash

source "/home/$USER/.env"
sudo systemctl stop openvpn-client@$VPN_COUNTRY
sed -i "s/^\(VPN_COUNTRY=\).*/\1/" "/home/$USER/.env"