# 🖥️ STACK 61: TMUX & SCREEN
## Terminal Multiplexers - Session Management

---

## 🔰 What is a Terminal Multiplexer?

A terminal multiplexer lets you:
- Run multiple terminal sessions in one window
- Detach and reattach sessions remotely
- Split screens into multiple panes
- Share sessions with others
- Keep processes running after logout

### tmux vs Screen
| Feature | tmux | Screen |
|---------|------|--------|
| Status bar | Built-in | Needs customization |
| Split panes | Easier syntax | More complex |
| Configuration | Simple | More options |
| Popularity | More modern | Legacy |
| Copy mode | vi/emacs modes | vi/emacs modes |

---

## 🖥️ TMUX BASICS

### Installation
```bash
# Ubuntu/Debian
sudo apt install tmux

# CentOS/RHEL
sudo yum install tmux

# macOS
brew install tmux

# Verify
tmux -V
```

### Key Concepts
- **Session** - A collection of windows
- **Window** - A single terminal (can have splits)
- **Pane** - A split portion of a window
- **Prefix** - Ctrl+b (default)

### Starting tmux
```bash
# Start new session (with name)
tmux new -s mysession

# Start new session (auto-name)
tmux new

# Attach to existing session
tmux attach
tmux attach -t mysession

# List sessions
tmux ls

# Kill session
tmux kill-session -t mysession
```

---

## ⌨️ Essential Commands

### Session Management
```bash
# Detach from session
Ctrl+b d

# Attach to session
tmux attach

# Rename session
Ctrl+b $

# List sessions
Ctrl+b s

# Switch sessions
Ctrl+b (    # Previous
Ctrl+b )    # Next
```

### Window Management
```bash
# Create new window
Ctrl+b c

# List windows
Ctrl+b w

# Rename window
Ctrl+b ,

# Close window
Ctrl+b &

# Switch to window by number
Ctrl+b 0-9

# Next/Previous window
Ctrl+b n    # Next
Ctrl+b p    # Previous
```

### Pane Management
```bash
# Split vertically (top/bottom)
Ctrl+b "

# Split horizontally (left/right)
Ctrl+b %

# Switch panes
Ctrl+b arrow keys
Ctrl+b o

# Resize pane
Ctrl+b :resize-pane -D 10  # Down 10
Ctrl+b :resize-pane -U 10  # Up 10
Ctrl+b :resize-pane -L 10  # Left 10
Ctrl+b :resize-pane -R 10  # Right 10

# Make pane full screen
Ctrl+b z

# Close pane
Ctrl+b x
```

---

## 🎨 Pane Layouts

```bash
# Cycle layouts
Ctrl+b space

# Even horizontal
Ctrl+b :select-layout even-horizontal

# Even vertical
Ctrl+b :select-layout even-vertical

# Main horizontal (one big pane)
Ctrl+b :select-layout main-horizontal

# Main vertical
Ctrl+b :select-layout main-vertical

# Tiled
Ctrl+b :select-layout tiled
```

### Visual Layout Example
```
+------------------+------------------+
|                  |                  |
|     Pane 1       |      Pane 2      |
|                  +--------+---------+
|                  |        |         |
+------------------+  Pane3 | Pane 4  |
|                  |        |         |
|     Pane 5       +--------+---------+
|                  |                  |
+------------------+------------------+
```

---

## 📋 Copy Mode (Scrolling)

### Enter Copy Mode
```bash
Ctrl+b [    # Enter copy mode
Ctrl+b PgUp # Enter and scroll up

# Exit
q
```

### Navigation in Copy Mode
```bash
# Move
Arrow keys
h,j,k,l

# Jump by word
w, b

# Jump by line
0, ^, $

# Search
/   # Forward
?   # Backward
n   # Next match
N   # Previous match

# Scroll
Ctrl+b u    # Scroll up half page
Ctrl+b d    # Scroll down half page

# Mark
Space   # Start selection
Enter   # Copy selection
```

### Copy/Paste
```bash
# Copy (in copy mode)
Space   # Start selection
Enter   # Copy

# Paste
Ctrl+b ]    # Paste
```

---

## ⚙️ Configuration

