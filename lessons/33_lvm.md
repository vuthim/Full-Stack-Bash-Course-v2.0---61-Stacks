# 💾 STACK 33: LVM (LOGICAL VOLUME MANAGER)
## Flexible Disk Storage Management

**What is LVM?** Think of LVM as a "storage magician" - it lets you combine multiple physical disks into one big pool, then carve out flexible volumes that you can resize on the fly. No more "disk full" emergencies!

**Why This Matters:** Without LVM, resizing partitions is painful and risky. With LVM, you can grow your storage online (without downtime!) by simply adding more disks.

---

## 🔰 What is LVM?

LVM (Logical Volume Manager) provides logical abstraction over physical disks, allowing:
- ✅ **Resize volumes dynamically** - Grow/shrink without reinstalling
- ✅ **Create snapshots** - Point-in-time backups (great for testing)
- ✅ **Combine multiple disks** - One big pool from many drives
- ✅ **Flexible partition management** - Change sizes on the fly

### LVM Analogy for Beginners
```
Traditional partitions:  Like fixed-size rooms (can't easily expand)
LVM:                     Like modular furniture (add/remove pieces as needed)

Physical Disk 1 ──┐
Physical Disk 2 ──┼──→ Volume Group (storage pool) ──→ Logical Volumes (usable partitions)
Physical Disk 3 ──┘
```

### Key Concepts (Simplified)
| Concept | What It Is | Analogy |
|---------|------------|---------|
| **PV (Physical Volume)** | Raw disk or partition | Individual bricks |
| **VG (Volume Group)** | Pool of storage from multiple PVs | Wall built from bricks |
| **LV (Logical Volume)** | Partition-like volume carved from VG | Windows/doors cut from the wall |

---

## ⚡ Setting Up LVM

### Install LVM
```bash
# Install on Ubuntu/Debian
sudo apt install lvm2

# Install on RHEL/CentOS
sudo yum install lvm2
```

### Create Physical Volume
```bash
# View available disks
lsblk

# Create PV on a partition
sudo pvcreate /dev/sdb1

# Create PV on entire disk (careful!)
sudo pvcreate /dev/sdc

# View PVs
sudo pvs
sudo pvdisplay
```

### Create Volume Group
```bash
# Create VG from one PV
sudo vgcreate vg_data /dev/sdb1

# Add additional PV to VG
sudo vgextend vg_data /dev/sdc

# View VGs
sudo vgs
sudo vgdisplay vg_data
```

---

## 📦 Creating Logical Volumes

### Basic LV Creation
```bash
# Create LV (using all space)
sudo lvcreate -n lv_data -l 100%FREE vg_data

# Create LV with specific size
sudo lvcreate -n lv_data -L 10G vg_data

# Create LV with specific extents
sudo lvcreate -n lv_data -l 256 vg_data

# View LVs
sudo lvs
sudo lvdisplay
```

### Filesystem Creation
```bash
# Create ext4
sudo mkfs.ext4 /dev/vg_data/lv_data

# Create xfs
sudo mkfs.xfs /dev/vg_data/lv_data

# Create btrfs
sudo mkfs.btrfs /dev/vg_data/lv_data
```

### Mounting
```bash
# Mount manually
sudo mount /dev/vg_data/lv_data /mnt/data

# Add to fstab
echo '/dev/vg_data/lv_data /mnt/data ext4 defaults 0 2' | sudo tee -a /etc/fstab
```

---

## 📈 Resizing Volumes

### Extend Logical Volume
```bash
# Extend LV by 5GB
sudo lvextend -L +5G /dev/vg_data/lv_data

# Extend to specific size
sudo lvextend -L 20G /dev/vg_data/lv_data

# Use all available space
sudo lvextend -l +100%FREE /dev/vg_data/lv_data

# Resize filesystem (ext4)
sudo resize2fs /dev/vg_data/lv_data

# Resize filesystem (xfs)
sudo xfs_growfs /mnt/data
```

### Reduce Logical Volume
```bash
# Unmount first
sudo umount /mnt/data

# Check filesystem
sudo e2fsck -f /dev/vg_data/lv_data

# Resize filesystem
sudo resize2fs /dev/vg_data/lv_data 10G

# Reduce LV
sudo lvreduce -L 10G /dev/vg_data/lv_data

# Remount
sudo mount /dev/vg_data/lv_data /mnt/data
```

---

## 📸 LVM Snapshots

### Create Snapshot
```bash
# Create snapshot
sudo lvcreate -n snap_data -s -L 5G /dev/vg_data/lv_data

# View snapshot
sudo lvs
```

### Restore from Snapshot
```bash
# Unmount
sudo umount /mnt/data

# Merge snapshot
sudo lvconvert --merge /dev/vg_data/snap_data

# Remount
sudo mount /dev/vg_data/lv_data /mnt/data
```

### Remove Snapshot
```bash
# Remove snapshot
sudo lvremove /dev/vg_data/snap_data
```

---

## 🗂️ Removing LVM

### Proper Removal
```bash
# Unmount
sudo umount /mnt/data

# Remove LV
sudo lvremove /dev/vg_data/lv_data

# Remove VG
sudo vgremove vg_data

# Remove PV
sudo pvremove /dev/sdb1
```

