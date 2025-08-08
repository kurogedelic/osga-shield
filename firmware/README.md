# OSGA Shield Firmware

## Directory Structure

- **boot/** - Raspberry Pi boot configuration files
- **config/** - System configuration files (ALSA, etc.)
- **scripts/** - Initialization and utility scripts  
- **systemd/** - SystemD service definitions
- **install.sh** - Main installation script

## Installation

1. Flash Raspberry Pi OS Lite to SD card
2. Clone this repository on the Pi
3. Run installation script:
   ```bash
   cd firmware
   sudo ./install.sh
   ```
4. Reboot

## Configuration

The system runs in headless mode with:
- Direct framebuffer access via DRM/KMS
- I2S audio output
- Automatic OSGA startup on boot
- No X11/desktop environment