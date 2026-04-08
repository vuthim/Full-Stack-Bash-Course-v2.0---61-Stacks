# 🖥️ STACK 53: TERMINAL UI DEVELOPMENT
## Building Interactive CLI Applications

**What is Terminal UI?** Think of it like adding a nice dashboard to a car. The engine (your script) works fine without it, but a good UI makes it intuitive, professional, and pleasant to use. Terminal UI turns boring scripts into tools people actually enjoy using!

**Why This Matters:** Well-designed CLI tools are used more, understood better, and cause fewer user errors. A menu is friendlier than memorizing command-line flags.

---

## 🔰 What You'll Learn

By the end of this stack, you'll be able to create:
- ✅ **Interactive terminal menus** - Guide users through choices
- ✅ **User-friendly interfaces** - Make scripts accessible to non-technical users
- ✅ **Keyboard input handling** - Respond to single keypresses (no Enter needed!)
- ✅ **Progress bars and spinners** - Show users something is happening
- ✅ **Colorized output** - Make important info stand out visually

### The Terminal UI Mindset
```
Basic script:   ./backup.sh → runs → done (user has no idea what happened)
Terminal UI:    ./backup.sh → [=====>      ] 45% → "✓ Backup complete!" (user is informed)
```

**Pro Tip:** Good terminal UI follows these rules:
1. Always show progress (don't leave users guessing)
2. Use colors consistently (green=good, red=bad, yellow=warning)
3. Make it clear what the user should do next

---

## 🎨 ANSI Colors & Formatting

### Color Codes
```bash
#!/bin/bash
# colors.sh

# ANSI Color Codes
RED='\033[0;31m' 
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
NC='\033[0m' # No Color

# Usage
echo -e "${RED}Error:${NC} Something went wrong"
echo -e "${GREEN}Success!${NC} Operation complete"
echo -e "${BOLD}${YELLOW}Warning:${NC} Check your input"
echo -e "${CYAN}Processing${NC}..."

# RGB Colors (256 colors)
echo -e "\033[38;2;255;100;0mOrange RGB\033[0m"
```

### Cursor Control
```bash
#!/bin/bash
# cursor_control.sh

# Clear screen
clear

# Cursor movement
echo -e "\033[5;10H"  # Move to row 5, column 10
echo "Text at position"

# Hide/show cursor
echo -e "\033[?25l"   # Hide cursor
sleep 2
echo -e "\033[?25h"  # Show cursor

# Save/restore cursor position
echo -e "\033[s"     # Save
echo "Some text"
echo -e "\033[u"      # Restore
```

---

## 📋 Menu Systems

### Simple Select Menu
```bash
#!/bin/bash
# menu.sh

PS3="Choose an option: "
options=("Option 1" "Option 2" "Option 3" "Quit")

select opt in "${options[@]}"; do
    case $opt in
        "Option 1")
            echo "You chose option 1"
            ;;
        "Option 2")
            echo "You chose option 2"
            ;;
        "Option 3")
            echo "You chose option 3"
            ;;
        "Quit")
            echo "Goodbye!"
            break
            ;;
        *)
            echo "Invalid option"
            ;;
    esac
done
```

### Interactive Dashboard
```bash
#!/bin/bash
# dashboard.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

while true; do
    clear
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN}     SYSTEM MONITORING DASHBOARD        ${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo ""
    
    # Get system info
    cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    mem=$(free | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}')
    disk=$(df -h / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
    
    # Display with colors
    echo -e "CPU Usage:    ${GREEN}$cpu%${NC}"
    echo -e "Memory Used:  ${GREEN}$mem%${NC}"
    echo -e "Disk Used:    ${GREEN}$disk%${NC}"
    echo ""
    echo "Press 'q' to quit, any key to refresh"
    
    read -t 1 -n 1 key
    if [[ $key == "q" ]]; then
        break
    fi
done
```

---

## 📊 Progress Bars

### Simple Progress Bar
```bash
#!/bin/bash
# progress_bar.sh

# Function to draw progress bar
progress_bar() {
    local total=$1
    local current=$2
    local width=50
    
    local percent=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))
    
    printf "\rProgress: ["
    printf "%${completed}s" | tr ' ' '='
    printf "%${remaining}s" | tr ' ' '-'
    printf "] %3d%%" "$percent"
}

# Usage
for i in {1..100}; do
    progress_bar 100 $i
    sleep 0.05
done
echo ""
```

### Download Progress Bar
```bash
#!/bin/bash
# download_progress.sh

download_file() {
    local url=$1
    local output=$2
    
    curl -L -o "$output" "$url" 2>&1 | while read -r line; do
        # Extract percentage
        if [[ $line =~ ([0-9]+)% ]]; then
            percent=${BASH_REMATCH[1]}
            printf "\rDownloading: ["
            printf "%$((percent/2))s" | tr ' ' '='
            printf "%$((50 - percent/2))s" | tr ' ' '-'
            printf "] %3d%%" "$percent"
        fi
    done
    echo ""
}
```

### Spinner Animation
```bash
#!/bin/bash
# spinner.sh

spinner() {
    local pid=$1
    local spin='-\|/'
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        printf "\r[%c] " "${spin:i++%${#spin}:1}"
        sleep 0.1
    done
    printf "\r[✓] Done!   \n"
}

# Usage: Run command with spinner
(sleep 3) & spinner $!
echo "Background task complete"
```

---

## ⌨️ Keyboard Input Handling

### Single Key Input
```bash
#!/bin/bash
# key_input.sh

# Read single character without Enter
read -rn 1 -p "Press any key to continue..."

# Read with timeout
read -t 2 -n 1 -p "Press y/n within 2 seconds: " response
if [ -z "$response" ]; then
    echo "Timeout!"
fi

# Arrow key detection
echo "Use arrow keys, press q to quit"
while true; do
    read -rn 1 key
    case "$key" in
        $'\x1b')  # Escape sequence
            read -rn 1 -t 0.1 key
            read -rn 1 -t 0.1 key
            case "$key" in
                A) echo "Up" ;;
                B) echo "Down" ;;
                C) echo "Right" ;;
                D) echo "Left" ;;
            esac
            ;;
        q) break ;;
    esac
done
```

### Password Input
```bash
#!/bin/bash
# password.sh

# Hide input
read -sp "Enter password: " password
echo ""

# Show asterisks
password=""
while true; do
    read -rn 1 -p "Char: " char
    if [ "$char" = $'\r' ]; then
        break
    elif [ "$char" = $'\x7f' ]; then
        password="${password%?}"
        printf "\b \b"
    else
        password+="$char"
        printf "*"
    fi
done
echo ""
echo "Password: $password"
```

---

## 📝 Form Input

### Interactive Form
```bash
#!/bin/bash
# form.sh

form() {
    clear
    echo "═══════════════════════════════"
    echo "     USER REGISTRATION         "
    echo "═══════════════════════════════"
    
    # Name
    echo -n "Enter name: "
    read name
    
    # Email with validation
    while true; do
        echo -n "Enter email: "
        read email
        if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            break
        else
            echo "Invalid email format. Try again."
        fi
    done
    
    # Password
    read -sp "Enter password: " password
    echo ""
    
    # Confirm
    read -sp "Confirm password: " confirm
    echo ""
    
    if [ "$password" = "$confirm" ]; then
        echo -e "${GREEN}Registration successful!${NC}"
    else
        echo -e "${RED}Passwords do not match!${NC}"
    fi
}

form
```

---

## 📊 Tables

### Align Output in Table
```bash
#!/bin/bash
# table.sh

# Print a formatted table
print_table() {
    local header="$1"
    local data="$2"
    
    # Print header
    printf "+%s+\n" "$(printf '%-60s' '' | tr ' ' '-')"
    printf "| %-58s |\n" "$header"
    printf "+%s+\n" "$(printf '%-60s' '' | tr ' ' '-')"
    
    # Print rows
    while IFS='|' read -r name value; do
        printf "| %-20s | %-35s |\n" "$name" "$value"
    done <<< "$data"
    
    printf "+%s+\n" "$(printf '%-60s' '' | tr ' ' '-')"
}

# Usage
print_table "System Information" \
"Hostname|$(hostname)
Uptime|$(uptime -p)
Memory|$(free -h | grep Mem | awk '{print $3 "/" $2}')
Disk|$(df -h / | tail -1 | awk '{print $3 "/" $2}')"
```

---

## 🎯 Interactive Wizard

### Multi-Step Wizard
```bash
#!/bin/bash
# wizard.sh

step1() {
    echo "Step 1: Choose installation type"
    select type in "Basic" "Full" "Custom"; do
        [ -n "$type" ] && break
    done
    echo "$type"
}

step2() {
    echo "Step 2: Select components"
    select comp in "Web Server" "Database" "Both"; do
        [ -n "$comp" ] && break
    done
    echo "$comp"
}

step3() {
    read -p "Enter domain name: " domain
    echo "$domain"
}

# Run wizard
clear
echo "Installation Wizard"
echo "==================="
echo ""

install_type=$(step1)
component=$(step2)
domain=$(step3)

echo ""
echo "Summary:"
echo "- Installation: $install_type"
echo "- Components: $component"
echo "- Domain: $domain"
```

---

## 🏆 Practice Exercises

### Exercise 1: Calculator
Build an interactive calculator with menu options

### Exercise 2: File Manager
Create a simple TUI file manager

### Exercise 3: Progress Tracking
Add progress bar to a long-running script

---

## 🎓 Final Project: The Bash Terminal UI (TUI) Framework

Now that you've mastered colors, menus, and keyboard input, let's see how a professional scripter might build a "UI Library" for their tools. We'll examine the "TUI Framework" — a collection of reusable Bash components that provide progress bars, spinners, interactive menus, and even dialog boxes.

### What the Bash TUI Framework Does:
1. **Renders Animated Progress Bars** to give users visual feedback during long tasks.
2. **Displays Elegant Spinners** for tasks where the exact duration is unknown.
3. **Creates Interactive Menus** that allow users to select options using numbers or keys.
4. **Formats Beautiful Tables** with aligned columns and color-coded headers.
5. **Generates System Dialogs** using the `dialog` utility (with text-based fallbacks).
6. **Simplifies User Input** by wrapping complex `read` and `printf` logic into easy functions.

### Key Snippet: The Terminal Spinner
A spinner is a great way to show that your script is "thinking" and hasn't frozen. It works by rapidly cycling through characters and using `\b` (backspace) to overwrite them.

```bash
spinner_example() {
    local delay=0.1
    local spinstr='|/-\' # The 4 frames of our animation
    
    echo -n "Processing Data... "
    for i in {1..20}; do
        local temp=${spinstr#?}
        # \b: move cursor back one space
        # %c: print the first character of spinstr
        printf "\b%c" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\bDone!\n"
}
```

### Key Snippet: Formatted Output Tables
Using `printf` with specific widths ensures your data is always perfectly aligned, regardless of how long the strings are.

```bash
table_example() {
    # %-10s means: Print a string, left-aligned, in a 10-character wide box
    printf "${BLUE}%-15s %-10s %-10s${NC}\n" "Service" "Status" "Uptime"
    echo "---------------------------------------"
    printf "%-15s %-10s %-10s\n" "Web Server" "RUNNING" "24d"
    printf "%-15s %-10s %-10s\n" "Database" "ERROR" "0s"
}
```

**Pro Tip:** Adding a professional TUI to your scripts is the fastest way to make your work look "expensive" and high-quality to your users and colleagues!

---

## ✅ Stack 53 Complete!

Congratulations! You've successfully turned your "Text Terminal" into a "Graphic Interface"! You can now:
- ✅ **Use ANSI Colors** to highlight important information
- ✅ **Build interactive menus** for a professional user experience
- ✅ **Create animated progress bars** and spinners for long-running tasks
- ✅ **Format complex data** into beautiful, aligned tables
- ✅ **Manage user input** safely using advanced `read` techniques
- ✅ **Build interactive wizards** to guide users through complex setups

### What's Next?
In the next stack, we'll dive into **IPC (Inter-Process Communication)**. You'll learn how to make multiple scripts "talk" to each other using signals, pipes, and shared memory!

**Next: Stack 54 - IPC Mechanisms →**

---

*End of Stack 53*
-- **Previous:** [Stack 52 → SSL/TLS](52_ssl_tls.md)
-- **Next:** [Stack 54 - IPC Mechanisms](54_ipc_mechanisms.md)