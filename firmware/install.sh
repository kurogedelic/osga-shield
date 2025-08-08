#!/bin/bash
# OSGA Shield Installation Script for Raspberry Pi OS Lite

set -e

if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo ./install.sh)"
    exit 1
fi

echo "======================================"
echo "OSGA Shield Installation"
echo "======================================"

# Update system
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install minimal dependencies
echo "Installing dependencies..."
apt-get install -y \
    love2d \
    git \
    alsa-utils \
    i2c-tools \
    python3-smbus2 \
    python3-rpi.gpio \
    libsdl2-2.0-0 \
    libsdl2-image-2.0-0 \
    libsdl2-mixer-2.0-0

# Remove unnecessary packages
echo "Removing unnecessary packages..."
apt-get remove -y \
    xserver-* \
    x11-* \
    lightdm \
    lxde-* \
    raspberrypi-ui-mods \
    plymouth \
    triggerhappy \
    || true

apt-get autoremove -y

# Copy boot configuration
echo "Configuring boot..."
cp boot/config.txt /boot/config.txt
cp boot/cmdline.txt /boot/cmdline.txt

# Install systemd services
echo "Installing systemd services..."
cp systemd/osga.service /etc/systemd/system/
cp systemd/osga-early.service /etc/systemd/system/

# Install scripts
echo "Installing scripts..."
cp scripts/osga-splash /usr/local/bin/
cp scripts/osga-init.sh /usr/local/bin/
chmod +x /usr/local/bin/osga-*

# Configure audio
echo "Configuring audio..."
cp config/asound.conf /etc/asound.conf

# Create OSGA directory
echo "Setting up OSGA..."
mkdir -p /home/pi/osga
mkdir -p /usr/share/osga

# Clone OSGA if not exists
if [ ! -d "/home/pi/osga/.git" ]; then
    echo "Cloning OSGA repository..."
    git clone https://github.com/kurogedelic/osga.git /home/pi/osga
    chown -R pi:pi /home/pi/osga
fi

# Add pi user to required groups
echo "Configuring user permissions..."
usermod -a -G gpio,i2c,spi,audio,input pi

# Enable services
echo "Enabling services..."
systemctl daemon-reload
systemctl enable osga-early.service
systemctl enable osga.service

# Create hardware init service
cat > /etc/systemd/system/osga-hardware.service << EOF
[Unit]
Description=OSGA Hardware Initialization
Before=osga.service
After=basic.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/local/bin/osga-init.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl enable osga-hardware.service

# Disable unnecessary services
echo "Disabling unnecessary services..."
systemctl disable bluetooth || true
systemctl disable hciuart || true
systemctl disable avahi-daemon || true
systemctl disable cups || true

# Configure console
echo "Configuring console..."
echo "consoleblank=0" >> /boot/cmdline.txt

# Create splash image converter script
cat > /usr/local/bin/osga-splash-convert << 'EOF'
#!/bin/bash
# Convert image to raw framebuffer format for ILI9341 (320x240 RGB565)
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input.png output.raw"
    exit 1
fi
convert "$1" -resize 320x240! -depth 16 RGB565:"$2"
EOF
chmod +x /usr/local/bin/osga-splash-convert

echo "======================================"
echo "Installation complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Reboot your Raspberry Pi: sudo reboot"
echo "2. OSGA will start automatically on boot"
echo "3. The display will show content via /dev/fb1"
echo ""
echo "To create a splash screen:"
echo "  osga-splash-convert image.png /usr/share/osga/splash.raw"
echo ""
echo "To check service status:"
echo "  systemctl status osga"
echo ""