# 🌐 STACK 34: NETWORK FILE SYSTEMS
## NFS, Samba, and SSHFS

**What are Network File Systems?** Think of them like a shared Google Drive, but for Linux/Windows servers. Instead of copying files between machines, you mount a remote folder so it appears as if it's on your own computer!

**Why This Matters:** Network file sharing is essential for collaborative work, centralized storage, and backup systems. Every IT team needs at least one of these!

---

## 🔰 Network File Systems

Network file systems allow sharing files between computers over a network.

### Which One Should You Use?
| System | Protocol | Best For | Analogy |
|--------|----------|----------|---------|
| **NFS** | NFS | Unix/Linux ↔ Unix/Linux | A bridge between Linux servers |
| **Samba** | SMB/CIFS | Windows ↔ Linux sharing | A translator between Windows and Linux |
| **SSHFS** | SSH | Quick, secure access | A secure tunnel for files |

**Pro Tip:** 
- Linux-to-Linux? Use **NFS** (fastest)
- Windows and Linux need to share? Use **Samba**
- Need quick, one-time access? Use **SSHFS** (easiest setup)

---

## 📂 NFS (Network File System)

### Server Setup
```bash
# Install NFS server
sudo apt install nfs-kernel-server

# Create export directory
sudo mkdir -p /share/data
sudo chown nobody:nogroup /share/data

# Edit exports
sudo nano /etc/exports

# Add line:
# /share/data    *(rw,sync,no_subtree_check)
```

### Export Options
```
/share/data    *(rw,sync,no_subtree_check)
192.168.1.0/24(rw,sync,no_root_squash)
/home/user     192.168.1.100(ro,sync)
```

```bash
# Export
sudo exportfs -a

# Restart service
sudo systemctl restart nfs-kernel-server
```

### Client Setup
```bash
# Install NFS client
sudo apt install nfs-common

# Create mount point
sudo mkdir -p /mnt/nfs/share

# Mount manually
sudo mount -t nfs server:/share/data /mnt/nfs/share

# Mount on boot (fstab)
echo "server:/share/data /mnt/nfs/share nfs defaults 0 0" | sudo tee -a /etc/fstab
```

---

## 🪟 Samba (SMB/CIFS)

### Server Setup
```bash
# Install Samba
sudo apt install samba

# Backup config
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Edit config
sudo nano /etc/samba/smb.conf
```

### Simple Configuration
```ini
[global]
   workgroup = WORKGROUP
   security = user
   map to guest = bad user

[share]
   path = /srv/samba/share
   browsable = yes
   writable = yes
   guest ok = yes
   create mask = 0777
   directory mask = 0777
```

```bash
# Create share directory
sudo mkdir -p /srv/samba/share
sudo chmod 777 /srv/samba/share

# Create Samba user
sudo smbpasswd -a username

# Restart
sudo systemctl restart smbd
```

### Client Access
```bash
# From Linux
sudo apt install cifs-utils
sudo mount -t cifs //server/share /mnt/share -o user=username

# From Windows
# \\server\share
```

---

## 🔐 SSHFS

### Install
```bash
# Install SSHFS
sudo apt install sshfs

# Load FUSE module
sudo modprobe fuse
```

### Mount
```bash
# Create mount point
mkdir -p ~/remote

# Mount via SSH
sshfs user@server:/remote/path ~/remote

# With key authentication
sshfs -o identity_file=~/.ssh/key user@server:/path ~/remote

# Unmount
fusermount -u ~/remote
```

### Auto-Mount (fstab)
```bash
# Add to /etc/fstab
user@server:/remote/path /mnt/remote fuse.sshfs defaults,_netdev 0 0
```

---

## 🔧 Comparison

### When to Use Each

| Use Case | Recommendation |
|----------|----------------|
| Linux-to-Linux | NFS |
| Windows-to-Linux | Samba |
| Secure/Cloud | SSHFS |
| High Performance | NFS |
| Mixed Environment | Samba |

### Performance Notes
- NFS: Fastest for local networks
- Samba: Good for mixed Windows/Linux
- SSHFS: Slower, but encrypted and simple

---

## 🏆 Practice Exercises

### Exercise 1: Setup NFS Server
```bash
# Install
sudo apt install nfs-kernel-server

# Export directory
echo "/tmp/nfs_test *(rw,sync)" | sudo tee /etc/exports

# Export
sudo exportfs -a

# Verify
showmount -e localhost
```

### Exercise 2: Mount NFS
```bash
# Mount
sudo mount -t nfs localhost:/tmp/nfs_test /mnt/test

# Verify
df -h /mnt/test
ls /mnt/test

# Unmount
sudo umount /mnt/test
```

### Exercise 3: Use SSHFS
```bash
# Mount home directory
sshfs localhost: ~/ssh_home

# List files
ls ~/ssh_home

# Unmount
fusermount -u ~/ssh_home
```

---

## 📋 Commands Cheat Sheet

### NFS
| Command | Action |
|---------|--------|
| `exportfs` | List exports |
| `showmount` | Show mounts |
| `mount -t nfs` | Mount NFS |

### Samba
| Command | Action |
|---------|--------|
| `smbpasswd` | Add user |
| `testparm` | Test config |
| `smbclient` | Client |

### SSHFS
| Command | Action |
|---------|--------|
| `sshfs` | Mount |
| `fusermount` | Unmount |

---

## ✅ Stack 34 Complete!

You learned:
- ✅ NFS server and client setup
- ✅ Samba configuration
- ✅ SSHFS mounting
- ✅ When to use each

### Next: Stack 35 - Firewall & Security →

---

*End of Stack 34*