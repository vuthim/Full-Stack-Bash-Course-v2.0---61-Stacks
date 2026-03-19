# 🪟 STACK 43: WINDOWS WSL [ELECTIVE]
## Running Linux on Windows

---

## 🔰 What is WSL?

Windows Subsystem for Linux (WSL) lets you run Linux on Windows without a virtual machine.

### WSL vs WSL2
| Feature | WSL 1 | WSL 2 |
|---------|-------|-------|
| Speed | Fast | Faster |
| File I/O | Good | Great |
| Full Linux kernel | ❌ | ✅ |
| Memory | Less | More |
| Cross-OS file system | Better | Good |

---

## ⚡ Installing WSL

### Quick Install (Windows 10/11)
```powershell
# Open PowerShell as Admin
wsl --install

# Restart computer
# After restart, Ubuntu will launch

# Set username and password
```

### Manual Install
```powershell
# Enable WSL feature
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Enable Virtual Machine Platform
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Set default to WSL 2
wsl --set-default-version 2

# Install Ubuntu
wsl --install -d Ubuntu-22.04
```

---

## 📚 Basic Commands

### wsl.exe Commands
```powershell
# List installed distros
wsl -l -v

# Run specific distro
wsl -d Ubuntu-22.04

# Set default distro
wsl -s Ubuntu-22.04

# Terminate WSL
wsl --terminate Ubuntu-22.04

# Shutdown all WSL
wsl --shutdown
```

### From Windows Terminal
```powershell
# Open in new window
wsl

# Run command in WSL
wsl ls -la
wsl pwd
wsl cat /etc/os-release
```

---

## 📂 File Access

### From Windows
```powershell
# Access Ubuntu files
# \\wsl$

# In PowerShell:
cd \\wsl$\Ubuntu-22.04\home\username

# Or use the Linux path directly:
C:\Users\YourName\AppData\Local\Packages\...
```

### From Linux (WSL)
```bash
# Access Windows C: drive
cd /mnt/c

# Access Windows home
cd /mnt/c/Users/YourName

# Create shortcut to Windows folder
ln -s /mnt/c/Users/YourName/Documents ~/windows_docs
```

---

## 🔧 Development Setup

### Install Tools
```bash
# Update
sudo apt update && sudo apt upgrade

# Install common tools
sudo apt install -y build-essential git curl wget vim

# Install Docker in WSL 2
# (requires Docker Desktop)
sudo apt install docker.io
sudo usermod -aG docker $USER

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

### VS Code Integration
```bash
# In WSL install remote extension
# Then:
code .
code --folder-uri vscode-remote://wsl+Ubuntu-22.04/home/user/project/
```

---

## ⚙️ Performance Tips

### .wslconfig
```ini
# Create in Windows home: C:\Users\You\.wslconfig

[wsl2]
processors=4
memory=4GB
swap=2GB
localhostForwarding=true

[network]
generateResolvConf=true
```

### Apply Changes
```powershell
# After editing .wslconfig
wsl --shutdown
```

---

## 🔐 WSL Commands Reference

### Important Commands
```bash
# Check version
wsl.exe -l -v

# Export/Import distro
wsl --export Ubuntu ubuntu_backup.tar
wsl --import UbuntuNew ubuntu_backup.tar

# Unregister distro
wsl --unregister Ubuntu
```

---

## 🏆 Practice Exercises

### Exercise 1: Install WSL
```powershell
# Run as Admin in PowerShell
wsl --install -d Ubuntu-22.04
# Restart computer
# Set up user
```

### Exercise 2: Access Files
```bash
# In WSL, access Windows
cd /mnt/c
ls -la

# From PowerShell
wsl ls -la /home
```

### Exercise 3: Docker Setup
```bash
# Install Docker Desktop (Windows)
# Enable WSL2 integration in Docker settings

# In WSL
docker --version
docker ps

# Add user to docker group
sudo usermod -aG docker $USER
```

---

## 📋 WSL vs Virtual Machine

| Feature | WSL | VM |
|---------|-----|-----|
| Resource usage | Low | High |
| Startup time | Fast | Slow |
| Integration | Excellent | Good |
| Full Linux | WSL2 | Yes |
| Dual boot | No | Yes |

---

## ✅ Stack 43 Complete!

You learned:
- ✅ What is WSL
- ✅ Installing WSL 1 and 2
- ✅ Basic commands
- ✅ File access between OS
- ✅ Development setup
- ✅ Performance tips

### Next: Stack 44 - ShellCheck →

---

*End of Stack 43*