### tmux.conf
```bash
# ~/.tmux.conf

# Set prefix to Ctrl+a (instead of Ctrl+b)
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# Enable mouse support
set -g mouse on

# Start window numbering at 1
set -g base-index 1

# Start pane numbering at 1
setw -g pane-base-index 1

# Renumber windows automatically
set -g renumber-windows on

# Faster command sequence
set -s escape-time 0

# Status bar
set -g status-bg green
set -g status-fg black

# Show activity in other windows
setw -g monitor-activity on
set -g visual-activity on

# Color support
set -g default-terminal "screen-256color"

# Vi keys in copy mode
setw -g mode-keys vi
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

# Split panes using | and -
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %

# Reload config
bind r source-file ~/.tmux.conf
```

### Useful Options
```bash
# From command line
tmux set -g mouse on
tmux set -g status off
tmux setw -g mode-keys vi

# View all options
tmux show-options -g
tmux show-window-options -g
```

---

## 🔄 Synchronizing Panes

### Enable/Disable Sync
```bash
# Turn on
Ctrl+b :setw synchronize-panes on

# Turn off
Ctrl+b :setw synchronize-panes off

# Toggle
Ctrl+b :setw synchronize-panes
```

### Use Case
Run the same command on multiple servers:
```
+----------+----------+
| Server 1 | Server 2 |
|   (ssh   |   (ssh   |
|  server1)|  server2)|
+----------+----------+
| Server 3 | Server 4 |
|   (ssh   |   (ssh   |
|  server3)|  server4)|
+----------+----------+
# Now type once, execute everywhere!
```

---

## 🔗 Scripting tmux

### Create Sessions from Script
```bash
#!/bin/bash
# setup_dev_env.sh

SESSION="dev"

# Create session if not exists
tmux new-session -d -s "$SESSION"

# Split into panes
tmux split-window -h -t "$SESSION"
tmux split-window -v -t "$SESSION"
tmux select-layout -t "$SESSION" tiled

# Send commands to panes
tmux send-keys -t "$SESSION:0.0" "cd ~/project" C-m
tmux send-keys -t "$SESSION:0.0" "npm run dev" C-m

tmux send-keys -t "$SESSION:0.1" "cd ~/project" C-m
tmux send-keys -t "$SESSION:0.1" "npm test" C-m

tmux send-keys -t "$SESSION:0.2" "cd ~/logs" C-m
tmux send-keys -t "$SESSION:0.2" "tail -f app.log" C-m

# Attach
tmux attach -t "$SESSION"
```

### Automated Setup
```bash
#!/bin/bash
# monitor_servers.sh

# Create monitoring session
tmux new-session -d -s monitors

# Split into 4 panes
tmux split-window -h
tmux split-window -v
tmux select-pane -t 0
tmux split-window -v

# Start monitoring
tmux send-keys -t monitors.0 "htop" C-m
tmux send-keys -t monitors.1 "watch df -h" C-m
tmux send-keys -t monitors.2 "watch free -m" C-m
tmux send-keys -t monitors.3 "tail -f /var/log/syslog" C-m

tmux attach -t monitors
```

---

## 🖥️ SCREEN BASICS

### Installation
```bash
# Ubuntu/Debian
sudo apt install screen

# CentOS/RHEL
sudo yum install screen

# macOS (pre-installed)
screen -v
```

### Starting Screen
```bash
# Start new session
screen -S mysession

# List sessions
screen -ls

# Attach to session
screen -r mysession

# Attach to existing (if only one)
screen -r

# Detach
Ctrl+a d

# Kill session
screen -X -S mysession quit
```

---

## ⌨️ Screen Commands

### Session Management
```bash
# Detach
Ctrl+a d

# Attach
screen -r

# Attach to attached (grab)
screen -d -r

# List
screen -ls

# Kill current session
Ctrl+a \

# New session
Ctrl+a c
```

### Window Management
```bash
# New window
Ctrl+a c

# Next window
Ctrl+a n

# Previous window
Ctrl+a p

# Switch to window 0-9
Ctrl+a 0-9

# List windows
Ctrl+a w

# Rename window
Ctrl+a A

# Kill window
Ctrl+a k
```

### Pane Management
```bash
# Split vertically
Ctrl+a S

# Split horizontally
Ctrl+a |

# Go to next region
Ctrl+a Tab

# Remove region
Ctrl+a X

# Resize region
Ctrl+a :resize
```

---

## 📋 Copy Mode (Screen)

### Enter and Navigate
```bash
# Enter copy mode
Ctrl+a [

# Navigate
h,j,k,l
Arrow keys

# Search
/   # Forward
?   # Backward
n   # Next

# Start selection
Space

# Copy selection
Space

# Paste
Ctrl+a ]
```

