#!/bin/bash
# Grove I2C Software Bus Setup Script
# Creates a software I2C bus on GPIO22/23 for Grove connector

set -e

echo "Setting up Grove I2C software bus..."

# Load i2c-gpio module for software I2C
modprobe i2c-gpio

# Create device tree overlay for software I2C on GPIO22/23
cat > /tmp/i2c-gpio.dts << 'EOF'
/dts-v1/;
/plugin/;

/ {
    compatible = "brcm,bcm2835";

    fragment@0 {
        target-path = "/";
        __overlay__ {
            i2c_gpio: i2c@0 {
                compatible = "i2c-gpio";
                gpios = <&gpio 22 0 /* sda */
                         &gpio 23 0 /* scl */
                        >;
                i2c-gpio,delay-us = <2>;
                i2c-gpio,scl-open-drain;
                i2c-gpio,sda-open-drain;
                #address-cells = <1>;
                #size-cells = <0>;
            };
        };
    };
};
EOF

# Compile and load the overlay
dtc -@ -I dts -O dtb -o /tmp/i2c-gpio.dtbo /tmp/i2c-gpio.dts 2>/dev/null || {
    echo "Device tree compiler not found. Installing..."
    apt-get install -y device-tree-compiler
    dtc -@ -I dts -O dtb -o /tmp/i2c-gpio.dtbo /tmp/i2c-gpio.dts
}

# Copy overlay to boot partition
cp /tmp/i2c-gpio.dtbo /boot/overlays/

# Add to config.txt if not already present
if ! grep -q "dtoverlay=i2c-gpio" /boot/config.txt; then
    echo "" >> /boot/config.txt
    echo "# Software I2C for Grove connector" >> /boot/config.txt
    echo "dtoverlay=i2c-gpio,i2c_gpio_sda=22,i2c_gpio_scl=23,bus=3" >> /boot/config.txt
fi

echo "Grove I2C software bus configured. The bus will be available as /dev/i2c-3 after reboot."
echo "To scan for devices on Grove connector: i2cdetect -y 3"