# 📦 STACK 28: PACKAGE MANAGEMENT
## Managing Software on Linux Systems

**What is a Package Manager?** Think of it like an app store for Linux. Instead of downloading .exe files from websites, you use commands to safely install, update, and remove software - with automatic dependency handling!

**Why This Matters:** Package managers are the foundation of Linux software management. They handle dependencies, resolve conflicts, and keep your system secure.

---

## 🔰 Package Management Basics

A **package manager** is a tool that automates the process of installing, upgrading, configuring, and removing software packages.

### The Two Major Families
| Family | Package Format | Package Manager | Examples |
|--------|---------------|-----------------|----------|
| **Debian** | `.deb` | `apt`, `dpkg` | Ubuntu, Debian, Mint |
| **Red Hat** | `.rpm` | `dnf`, `yum`, `rpm` | Fedora, RHEL, CentOS |

**Pro Tip:** If you learn `apt`, you'll understand `dnf` too - they work almost the same way, just different names!

---

## 👥 APT (Debian/Ubuntu)

### Basic Operations
```bash
# Update package lists
sudo apt update

# Upgrade all packages
sudo apt upgrade

# Full upgrade (may remove packages)
sudo apt full-upgrade

# Install a package
sudo apt install nginx

# Remove a package
sudo apt remove nginx

# Remove package and config
sudo apt purge nginx

# Clean up
sudo apt autoremove
sudo apt clean
```

### Searching and Info
```bash
# Search for packages
apt search nginx

# Show package info
apt show nginx

# List installed packages
apt list --installed

# Check if installed
dpkg -l nginx
```

### Package Files
```bash
# Install from .deb file
sudo dpkg -i package.deb

# Fix broken dependencies
sudo apt install -f

# List package contents
dpkg -L nginx

# Find package owning file
dpkg -S /usr/bin/nginx
```

---

## 📦 YUM/DNF (Fedora/RHEL/CentOS)

### Basic Operations
```bash
# Update packages
sudo dnf update

# Upgrade packages
sudo dnf upgrade

# Install package
sudo dnf install nginx

# Remove package
sudo dnf remove nginx

# Clean cache
sudo dnf clean all
```

### Searching
```bash
# Search for packages
dnf search nginx

# List package details
dnf info nginx

# List installed
dnf list installed

# Find package providing file
dnf provides /usr/sbin/nginx
```

### Groups and Modules
```bash
# List available groups
dnf group list

# Install group
sudo dnf group install "Development Tools"

# Enable a module (like Python)
sudo dnf module enable python:3.9
sudo dnf install python
```

---

## 🔧 Snap Packages

### Installing and Managing
```bash
# Install snapd
sudo apt install snapd

# Find snap
snap find nginx

# Install snap
sudo snap install nginx

# List installed snaps
snap list

# Update snap
sudo snap refresh nginx

# Update all snaps
sudo snap refresh

# Remove snap
sudo snap remove nginx
```

### Classic Confinement
```bash
# Install with classic mode (more permissions)
sudo snap install --classic code
```

---

## 🐛 Flatpak Packages

### Basic Operations
```bash
# Install flatpak
sudo apt install flatpak

# Add flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install application
flatpak install flathub org.vim.Master

# Run application
flatpak run org.vim.Master

# List installed
flatpak list

# Update all
flatpak update
```

---

## 🏗️ Building from Source

### Typical Build Process
```bash
# Download source
wget https://example.com/source.tar.gz
tar -xzf source.tar.gz
cd source

# Check for dependencies
./configure

# Build (if no configure)
make

# Install
sudo make install

# Uninstall
sudo make uninstall
```

### CheckInstall
```bash
# Build and create .deb
sudo apt install checkinstall
sudo checkinstall
```

---

## 🗂️ Repository Management

### Adding a Repository (Ubuntu)
```bash
# Add PPA
sudo add-apt-repository ppa:nginx/stable
sudo apt update

# Add repository manually
sudo apt install software-properties-common
sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu focal main"
```