---

## ⚙️ Screen Configuration

### screenrc
```bash
# ~/.screenrc

# Status line
hardstatus alwayslastline
hardstatus string '%{= kG}[ %{G}%H %{g}][%= %{= kw}%-w%{+b}[%n %t]%{-b}%{kW}%?%-w%?%{= R}%(%{B}%n %t%{b}%?%{= R}%?%{= kW}%?%+w%?%?%= %{g}][%{B}%m/%d %{W}%c %{g}]'

# Start at 1
startup_message off

# Scrollback
defscrollback 10000

# Escape character
escape ^Aa

# Vi keys
bindkey -k k1 select 1
bindkey -k k2 select 2

# New window with shell
shell -$SHELL
```

---

## 🔄 Quick Reference

### tmux Quick Commands
| Action | Command |
|--------|---------|
| New session | `tmux new -s name` |
| Detach | `Ctrl+b d` |
| Split vertical | `Ctrl+b "` |
| Split horizontal | `Ctrl+b %` |
| Navigate panes | `Ctrl+b arrows` |
| New window | `Ctrl+b c` |
| Copy mode | `Ctrl+b [` |
| Sync panes | `:setw synchronize-panes on` |
| List | `tmux ls` |

### screen Quick Commands
| Action | Command |
|--------|---------|
| New session | `screen -S name` |
| Detach | `Ctrl+a d` |
| Split | `Ctrl+a S` |
| Navigate | `Ctrl+a Tab` |
| New window | `Ctrl+a c` |
| Copy mode | `Ctrl+a [` |
| Paste | `Ctrl+a ]` |
| List | `screen -ls` |

---

## 🎯 Practical Use Cases

### Remote Server Management
```bash
# SSH into server
ssh user@server

# Start tmux
tmux new -s work

# Run your tasks...
# If connection drops, processes continue!

# Reconnect later
ssh user@server
tmux attach -t work
```

### Development Workflow
```
┌─────────────────────────────────┐
│  Terminal 1: Code Editor       │
│  vim or nano file.js           │
├─────────────────────────────────┤
│  Terminal 2: Tests             │
│  npm test --watch              │
├─────────────────────────────────┤
│  Terminal 3: Server            │
│  node server.js                │
├─────────────────────────────────┤
│  Terminal 4: Git               │
│  git log --oneline             │
└─────────────────────────────────┘
```

### Pair Programming
```bash
# User A (host)
tmux -S /tmp/share new -s pair
chmod 777 /tmp/share

# User B (joiner)
tmux -S /tmp/share attach -t pair

# Now both can see and interact!
```

---

## 🛠️ Advanced Tips

### tmux
```bash
# Save/restore sessions (tmux-resurrect)
# https://github.com/tmux-plugins/tmux-resurrect

# Plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Activities monitoring
setw -g monitor-activity on
set -g visual-activity on
```

### screen
```bash
# Multiuser mode
screen -mdS pair
aclchg user +x "#(pid -P $$ 2>/dev/null || echo 0)" # workaround
# Use tmux for easier sharing!
```

---

## ⚡ Productivity Tips

1. **Always use tmux/screen** when SSH-ing
2. **Name your sessions** for easy identification
3. **Use synchronize-panes** for running commands on multiple servers
4. **Configure vi keys** for copy mode
5. **Set up tmux-resurrect** to persist sessions across reboots
6. **Use prefix remapping** (Ctrl+a) for ergonomics

---

## ✅ Stack 61 Complete!

You learned:
- ✅ What terminal multiplexers are
- ✅ tmux basics and commands
- ✅ Pane management and layouts
- ✅ Copy mode and scrolling
- ✅ Configuration and customization
- ✅ Scripting and automation
- ✅ Synchronizing panes
- ✅ screen basics
- ✅ Practical use cases
- ✅ Productivity tips

### Congratulations! Course Complete! 🎓

---

## 📚 Final Words

You now have **complete Bash mastery**:
- Core scripting (Stacks 1-12)
- Intermediate tools (Stacks 13-25)
- DevOps skills (Stacks 26-41)
- Advanced topics (Stacks 42-52, 60-61)
- Specialized infrastructure (Stacks 53-59)

**Keep practicing and building!**

---

*End of Stack 61 - Course Complete!*
