# 🤖 STACK 38: ANSIBLE ESSENTIALS
## Configuration Management with Ansible

**What is Ansible?** Think of Ansible as a "remote control for server management." Instead of logging into each server and running commands manually, you write a playbook (a recipe) and Ansible runs it on ALL your servers at once - via SSH, no software needed on the remote machines!

**Why This Matters:** Managing 1 server manually is easy. Managing 100? You need automation. Ansible is the simplest way to start.

---

## 🔰 What is Ansible?

Ansible is an agentless configuration management tool that uses SSH to execute tasks on remote servers.

### Key Features (Why Ansible is Popular)
- ✅ **Agentless**: No software to install on remote hosts (just SSH access!)
- ✅ **Idempotent**: Safe to run multiple times (same result every time)
- ✅ **YAML-based**: Easy to read/write (looks like a todo list)
- ✅ **Push-based**: YOU control when changes happen (not a daemon running in background)

### Ansible Analogy for Beginners
```
Manual:     SSH to each server → run commands → repeat 100 times
Ansible:    Write one playbook → ansible-playbook → ALL servers updated at once

It's like the difference between:
- Manually mailing 100 letters
- Using a mail merge to send all 100 at once
```

---

## ⚡ Installing Ansible

### Ubuntu
```bash
# Install
sudo apt update
sudo apt install ansible

# Verify
ansible --version
```

### pip
```bash
# Via pip
pip install ansible

# With specific version
pip install ansible==2.10.7
```

---

## 🔧 Inventory

### Basic Inventory
```ini
# inventory.ini
[webservers]
web1.example.com
web2.example.com

[dbservers]
db1.example.com
db2.example.com

[all:vars]
ansible_user=ubuntu
ansible_python_interpreter=/usr/bin/python3
```

### Inventory Commands
```bash
# List hosts
ansible-inventory -i inventory.ini --list

# Graph
ansible-inventory -i inventory.ini --graph
```

---

## 📝 Playbooks

### Basic Playbook
```yaml
# playbook.yml
- hosts: webservers
  become: yes
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
    
    - name: Install nginx
      apt:
        name: nginx
        state: present
    
    - name: Start nginx
      service:
        name: nginx
        state: started
        enabled: yes
```

### Run Playbook
```bash
# Dry run
ansible-playbook -i inventory.ini playbook.yml --check

# Execute
ansible-playbook -i inventory.ini playbook.yml
```

---

## 📦 Modules

### Common Modules
| Module | Purpose |
|--------|---------|
| apt | Package management |
| yum | Package management (RHEL) |
| service | Manage services |
| copy | Copy files |
| file | File properties |
| command | Run commands |
| shell | Run shell commands |
| git | Git operations |
| template | Template files |
| user | User management |

### Examples
```yaml
tasks:
  - name: Copy file
    copy:
      src: ./config.conf
      dest: /etc/myapp/config.conf
      mode: '0644'
      owner: root
      group: root

  - name: Create user
    user:
      name: appuser
      shell: /bin/bash
      create_home: yes
    
  - name: Run command
    command: /opt/scripts/backup.sh
    args:
      creates: /tmp/backup.done
```

---

## 🔄 Variables

### Variables in Playbook
```yaml
- hosts: all
  vars:
    nginx_port: 8080
    app_dir: /opt/myapp
  
  tasks:
    - name: Install {{app_dir}}
      apt:
        name: nginx
        state: present
```

### Host Variables
```ini
# inventory.ini
[webservers]
web1.example.com nginx_port=8080
web2.example.com nginx_port=8090
```

---

## 🔀 Conditionals and Loops

### Conditionals
```yaml
tasks:
  - name: Install Apache on Debian
    apt:
      name: apache2
      state: present
    when: ansible_os_family == "Debian"
  
  - name: Install Apache on RedHat
    yum:
      name: httpd
      state: present
    when: ansible_os_family == "RedHat"
```

### Loops
```yaml
tasks:
  - name: Install packages
    apt:
      name: "{{ item }}"
      state: present
    loop:
      - nginx
      - git
      - vim
```

---

## 🛡️ Roles

### Role Structure
```
roles/
  webserver/
    tasks/
      main.yml
    handlers/
      main.yml
    templates/
      nginx.conf.j2
    vars/
      main.yml
```

### Using Role
```yaml
# playbook.yml
- hosts: webservers
  roles:
    - webserver
```

### Role Tasks
```yaml
# roles/webserver/tasks/main.yml
- name: Install nginx
  apt:
    name: nginx
    state: present

- name: Configure nginx
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: restart nginx
```

---

## 🏆 Practice Exercises

### Exercise 1: Basic Setup
```bash
# Install Ansible
sudo apt install ansible

# Create inventory
echo "[servers]
server1 ansible_host=localhost" > inventory.ini
```

### Exercise 2: Ping Test
```bash
# Ping all hosts
ansible -i inventory.ini all -m ping
```

### Exercise 3: Create Playbook
```yaml
# install_nginx.yml
---
- hosts: servers
  become: yes
  
  tasks:
  - name: Update apt
    apt:
      update_cache: yes
  
  - name: Install nginx
    apt:
      name: nginx
      state: present
      
  - name: Start nginx
    service:
      name: nginx
      state: started
```

```bash
# Run
ansible-playbook -i inventory.ini install_nginx.yml
```

---

## 📋 Ansible Cheat Sheet

| Command | Action |
|---------|--------|
| `ansible` | Run single task |
| `ansible-playbook` | Run playbook |
| `ansible-inventory` | Manage inventory |
| `ansible-vault` | Encrypt secrets |

---

## ✅ Stack 38 Complete!

You learned:
- ✅ What is Ansible
- ✅ Installation
- ✅ Inventory
- ✅ Playbook basics
- ✅ Common modules
- ✅ Variables
- ✅ Roles

### Next: Stack 39 - System Hardening →

---

*End of Stack 38*