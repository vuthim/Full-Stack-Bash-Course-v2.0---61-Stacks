# 👥 STACK 32: USER MANAGEMENT
## Creating and Managing Users in Linux

**What is User Management?** Linux is a multi-user system - multiple people (and services) can use the same computer. User management is how you control who has access and what they can do.

**Security First:** Every user account is a potential security boundary. Give users only the permissions they NEED (least privilege), not everything they might want.

---

## 🔰 User Management Basics

Linux is a multi-user system where you can create, modify, and delete user accounts with different permission levels.

### Types of Users
| Type | UID Range | Description | Examples |
|------|-----------|-------------|----------|
| **Root** | 0 | Superuser (full access) | System administrator |
| **System** | 1-999 | Services and daemons | www-data, mysql, nginx |
| **Regular** | 1000+ | Normal users | john, sarah, deploy |

**Pro Tip:** System accounts (UID 1-999) are for SERVICES, not people. They usually can't log in - they just run background processes!

---

## 👤 Creating Users

### useradd Command
```bash
# Create basic user
sudo useradd john

# Create with home directory
sudo useradd -m john

# Create with specific shell
sudo useradd -m -s /bin/bash john

# Create with comment
sudo useradd -m -c "John Doe" john

# Create with specific UID
sudo useradd -m -u 1500 john

# Create system user (no home)
sudo useradd -r myservice
```

### useradd Options
```bash
sudo useradd -m \
    -s /bin/bash \
    -c "Full Name" \
    -G sudo,www-data \
    username
```

---

## 🔐 Managing Passwords

### passwd Command
```bash
# Set password for user
sudo passwd john

# Remove password (lock account)
sudo passwd -d john

# Lock account
sudo passwd -l john

# Unlock account
sudo passwd -u john

# Force password change
sudo passwd -e john
```

### Password Policies
```bash
# Set password expiry
sudo chage -M 90 john        # Max days
sudo chage -m 5 john         # Min days
sudo chage -W 7 john         # Warning
sudo chage -I 30 john        # Inactive

# View password status
sudo chage -l john
```

---

## ✏️ Modifying Users

### usermod Command
```bash
# Change username
sudo usermod -l newname oldname

# Change home directory
sudo usermod -d /new/home -m john

# Change shell
sudo usermod -s /bin/zsh john

# Add to groups
sudo usermod -aG docker john

# Lock account
sudo usermod -L john

# Unlock account
sudo usermod -U john
```

---

## 🗑️ Deleting Users

### userdel Command
```bash
# Delete user (keep home)
sudo userdel john

# Delete user and home
sudo userdel -r john

# Force delete
sudo userdel -f john
```

---

## 👥 Managing Groups

### groupadd Command
```bash
# Create group
sudo groupadd developers

# Create with GID
sudo groupadd -g 1500 developers
```

### groupmod Command
```bash
# Change group name
sudo groupmod -n newname oldname

# Change GID
sudo groupmod -g 1500 developers
```

### groupdel Command
```bash
# Delete group
sudo groupdel developers
```

### gpasswd Command
```bash
# Add user to group
sudo gpasswd -a john developers

# Remove from group
sudo gpasswd -d john developers

# Set group admin
sudo gpasswd -A john developers
```

---

## 🔍 Viewing User Info

### Commands
```bash
# List all users
cat /etc/passwd

# List all groups
cat /etc/group

# List user's groups
groups john

# List users with shell
getent passwd

# List groups
getent group

# Show user info
id john
# Output: uid=1000(john) gid=1000(john) groups=1000(john),27(sudo)
```

---

## 🚪 Sudo Access

### Granting Sudo
```bash
# Add user to sudo group (Debian/Ubuntu)
sudo usermod -aG sudo john

# Add to wheel group (RHEL/CentOS)
sudo usermod -aG wheel john

# Edit sudoers file (careful!)
sudo visudo

# Add specific permissions
john ALL=(ALL) NOPASSWD: /usr/bin/systemctl
```

### Sudoers File Format
```bash
# Allow user to run all commands
john ALL=(ALL) ALL

# Allow group to run all commands
%developers ALL=(ALL) ALL

# No password for specific commands
%admin ALL=(ALL) NOPASSWD: /usr/bin/systemctl
```

