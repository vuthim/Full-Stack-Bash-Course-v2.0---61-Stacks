# 🫐 STACK 42: RASPBERRY PI PROJECTS [ELECTIVE]
## Automation with Raspberry Pi

---

## 🔰 Introduction to Raspberry Pi

Raspberry Pi is a small, affordable computer for learning and projects.

### Models
| Model | Use |
|-------|-----|
| Pi Zero | Low power, small projects |
| Pi 3/4 | General use, server |
| Pi 400 | Desktop replacement |

---

## ⚡ Initial Setup

### Installing OS
```bash
# Download Raspberry Pi Imager
# https://www.raspberrypi.com/software/

# Or via command line (Raspberry Pi OS)
sudo apt update
sudo apt install rpi-imager
```

### Headless Setup
```bash
# Enable SSH
touch /boot/ssh

# Add WiFi config
# boot/wpa_supplicant.conf
country=US
network={
    ssid="YourNetwork"
    psk="YourPassword"
}
```

### First Login
```bash
# SSH into Pi
ssh pi@raspberrypi.local
# Default password: raspberry
```

---

## 🏠 Home Automation Scripts

### Script 1: System Monitor
```bash
#!/bin/bash
# monitor.sh - System monitoring

EMAIL="admin@example.com"

# Check temperature
TEMP=$(vcgencmd measure_temp | cut -d= -f2 | cut -d. -f1)
if [ "$TEMP" -gt 70 ]; then
    echo "Warning: Temperature is ${TEMP}C" | mail -s "Pi Alert" $EMAIL
fi

# Check disk space
DISK=$(df -h / | tail -1 | awk '{print $5}' | cut -d% -f1)
if [ "$DISK" -gt 90 ]; then
    echo "Warning: Disk at ${DISK}%" | mail -s "Pi Alert" $EMAIL
fi
```

### Script 2: Backup to USB
```bash
#!/bin/bash
# backup.sh - Backup to USB

USB_PATH="/mnt/backup"
DATE=$(date +%Y%m%d)

# Mount USB drive
mount UUID=xxx $USB_PATH

# Backup home folder
rsync -avz --delete /home/pi/ $USB_PATH/backup_$DATE/

# Cleanup old backups (keep last 7)
cd $USB_PATH
ls -t | tail -n+8 | xargs -r rm -rf
```

---

## 🌡️ Sensor Projects

### Temperature Sensor (DS18B20)
```python
#!/usr/bin/env python3
# temp_sensor.py

import os
import time

# Load modules
os.system('modprobe w1-gpio')
os.system('modprobe w1-therm')

# Read sensor
def read_temp():
    with open('/sys/bus/w1/devices/28-xxxx/w1_slave', 'r') as f:
        lines = f.readlines()
    while lines[0].strip()[-3:] != 'YES':
        time.sleep(0.2)
        # read again
    temp = lines[1].find('t=') + 2
    return float(lines[1][temp:])/1000

while True:
    print(f"Temperature: {read_temp():.1f}°C")
    time.sleep(60)
```

### Motion Detection
```python
#!/usr/bin/env python3
# motion.py

import RPi.GPIO as GPIO
import time

PIR_PIN = 17

GPIO.setmode(GPIO.BCM)
GPIO.setup(PIR_PIN, GPIO.IN)

def motion_callback(channel):
    print("Motion detected!")

try:
    GPIO.add_event_detect(PIR_PIN, GPIO.RISE, callback=motion_callback)
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    GPIO.cleanup()
```

---

## 🚗 Pi Projects Examples

### Air Quality Monitor
```bash
#!/bin/bash
# air_quality.sh

API_KEY="your_api_key"
DEVICE_ID="pi_001"

# Read sensor (example with SDS011)
DATA=$(python3 /opt/sensor/read.py)

# Send to API
curl -X POST "https://api.example.com/data" \
  -H "Authorization: Bearer $API_KEY" \
  -d "device=$DEVICE_ID&pm25=$PM25&pm10=$PM10"
```

### Plant Watering System
```python
#!/usr/bin/env python3
# water_plants.py

import RPi.GPIO as GPIO
import time, schedule

RELAY_PIN = 18

def water_plants():
    print("Watering plants...")
    GPIO.output(RELAY_PIN, GPIO.HIGH)
    time.sleep(60)  # Water for 60 seconds
    GPIO.output(RELAY_PIN, GPIO.LOW)

schedule.every().day.at("07:00").do(water_plants)

# ... rest of script
```

---

## 📸 Camera Projects

### Motion Detection Camera
```bash
#!/bin/bash
# camera.sh

DATE=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="/home/pi/captures"

# Capture photo
raspistill -o $OUTPUT_DIR/photo_$DATE.jpg

# Record video (10 seconds)
raspivid -o $OUTPUT_DIR/video_$DATE.h264 -t 10000
```

---

## 📋 Useful Pi Commands

| Command | Description |
|---------|-------------|
| `raspi-config` | Configuration |
| `vcgencmd` | VideoCore commands |
| `raspistill` | Still camera |
| `raspivid` | Video camera |
| `gpio` | GPIO control |

---

## 🏆 Practice Exercises

### Exercise 1: System Monitor Script
```bash
#!/bin/bash
echo "=== Raspberry Pi Status ==="
echo "Temperature: $(vcgencmd measure_temp | cut -d= -f2)"
echo "Memory: $(free -h | grep Mem)"
echo "Disk: $(df -h / | tail -1)"
echo "Load:$(uptime | awk -F'load average:' '{print $2}')"
```

### Exercise 2: LED Control
```python
import RPi.GPIO as GPIO
import time

LED = 18
GPIO.setmode(GPIO.BCM)
GPIO.setup(LED, GPIO.OUT)

while True:
    GPIO.output(LED, True)
    time.sleep(1)
    GPIO.output(LED, False)
    time.sleep(1)
```

### Exercise 3: Cron Job
```bash
# Add to crontab
crontab -e

# Run monitoring every hour
0 * * * * /home/pi/scripts/monitor.sh
```

---

## ✅ Stack 42 Complete!

You learned:
- ✅ Raspberry Pi setup
- ✅ System monitoring scripts
- ✅ Sensor projects
- ✅ Camera projects
- ✅ Automation
- ✅ GPIO control basics

### Next: Stack 43 - Windows WSL →

---

*End of Stack 42*