---

## 🔧 LVM Commands Reference

### Physical Volume
| Command | Action |
|---------|--------|
| `pvcreate` | Create PV |
| `pvdisplay` | Show PV details |
| `pvs` | List PVs |
| `pvremove` | Remove PV |
| `pvscan` | Scan for PVs |

### Volume Group
| Command | Action |
|---------|--------|
| `vgcreate` | Create VG |
| `vgdisplay` | Show VG details |
| `vgs` | List VGs |
| `vgextend` | Add PV to VG |
| `vgreduce` | Remove PV from VG |
| `vgremove` | Remove VG |

### Logical Volume
| Command | Action |
|---------|--------|
| `lvcreate` | Create LV |
| `lvdisplay` | Show LV details |
| `lvs` | List LVs |
| `lvextend` | Extend LV |
| `lvreduce` | Reduce LV |
| `lvremove` | Remove LV |
| `lvrename` | Rename LV |

---

## 🏆 Practice Exercises

### Exercise 1: Set Up LVM
```bash
# Create PV (use a test disk/d partition)
sudo pvcreate /dev/sdb1

# Create VG
sudo vgcreate vg_test /dev/sdb1

# Create LV
sudo lvcreate -n lv_test -L 1G vg_test

# Create filesystem
sudo mkfs.ext4 /dev/vg_test/lv_test

# Mount
sudo mkdir /mnt/test
sudo mount /dev/vg_test/lv_test /mnt/test

# Verify
df -h /mnt/test
```

### Exercise 2: Resize Volume
```bash
# Extend to 2GB
sudo lvextend -L +1G /dev/vg_test/lv_test

# Resize filesystem
sudo resize2fs /dev/vg_test/lv_test

# Verify
df -h /mnt/test
```

### Exercise 3: Create Snapshot
```bash
# Add some data
sudo cp /etc/passwd /mnt/test/

# Create snapshot
sudo lvcreate -s -n snap1 -L 500M /dev/vg_test/lv_test

# Remove original data
sudo rm /mnt/test/passwd

# Merge snapshot to restore
sudo umount /mnt/test
sudo lvconvert --merge /dev/vg_test/snap1

# Remount
sudo mount /dev/vg_test/lv_test /mnt/test

# Verify data is back
ls /mnt/test/
```

---

## 🎓 Final Project: Logical Volume Manager (LVM)

Now that you've mastered the layers of LVM, let's see how a professional storage engineer might automate disk management. We'll examine the "LVM Manager" — a tool that simplifies creating, extending, and snapshotting your disk space.

### What the LVM Manager Does:
1. **Provides a Unified Status** showing Physical Volumes (PV), Volume Groups (VG), and Logical Volumes (LV).
2. **Simplifies Volume Creation** by wrapping complex `pvcreate`, `vgcreate`, and `lvcreate` commands.
3. **Automates Volume Extension** and automatically resizes the underlying filesystem (no extra steps!).
4. **Handles Safety Checks** like unmounting and running `e2fsck` before reducing a volume.
5. **Manages Snapshots** for instant backups and easy restores.
6. **Cleans Up Resources** by safely removing volumes and volume groups when they are no longer needed.

### Key Snippet: Automated Volume Extension
The most common LVM task is growing a disk when it gets full. The manager automates both the LVM part AND the filesystem part.

```bash
cmd_extend() {
    local vg=$1
    local lv=$2
    local size=$3
    
    # 1. Extend the Logical Volume in LVM
    sudo lvextend -L +"$size" "/dev/$vg/$lv"
    
    # 2. Grow the actual filesystem so the OS can use the new space
    # resize2fs works for ext4; for xfs, you'd use xfs_growfs
    sudo resize2fs "/dev/$vg/$lv"
    
    log "Logical Volume $vg/$lv extended by $size successfully!"
}
```

### Key Snippet: Instant Snapshots
Snapshots are like "save points" for your disk. The manager makes creating them a one-word command.

```bash
cmd_snap_create() {
    local lv=$1
    local name=$2
    
    # Create a snapshot (-s) of the logical volume
    # It only stores the CHANGES, so it can be small (1G)
    sudo lvcreate -s -n "$name" -L 1G "/dev/$lv"
    log "Snapshot '$name' created for volume $lv."
}
```

**Pro Tip:** Automation like this is why Linux servers can stay up for years without reboots, even while their disks are being upgraded and swapped!

---

## ✅ Stack 33 Complete!

Congratulations! You've successfully mastered the "Liquid Metal" of Linux storage! You can now:
- ✅ **Understand the LVM hierarchy** (Physical Volumes → Volume Groups → Logical Volumes)
- ✅ **Resize disks on-the-fly** without rebooting your system
- ✅ **Create and manage snapshots** for instant "point-in-time" backups
- ✅ **Manage disk space flexibly** across multiple physical drives
- ✅ **Automate filesystem resizing** to match your storage changes
- ✅ **Perform safe disk reductions** using proper unmounting and checking procedures

### What's Next?
In the next stack, we'll dive into **NFS, Samba, and SSHFS**. You'll learn how to share your files across the network so multiple computers can access them at once!

**Next: Stack 34 - NFS, Samba, SSHFS →**

---

*End of Stack 33*