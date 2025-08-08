#!/bin/bash
# OSGA Shield Hardware Initialization Script

set -e

echo "Initializing OSGA Shield hardware..."

# Load kernel modules
modprobe i2c-dev
modprobe spi-bcm2835
modprobe fbtft_device name=ili9341 rotate=90

# Set GPIO permissions
chown root:gpio /sys/class/gpio/export /sys/class/gpio/unexport
chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport

# Export GPIOs for buttons and encoder
for gpio in 5 6 13 17 22 27; do
    echo $gpio > /sys/class/gpio/export 2>/dev/null || true
    echo in > /sys/class/gpio/gpio${gpio}/direction
    chown root:gpio /sys/class/gpio/gpio${gpio}/value
    chmod 660 /sys/class/gpio/gpio${gpio}/value
done

# Export GPIO for haptic feedback
echo 12 > /sys/class/gpio/export 2>/dev/null || true
echo out > /sys/class/gpio/gpio12/direction
chown root:gpio /sys/class/gpio/gpio12/value
chmod 660 /sys/class/gpio/gpio12/value

# Set I2C permissions
chmod 666 /dev/i2c-1

# Set framebuffer permissions
chmod 666 /dev/fb1 2>/dev/null || true

# Initialize audio
amixer -c 0 set Master 80% 2>/dev/null || true

echo "OSGA Shield hardware initialized"