#!/bin/bash
# OSGA Shield Setup Script for Raspberry Pi 3A+
# Run this script on your Pi 3A+ as: sudo ./install-pi3a+.sh

set -e

echo "=================================================="
echo "OSGA Shield Setup for Raspberry Pi 3A+"
echo "=================================================="

# Detect Pi model
PI_MODEL=$(cat /proc/cpuinfo | grep "Model" | head -1)
echo "Detected Pi Model: $PI_MODEL"

# Update system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install required packages
echo "Installing required packages..."
apt-get install -y git love lua5.1 liblua5.1-0-dev
apt-get install -y alsa-utils pulseaudio pulseaudio-utils
apt-get install -y i2c-tools python3-smbus python3-pip
apt-get install -y xinit xorg lightdm

# Enable required interfaces
echo "Enabling SPI, I2C, and audio interfaces..."
raspi-config nonint do_spi 0
raspi-config nonint do_i2c 0
raspi-config nonint do_camera 1

# Clone OSGA repositories
echo "Cloning OSGA repositories..."
cd /home/pi
if [ ! -d "osga" ]; then
    sudo -u pi git clone https://github.com/kurogedelic/osga.git
fi
if [ ! -d "osga-shield" ]; then
    sudo -u pi git clone https://github.com/kurogedelic/osga-shield.git
fi

# Apply Pi 3A+ specific boot configuration
echo "Applying Pi 3A+ boot configuration..."
cp /home/pi/osga-shield/firmware/boot/config.txt /boot/config.txt

# Set GPU memory for Pi 3A+ (512MB RAM)
sed -i 's/gpu_mem=32/gpu_mem=32/' /boot/config.txt

# Enable vc4-fkms-v3d for better GPU performance on Pi 3
if ! grep -q "dtoverlay=vc4-fkms-v3d" /boot/config.txt; then
    echo "dtoverlay=vc4-fkms-v3d" >> /boot/config.txt
fi

# Configure ALSA for audio
echo "Configuring ALSA audio..."
if [ ! -f /home/pi/.asoundrc ]; then
    cat > /home/pi/.asoundrc << EOF
pcm.!default {
  type hw
  card 0
}
ctl.!default {
  type hw
  card 0
}
EOF
    chown pi:pi /home/pi/.asoundrc
fi

# Create systemd service for auto-start
echo "Creating OSGA auto-start service..."
cat > /etc/systemd/system/osga.service << EOF
[Unit]
Description=OSGA Creative Platform
After=multi-user.target graphical.target
Wants=graphical.target

[Service]
Type=simple
User=pi
Group=pi
Environment="DISPLAY=:0"
Environment="HOME=/home/pi"
Environment="XDG_RUNTIME_DIR=/run/user/1000"
Environment="SDL_MOUSE_RELATIVE=0"
Environment="SDL_MOUSE_FOCUS_CLICKTHROUGH=1"
WorkingDirectory=/home/pi/osga
ExecStartPre=/bin/sleep 10
ExecStart=/usr/bin/love /home/pi/osga/osga-run
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF

# Enable auto-login for pi user
echo "Enabling auto-login..."
systemctl set-default graphical.target
raspi-config nonint do_boot_behaviour B4

# Enable and start OSGA service
echo "Enabling OSGA service..."
systemctl daemon-reload
systemctl enable osga.service

# Set permissions
chown -R pi:pi /home/pi/osga*

echo "=================================================="
echo "Setup complete! The Pi will reboot now."
echo "OSGA will start automatically after boot."
echo "=================================================="

# Reboot
echo "Rebooting in 5 seconds..."
sleep 5
reboot