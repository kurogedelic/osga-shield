# OSGA Shield Project Structure

## Directory Organization

```
osga-shield/
├── CLAUDE.md                 # Setup documentation and troubleshooting guide
├── README.md                 # Project overview and pin mappings
├── PROJECT_STRUCTURE.md      # This file - project organization guide
├── firmware/                 # Raspberry Pi OS configuration and software
│   ├── README.md            # Firmware installation guide
│   ├── install.sh           # Complete installation script
│   ├── boot/                # Boot configuration files
│   │   ├── config.txt       # Hardware configuration for Pi
│   │   └── cmdline.txt      # Kernel command line parameters
│   ├── config/              # System configuration files
│   │   ├── asound.conf      # ALSA audio configuration for PCM5102
│   │   └── grove-i2c.conf   # Grove connector I2C bus settings
│   ├── scripts/             # System initialization scripts
│   │   ├── grove-i2c-setup.sh   # Software I2C setup for Grove
│   │   ├── osga-init.sh     # Hardware initialization script
│   │   └── osga-splash      # Boot splash screen script
│   └── systemd/             # SystemD service definitions
│       ├── osga.service     # Main OSGA auto-start service
│       └── osga-early.service   # Early boot display service
└── hardware/                # Hardware design files
    ├── README.md            # Hardware documentation
    ├── kicad/               # KiCad PCB design files
    │   ├── osga.kicad_pro   # Main project file
    │   ├── osga.kicad_sch   # Schematic design
    │   ├── osga.kicad_pcb   # PCB layout
    │   └── *.kicad_sym      # Symbol libraries
    ├── bom/                 # Bill of Materials
    ├── fabrication/         # Gerber files for PCB manufacturing
    └── 3d-models/           # 3D models for enclosure design
```

## Key Components

### Firmware (Software)
- **Raspberry Pi OS Lite** - Minimal OS without desktop environment
- **OSGA Runtime** - Creative coding platform via Love2D
- **SystemD Services** - Auto-start configuration
- **Hardware Drivers** - I2S audio, SPI display, I2C sensors

### Hardware Design
- **KiCad Project** - Complete PCB design files
- **Manufacturing Files** - Ready for PCB fabrication
- **Component Lists** - BOM for assembly

## Usage

### For Users (Installation)
1. Flash Raspberry Pi OS Lite to SD card
2. Clone this repository on the Pi
3. Run `firmware/install.sh` as root
4. System will auto-configure and start OSGA

### For Developers (Hardware)
1. Open `hardware/kicad/osga.kicad_pro` in KiCad
2. Modify schematic and PCB as needed
3. Export gerber files to `hardware/fabrication/`
4. Update BOM in `hardware/bom/`

### For Documentation
- **CLAUDE.md** - Complete setup guide and troubleshooting
- **README.md** - Quick overview and pin mappings
- **firmware/README.md** - Software installation details
- **hardware/README.md** - Hardware specifications

## Version Control
- All design files are version controlled
- KiCad libraries included in repository
- Firmware scripts tested on Raspberry Pi Zero 2 W
- Documentation updated with each hardware revision

## License
- **Hardware**: CERN Open Hardware License v2
- **Software**: LGPL v3 (matching OSGA platform)