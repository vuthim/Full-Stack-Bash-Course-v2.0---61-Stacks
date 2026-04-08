# 🪟 STACK 43: WINDOWS WSL [ELECTIVE]
## Running Linux on Windows

**What is WSL?** Think of WSL as a "Linux apartment inside your Windows building." Instead of dual-booting (choosing one or the other) or running a heavy VM (a whole separate building), WSL gives you a cozy Linux space that shares resources with Windows!

**Why This Matters?** If you're on Windows but need Linux for development, WSL is the fastest, easiest way to get a real Linux terminal without leaving Windows.

---

## 🔰 What is WSL?

Windows Subsystem for Linux (WSL) lets you run Linux on Windows without a virtual machine.

### WSL 1 vs WSL 2 (Which Should You Use?)
| Feature | WSL 1 | WSL 2 | **Winner** |
|---------|-------|-------|------------|
| **Speed** | Fast startup | Faster overall | WSL 2 |
| **File I/O** | Good for Windows files | Great for Linux files | Depends on use case |
| **Full Linux kernel** | ❌ | ✅ | WSL 2 |
| **Memory usage** | Less | More (uses actual kernel) | WSL 1 (lightweight) |
| **Cross-OS file access** | Better | Good | WSL 1 for Windows files |
| **Docker support** | Limited | Full | WSL 2 |

**Pro Tip:** Use **WSL 2** for most things (real Linux kernel, Docker support). Use **WSL 1** only if you need fast access to Windows files from Linux.

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

## 🎓 Final Project: WSL Distribution Manager

Now that you've mastered the integration between Windows and Linux, let's see how a professional developer might build a tool to manage multiple WSL environments. We'll examine the "WSL Manager" — a script that simplifies starting, stopping, and installing different Linux distributions on your Windows machine.

### What the WSL Distribution Manager Does:
1. **Lists All Distros** and their current status (Running vs. Stopped) using a single command.
2. **Simplifies Lifecycle Management** (Start, Stop, Restart) without typing complex `wsl.exe` flags.
3. **Automates New Installs** by pulling specific distributions from the Microsoft Store.
4. **Handles System Updates** for the WSL kernel itself.
5. **Sets Default Environments** so your terminal always opens your favorite Linux.
6. **Bridges Windows and Linux** by wrapping the native `wsl` executable in a clean Bash interface.

### Key Snippet: Listing Distro Status
The manager uses the `--list --verbose` flags to give you a clear picture of which versions of Linux are currently consuming resources on your machine.

```bash
cmd_list() {
    echo "=== Installed WSL Distributions ==="
    # Calls the Windows wsl executable from within the shell
    wsl --list --verbose
}
```

### Key Snippet: Stopping a Distro
Sometimes a Linux process might hang, or you simply want to reclaim RAM. The manager makes "killing" a distribution easy.

```bash
cmd_stop() {
    local distro=$1
    echo "Stopping $distro..."
    
    # -t: Terminate the specific distribution
    wsl -t "$distro"
    log "WSL Distribution '$distro' has been shut down."
}
```

**Pro Tip:** Using a manager like this allows you to quickly switch between different Linux environments (like Ubuntu for dev and Kali for security) without leaving your primary shell!

---

## ✅ Stack 43 Complete!

Congratulations! You've successfully merged the power of Linux with the convenience of Windows! You can now:
- ✅ **Setup and configure WSL 2** for maximum performance
- ✅ **Access Windows files** from Linux and vice-versa seamlessly
- ✅ **Manage multiple distributions** like a pro developer
- ✅ **Run Linux GUI apps** directly on your Windows desktop
- ✅ **Automate distribution lifecycle** using the WSL CLI
- ✅ **Optimized your dev environment** by combining the best of both worlds

### What's Next?
In the next stack, we'll dive into **ShellCheck & Best Practices**. You'll learn how to use automated tools to "lint" your scripts and catch thousands of common bugs before they ever run!

**Next: Stack 44 - ShellCheck & Best Practices →**

---

*End of Stack 43*