# 🫐 STACK 42: RASPBERRY PI PROJECTS [ELECTIVE]
## Automation with Raspberry Pi

**What is a Raspberry Pi?** Think of it as a credit-card-sized computer that costs about as much as a nice dinner. It's a full Linux computer that you can automate, experiment with, and even break without worrying about losing important work!

**Why Learn This?** The Pi is the perfect Linux sandbox: cheap, low power, and endlessly versatile. Many production servers started as Pi prototypes!

---

## 🔰 Introduction to Raspberry Pi

Raspberry Pi is a small, affordable computer for learning and projects.

### Which Pi Should You Use?
| Model | Best For | Analogy |
|-------|----------|---------|
| **Pi Zero** | Low power, tiny projects, IoT | The minimalist - does one thing well |
| **Pi 3/4** | General use, home server, learning | The Swiss Army knife - does everything well |
| **Pi 400** | Desktop replacement, learning to code | The all-in-one - computer built into keyboard |

### Real-World Pi Projects You Can Script
```
Home automation server  →  Bash scripts control lights, temperature
Personal cloud/NAS      →  Backup scripts, sync automation
Web server              →  Deploy scripts, monitoring
Network monitor         →  Alert scripts for internet outages
Ad blocker (Pi-hole)    →  Automated blocklist updates
```

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

## 🎓 Final Project: Raspberry Pi Infrastructure Manager

Now that you've mastered the hardware basics of the Raspberry Pi, let's see how a professional maker or IoT engineer might build a tool to manage their devices. We'll examine the "Pi Manager" — a utility that monitors system health, controls physical GPIO pins, and organizes your electronic projects.

### What the Raspberry Pi Infrastructure Manager Does:
1. **Audits Hardware Health** by monitoring CPU temperature and uptime.
2. **Displays Model Information** so you know exactly which version of the Pi you are using.
3. **Controls GPIO Pins** (Read/Write/Mode) directly from the command line without writing Python.
4. **Audits Overclock Settings** to ensure your Pi is running at the intended speed.
5. **Manages Project Directories** to keep your code and hardware designs organized.
6. **Simplifies Hardware Prototyping** by providing a consistent interface for sensors and actuators.

### Key Snippet: Monitoring CPU Temperature
Keeping your Pi cool is critical for its lifespan. The manager uses the `vcgencmd` tool (native to Raspbian) to get precise readings.

```bash
cmd_temp() {
    echo "Current CPU Temperature:"
    # vcgencmd is the official tool for Pi hardware info
    # We fallback to /sys if vcgencmd isn't available
    vcgencmd measure_temp 2>/dev/null || \
        awk '{print $1/1000 "°C"}' /sys/class/thermal/thermal_zone0/temp
}
```

### Key Snippet: GPIO Control with Bash
Instead of opening a complex Python environment just to turn on an LED, the manager uses the `gpio` command-line utility.

```bash
cmd_gpio_write() {
    local pin=$1
    local value=$2 # 1 for ON, 0 for OFF
    
    # 1. Set the pin mode to 'output'
    gpio -g mode "$pin" out
    
    # 2. Write the value to the physical pin
    gpio -g write "$pin" "$value"
    
    log "GPIO Pin $pin set to $value successfully!"
}
```

**Pro Tip:** Automation tools like this allow you to build "headless" (no screen) IoT devices that can be controlled entirely through SSH scripts!

---

## ✅ Stack 42 Complete!

Congratulations! You've successfully bridged the gap between code and the physical world! You can now:
- ✅ **Setup and manage** Raspberry Pi hardware like a professional maker
- ✅ **Monitor system health** (Temperature, CPU, Uptime) using specialized tools
- ✅ **Control GPIO pins** to interact with LEDs, sensors, and motors
- ✅ **Automate hardware tasks** using Bash scripts and Cron
- ✅ **Organize electronic projects** with consistent directory structures
- ✅ **Build headless IoT devices** that run your code on autopilot

### What's Next?
In the next stack, we'll dive into **WSL (Windows Subsystem for Linux)**. You'll learn how to bring the full power of Linux directly into your Windows desktop environment!

**Next: Stack 43 - Windows WSL →**

---

*End of Stack 42*