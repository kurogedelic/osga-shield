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

# Export GPIOs for buttons (5, 6)
for gpio in 5 6; do
    echo $gpio > /sys/class/gpio/export 2>/dev/null || true
    echo in > /sys/class/gpio/gpio${gpio}/direction
    chown root:gpio /sys/class/gpio/gpio${gpio}/value
    chmod 660 /sys/class/gpio/gpio${gpio}/value
done

# Export GPIOs for rotary encoder (16, 13, 26)
for gpio in 16 13 26; do
    echo $gpio > /sys/class/gpio/export 2>/dev/null || true
    echo in > /sys/class/gpio/gpio${gpio}/direction
    chown root:gpio /sys/class/gpio/gpio${gpio}/value
    chmod 660 /sys/class/gpio/gpio${gpio}/value
done

# Export GPIO for LCD backlight PWM
echo 12 > /sys/class/gpio/export 2>/dev/null || true
echo out > /sys/class/gpio/gpio12/direction
chown root:gpio /sys/class/gpio/gpio12/value
chmod 660 /sys/class/gpio/gpio12/value

# Export GPIOs for Grove I2C (22, 23) - will be used for software I2C
for gpio in 22 23; do
    echo $gpio > /sys/class/gpio/export 2>/dev/null || true
    echo out > /sys/class/gpio/gpio${gpio}/direction
    echo 1 > /sys/class/gpio/gpio${gpio}/value  # Pull high for I2C
    chown root:gpio /sys/class/gpio/gpio${gpio}/value
    chmod 660 /sys/class/gpio/gpio${gpio}/value
done

# Set I2C permissions
chmod 666 /dev/i2c-1

# Set framebuffer permissions
chmod 666 /dev/fb1 2>/dev/null || true

# Initialize audio
amixer -c 0 set Master 80% 2>/dev/null || true

echo "OSGA Shield hardware initialized"