---

## 🎯 Package Examples

### LAMP Stack Installation
```bash
# Update
sudo apt update

# Install Apache
sudo apt install apache2

# Install MySQL
sudo apt install mysql-server
sudo mysql_sec_installation

# Install PHP
sudo apt install php libapache2-mod-php php-mysql

# Install extras
sudo apt install php-fpm php-cli php-curl php-gd php-mbstring php-xml php-xmlrpc
```

### Python Packages
```bash
# Using pip (system)
sudo pip install requests

# Using pip (user)
pip install --user requests

# Virtual environment
python3 -m venv myenv
source myenv/bin/activate
pip install requests

# Upgrade pip
pip install --upgrade pip
```

### Node.js Packages
```bash
# Install npm
sudo apt install nodejs npm

# Global install
sudo npm install -g typescript

# Local install
npm install express

# List installed
npm list
```

---

## 🔍 Troubleshooting

### Fix Broken Packages
```bash
# Ubuntu/Debian
sudo dpkg --configure -a
sudo apt install -f

# Fedora
sudo dnf check
sudo rpm --rebuilddb
```

### Hold a Package (Prevent Update)
```bash
# Hold package
apt-mark hold nginx

# Unhold package
aptmark unhold nginx

# List held packages
apt-mark showhold
```

---

## 📝 Automation with Scripts

### Auto-Install Script
```bash
#!/bin/bash
# install_stack.sh

set -e

echo "Installing LAMP stack..."

# Update
sudo apt update

# Install packages
PACKAGES=(
    apache2
    mysql-server
    php
    libapache2-mod-php
    php-mysql
    php-cli
    curl
)

for package in "${PACKAGES[@]}"; do
    if dpkg -l | grep -q "^ii  $package"; then
        echo "$package already installed"
    else
        echo "Installing $package..."
        sudo apt install -y "$package"
    fi
done

echo "Installation complete!"
systemctl status apache2
```

---

## 🏆 Practice Exercises

### Exercise 1: Install Software
```bash
# Update system
sudo apt update && sudo apt upgrade

# Install vim, curl, wget, htop
sudo apt install vim curl wget htop

# Verify installation
which vim curl wget htop
```

### Exercise 2: Create a Package List
```bash
# Save installed packages
dpkg --get-selections > packages.txt

# Restore on new system
sudo dpkg --set-selections < packages.txt
sudo apt-get dselect-upgrade
```

### Exercise 3: Use CheckInstall
```bash
# Download sample source
wget http://ftp.gnu.org/gnu/hello/hello-2.10.tar.gz
tar -xzf hello-2.10.tar.gz
cd hello-2.10

# Configure and build
./configure
make

# Create .deb package
sudo checkinstall
```

---

## 📋 Package Management Cheat Sheet

### APT Commands
| Command | Action |
|---------|--------|
| `apt update` | Update package lists |
| `apt install pkg` | Install package |
| `apt remove pkg` | Remove package |
| `apt search term` | Search packages |
| `apt show pkg` | Show package info |

### DNF/YUM Commands
| Command | Action |
|---------|--------|
| `dnf update` | Update packages |
| `dnf install pkg` | Install package |
| `dnf remove pkg` | Remove package |
| `dnf search term` | Search packages |

---

## ✅ Stack 28 Complete!

You learned:
- ✅ Package management basics
- ✅ APT (Debian/Ubuntu) commands
- ✅ DNF/YUM (Fedora/RHEL) commands
- ✅ Snap and Flatpak
- ✅ Building from source
- ✅ Repository management
- ✅ Automation scripts

### Next: Stack 29 - CI/CD Pipelines →

---

## 📝 Challenge: Automate Software Installation

Create a script that:
1. Installs your favorite development tools
2. Handles both Debian and Fedora systems
3. Saves the package list for future use
4. Verifies each installation

---

*End of Stack 28*