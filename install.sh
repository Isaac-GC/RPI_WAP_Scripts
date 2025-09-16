#!/bin/bash

# Update system packages
sudo apt update && sudo apt upgrade -y

DEBIAN_FRONTEND=noninteractive sudo apt install iptables-persistent openvpn -y

sudo raspi-config nonint do_wifi_country US

sudo nmcli device wifi hotspot ssid Andre password SomePassword1

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
ip route add 10.42.0.0/24 via 10.42.0.1 dev wlan0 || true
EOF

# Create OpenVPN down script
sudo tee /etc/openvpn/client/down.sh << 'EOF'
#!/bin/bash
# Remove custom routes
ip route del 10.42.0.0/24 via 10.42.0.1 dev wlan0 2>/dev/null || true
EOF

# Make scripts executable
sudo chmod +x /etc/openvpn/client/up.sh
sudo chmod +x /etc/openvpn/client/down.sh

sudo systemctl enable openvpn@client

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