# OSGA Shield - Raspberry Pi Setup Documentation

## Project Overview
OSGA Shield is an open hardware platform for creative coding and generative art, designed to work with the OSGA software platform on Raspberry Pi Zero 2 W.

## Hardware Configuration (Updated)
- **Display**: ILI9341 320x240 SPI LCD
- **Audio**: PCM5102A I2S DAC
- **Input**: 2 buttons (A, B) + Rotary encoder with button
- **Sensors**: MPU6050 (6-axis IMU)
- **Expansion**: Grove I2C connector for additional modules
- **Touch**: ADS7846 resistive touchscreen controller

## Pin Mapping (Raspberry Pi Zero 2 WH)

### I²C Buses
- **I²C1** (Hardware): MPU6050
  - SDA: GPIO2 (Pin 3)
  - SCL: GPIO3 (Pin 5)
- **I²C** (Software): Grove Connector
  - SDA: GPIO22 (Pin 15)
  - SCL: GPIO23 (Pin 16)

### Audio (I²S)
- BCK: GPIO18 (Pin 12)
- LRCK: GPIO19 (Pin 35)
- DIN: GPIO20 (Pin 38)
- DOUT: GPIO21 (Pin 40)

### Display (SPI)
- CS: GPIO8 (Pin 24)
- MISO: GPIO9 (Pin 21)
- MOSI: GPIO10 (Pin 19)
- SCLK: GPIO11 (Pin 23)
- DC: GPIO24 (Pin 18)
- RESET: GPIO25 (Pin 22)
- LED: GPIO12 (Pin 32) - Backlight PWM

### Input Controls
- Button_A: GPIO6 (Pin 31)
- Button_B: GPIO5 (Pin 29)
- Rotary_CLK: GPIO16 (Pin 36)
- Rotary_DT: GPIO13 (Pin 33)
- Rotary_Enter: GPIO26 (Pin 37)

## Installation on Raspberry Pi (wren.local)

### Initial Setup
1. **Base System**: Raspberry Pi OS Lite (no desktop needed for production)
2. **Display Driver**: Using fbtft kernel module (native DRM/KMS support)
3. **GPU Driver**: vc4-fkms-v3d enabled for hardware acceleration

### Software Installation Steps

#### 1. Clone Repositories
```bash
cd ~
git clone https://github.com/kurogedelic/osga.git
git clone https://github.com/kurogedelic/osga-shield.git
```

#### 2. Install Dependencies
```bash
sudo apt-get update
sudo apt-get install -y love  # Love2D framework
```

#### 3. Enable GPU Driver
```bash
# Edit /boot/config.txt
sudo sed -i 's/#dtoverlay=vc4-kms-v3d/dtoverlay=vc4-fkms-v3d/' /boot/config.txt
```

#### 4. Configure Touchscreen
Created `/etc/X11/xorg.conf.d/99-calibration.conf`:
```
Section "InputClass"
    Identifier "calibration"
    MatchProduct "ADS7846 Touchscreen"
    Option "Calibration" "3936 227 268 3880"
    Option "SwapAxes" "0"
    Driver "evdev"
EndSection
```

#### 5. Setup Auto-start Service
Created `/etc/systemd/system/osga.service`:
```ini
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
```

Enable service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable osga.service
sudo systemctl start osga.service
```

## Touchscreen Support Implementation

### Issue Identified
- Raspberry Pi touchscreens (like ADS7846) send mouse events, not touch events
- OSGA apps were only handling touch events, not mouse events
- Cursor needed to be hidden for touchscreen use

### Solution Applied
1. **Latest OSGA Update** (Commit: 4cc5c4c)
   - Automatic cursor hiding for touchscreen environments
   - Mouse event support added to runtime

2. **Configuration Changes**
   - SDL environment variables for mouse handling
   - Cursor visibility set to false in osga-run
   - Touch events mapped from mouse input

### GitHub Issue Created
- Issue #2: "Add touchscreen support for Raspberry Pi displays with cursor emulation"
- https://github.com/kurogedelic/osga/issues/2

## Current Status (2025-08-15)

✅ **Working Features:**
- OSGA runtime (osga-run) running on boot
- Touchscreen input working via mouse event emulation
- Auto-start on system boot
- Latest OSGA version with touchscreen support
- All apps accessible through Kumo launcher

⚠️ **Known Limitations:**
- Touch events are handled as mouse clicks (single touch only)
- No multi-touch or gesture support
- Calibration may be needed for different displays

## File Structure

```
osga-shield/
├── firmware/          # Raspberry Pi configuration
│   ├── boot/         # Boot configuration files
│   ├── config/       # System configs (ALSA, Grove I2C)
│   ├── scripts/      # Initialization scripts
│   ├── systemd/      # Service definitions
│   └── install.sh    # Installation script
├── hardware/         # Hardware design files
│   ├── kicad/        # PCB design files
│   ├── bom/          # Bill of materials
│   └── fabrication/  # Manufacturing files
└── README.md         # Project documentation
```

## Troubleshooting

### Touchscreen Not Working
1. Check if touchscreen is detected:
   ```bash
   ls /dev/input/
   cat /proc/bus/input/devices | grep -i touch
   ```

2. Test touch events:
   ```bash
   sudo evtest /dev/input/event0
   ```

3. Verify X11 configuration:
   ```bash
   DISPLAY=:0 xinput list
   ```

### OSGA Not Starting
1. Check service status:
   ```bash
   systemctl status osga
   journalctl -u osga -n 50
   ```

2. Verify Love2D installation:
   ```bash
   love --version  # Should show "LOVE 11.3"
   ```

3. Check GPU driver:
   ```bash
   ls /dev/dri/  # Should show card0, renderD128
   ```

## Development Notes

### Future Improvements
- [ ] Implement proper touch calibration tool
- [ ] Add haptic feedback support (GPIO12 configured but not used)
- [ ] Create hardware test suite for all components
- [ ] Optimize boot time (currently ~10 seconds delay)
- [ ] Add support for BME280 environmental sensor (if added to hardware)

### Repository Links
- OSGA Platform: https://github.com/kurogedelic/osga
- OSGA Shield: https://github.com/kurogedelic/osga-shield
- OSGA Apps: https://github.com/kurogedelic/osga-apps

## Contact
Designed by Leo Kuroshita from Hugelton Instruments (2025)