---

## 🔐 LDAP Integration (Brief)

### Basic LDAP Commands
```bash
# Install LDAP client
sudo apt install libnss-ldap libpam-ldap

# Configure NSS
sudo auth-client-config -t nss -p lac_ldap

# Enable PAM modules
sudo pam-auth-update
```

---

## 🏆 Practice Exercises

### Exercise 1: Create Users
```bash
# Create developer user
sudo useradd -m -s /bin/bash -G sudo,docker devuser

# Set password
sudo passwd devuser

# Verify
id devuser
groups devuser

# Show user info
getent passwd devuser
```

### Exercise 2: Manage Groups
```bash
# Create groups
sudo groupadd webteam
sudo groupadd dbteam

# Add users to groups
sudo usermod -aG webteam john
sudo usermod -aG dbteam jane

# List groups
getent group
```

### Exercise 3: Sudo Configuration
```bash
# Create sudoers entry
sudo visudo

# Add line
developer ALL=(ALL) /usr/bin/systemctl restart nginx
developer ALL=(ALL) /usr/bin/systemctl status nginx
```

---

## 📋 User Management Cheat Sheet

| Command | Action |
|---------|--------|
| `useradd` | Create user |
| `usermod` | Modify user |
| `userdel` | Delete user |
| `passwd` | Set password |
| `groupadd` | Create group |
| `groupdel` | Delete group |
| `id` | Show user info |
| `groups` | Show groups |

---

## 🎓 Final Project: User & Group Manager

Now that you've mastered the commands for managing users and groups, let's see how a professional system administrator might automate these tasks. We'll examine the "User Manager" — a tool that simplifies creating accounts, managing group memberships, and handling security locks.

### What the User & Group Manager Does:
1. **Lists All Users** in a clean, readable table format.
2. **Simplifies Account Creation** with home directories and default shells.
3. **Manages Group Membership** (add/remove users) with one-word commands.
4. **Controls Sudo Access** safely without manual `visudo` editing.
5. **Locks and Unlocks Accounts** instantly for security purposes.
6. **Cleans Up Home Directories** automatically when a user is deleted.

### Key Snippet: Clean User Listing
The manager uses `getent` and `awk` to parse the system's user database and present it in a human-friendly table.

```bash
cmd_list() {
    echo "=== System Users ==="
    # getent: safely read the passwd database
    # awk: extract username, UID, home dir, and shell
    # column -t: align the output into perfect columns
    getent passwd | awk -F: '{print $1, $3, $6, $7}' | column -t
}
```

### Key Snippet: Managing Sudo Access
Adding a user to the `sudo` group is a common but sensitive task. The manager makes it a simple, repeatable command.

```bash
cmd_sudo() {
    local user=$1
    
    # -aG: Append to Group (don't overwrite their existing groups!)
    sudo usermod -aG sudo "$user"
    log "User '$user' now has administrative (sudo) access."
}
```

**Pro Tip:** Automation tools like this prevent "fat-finger" mistakes (like accidentally deleting the wrong user) by standardizing the way you interact with the system's identity files.

---

## ✅ Stack 32 Complete!

Congratulations! You've successfully mastered the "Identity and Access Management" of your Linux system! You can now:
- ✅ **Manage user accounts** (Create, Modify, Delete) like a pro
- ✅ **Master passwords and security** by locking and unlocking accounts
- ✅ **Organize users into groups** for efficient permission management
- ✅ **Control Sudo access** to grant administrative privileges safely
- ✅ **Audit system users** and understand UIDs and GIDs
- ✅ **Handle home directories** and default shell configurations

### What's Next?
In the next stack, we'll dive into **LVM (Logical Volume Management)**. You'll learn how to manage your hard drive space like a pro, allowing you to resize disks without rebooting!

**Next: Stack 33 - LVM →**

---

*End of Stack 32*
-- **Previous:** [Stack 31 → Kubernetes Basics](31_kubernetes.md)
-- **Next:** [Stack 33 - LVM](33_lvm.md)