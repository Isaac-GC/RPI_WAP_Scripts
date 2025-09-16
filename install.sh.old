#!/bin/bash

# Update system packages
sudo apt update && sudo apt upgrade -y

DEBIAN_FRONTEND=noninteractive sudo apt install hostapd dnsmasq iptables-persistent openvpn dhcpd -y

sudo systemctl stop hostapd
sudo systemctl stop dnsmasq

# Disable wpa_supplicant as it interferes with hostapd
sudo systemctl disable wpa_supplicant
sudo systemctl stop wpa_supplicant

# Configure static IP for wifi access point
sudo tee -a /etc/dhcpcd.conf << EOF

# Static IP configuration for wlan0
interface wlan0
    static ip_address=10.55.0.1/24
    nohook wpa_supplicant
EOF

sudo raspi-config nonint do_wifi_country US

# Configure hostapd 
sudo tee /etc/hostapd/hostapd.conf << EOF
interface=wlan0
driver=nl80211
ssid=Andre
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=SomePassword1
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
country_code=US
EOF

sudo tee -a /etc/default/hostapd << EOF
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF

# Configure dnsmasq (DHCP server)
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo tee /etc/dnsmasq.conf << EOF
interface=wlan0
dhcp-range=10.55.0.2,10.55.0.20,255.255.255.0,24h
EOF

# Enable IP forwarding
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf

# Configure iptables for traffic routing through OpenVPN
sudo iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
sudo iptables -A FORWARD -i tun0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i wlan0 -o tun0 -j ACCEPT

# Block direct internet access (force all traffic through VPN)
sudo iptables -A FORWARD -i wlan0 -o eth0 -j DROP
sudo iptables -A FORWARD -i wlan0 -o wlan1 -j DROP

# Save iptables rules
sudo netfilter-persistent save

# Create OpenVPN client configuration directory
sudo mkdir -p /etc/openvpn/client

# Create OpenVPN up script to handle routing
sudo tee /etc/openvpn/client/up.sh << 'EOF'
#!/bin/bash

TUN_IF="$1"

# Flush existing rules for clean slate
iptables -F FORWARD
iptables -t nat -F POSTROUTING

# Enable masquerading through tun0
iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE

# Allow forwarding between wlan0 and tun0
iptables -A FORWARD -i tun0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o tun0 -j ACCEPT

# Block direct internet access
iptables -A FORWARD -i wlan0 -o eth0 -j DROP
iptables -A FORWARD -i wlan0 ! -o tun0 -j DROP

# Add route for access point subnet through tun0
ip route add 10.55.0.0/24 via 10.55.0.1 dev wlan0 || true
EOF

# Create OpenVPN down script
sudo tee /etc/openvpn/client/down.sh << 'EOF'
#!/bin/bash
# Remove custom routes
ip route del 10.55.0.0/24 via 10.55.0.1 dev wlan0 2>/dev/null || true
EOF

# Make scripts executable
sudo chmod +x /etc/openvpn/client/up.sh
sudo chmod +x /etc/openvpn/client/down.sh

# Unmask service (JIC)
sudo systemctl unmask hostapd
sudo systemctl unmask dnsmasq

# Enable services
sudo systemctl enable hostapd
sudo systemctl enable dnsmasq
sudo systemctl enable openvpn@client

# Start services
sudo systemctl start hostapd
sudo systemctl start dnsmasq

#############################
# Install the helper scripts

SCRIPTS_DIR=$HOME/.scripts

mkdir -p $SCRIPTS_DIR

tee $SCRIPTS_DIR/connect.sh << 'EOF'
#!/bin/bash

sudo systemctl start openvpn-client@$1
echo "Connecting to: $1"
sed -i "s/^\(VPN_COUNTRY=\).*/\1$1/" "/home/$USER/.env"
EOF

chmod +x $SCRIPTS_DIR/connect.sh


tee $SCRIPTS_DIR/disconnect.sh << 'EOF'
#!/bin/bash

source "/home/$USER/.env"
sudo systemctl stop openvpn-client@$VPN_COUNTRY
sed -i "s/^\(VPN_COUNTRY=\).*/\1/" "/home/$USER/.env"
EOF

chmod +x $SCRIPTS_DIR/disconnect.sh


# Add the aliases
tee $SCRIPTS_DIR/ovpn_aliases.sh << 'EOF'
alias openvpn-connect='$HOME/.scripts/connect.sh'
alias openvpn-disconnect='$HOME/.scripts/disconnect.sh'
EOF

###
# Make sure the aliases are invoked
# 

if [[ "$SHELL" == *"zsh"* ]]; then
    CONFIG_FILE="$HOME/.zshrc"
    SHELL_NAME="zsh"
elif [[ "$SHELL" == *"bash"* ]]; then
    CONFIG_FILE="$HOME/.bashrc"
    SHELL_NAME="bash"
else
    # Default to bash if shell is unknown
    CONFIG_FILE="$HOME/.bashrc"
    SHELL_NAME="bash (default)"
fi

# Check if "source script.sh" line exists and add it if not
if ! grep -q "source ovpn_aliases.sh" "$CONFIG_FILE"; then
    echo "source $SCRIPTS_DIR/ovpn_aliases.sh" >> "$CONFIG_FILE"
    # echo "Added 'source script.sh' to $CONFIG_FILE"
else
    echo "'source script.sh' already exists in $CONFIG_FILE"
fi

# If no $HOME/.env file... create it JIC
if [ ! -f $HOME/.env ]; then touch $HOME/.env; fi

# Disable openvpn and openvpn@client (not necessary for what we are doing here)
sudo systemctl disable openvpn openvpn@client
sudo systemctl stop openvpn openvpn@client
