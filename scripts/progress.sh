#!/bin/bash
# Progress Tracker for Full Stack Bash Course - 59 STACKS

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROGRESS_FILE="$SCRIPT_DIR/.progress"

# Ensure progress file exists
touch "$PROGRESS_FILE"

# Stack names for all 59 stacks
declare -A STACK_NAMES
STACK_NAMES[1]="Bash Fundamentals"
STACK_NAMES[2]="File & Directory Operations"
STACK_NAMES[3]="File Viewing & Editing"
STACK_NAMES[4]="Text Processing"
STACK_NAMES[5]="Variables & Data Types"
STACK_NAMES[6]="Control Flow"
STACK_NAMES[7]="Loops"
STACK_NAMES[8]="Functions"
STACK_NAMES[9]="Input/Output & Redirection"
STACK_NAMES[10]="Regular Expressions"
STACK_NAMES[11]="Process Management"
STACK_NAMES[12]="Advanced Scripting"
STACK_NAMES[13]="Cron & Scheduling"
STACK_NAMES[14]="Git for Scripters"
STACK_NAMES[15]="Docker & Bash"
STACK_NAMES[16]="SSH & Remote Management"
STACK_NAMES[17]="Network Scripting"
STACK_NAMES[18]="System Monitoring"
STACK_NAMES[19]="AWS CLI Scripting"
STACK_NAMES[20]="Database Operations"
STACK_NAMES[21]="Web Scraping"
STACK_NAMES[22]="Testing Bash Scripts"
STACK_NAMES[23]="Security Scripting"
STACK_NAMES[24]="Backup Strategies"
STACK_NAMES[25]="Zsh Essentials"
STACK_NAMES[26]="Vim for Scripters"
STACK_NAMES[27]="Systemd Deep Dive"
STACK_NAMES[28]="Package Management"
STACK_NAMES[29]="CI/CD Pipelines"
STACK_NAMES[30]="Logging Best Practices"
STACK_NAMES[31]="Kubernetes Basics"
STACK_NAMES[32]="User Management"
STACK_NAMES[33]="LVM"
STACK_NAMES[34]="NFS, Samba, SSHFS"
STACK_NAMES[35]="Firewall & Security"
STACK_NAMES[36]="Terraform Basics"
STACK_NAMES[37]="Prometheus & Grafana"
STACK_NAMES[38]="Ansible Essentials"
STACK_NAMES[39]="System Hardening"
STACK_NAMES[40]="GitLab CI/CD"
STACK_NAMES[41]="Performance Tuning"
STACK_NAMES[42]="Raspberry Pi Projects"
STACK_NAMES[43]="Windows WSL"
STACK_NAMES[44]="ShellCheck & Linting"
STACK_NAMES[45]="Advanced Patterns"
STACK_NAMES[46]="Career & Production"
STACK_NAMES[47]="Advanced Git Workflows"
STACK_NAMES[48]="Load Balancing & Proxy"
STACK_NAMES[49]="High Availability"
STACK_NAMES[50]="Email Server"
STACK_NAMES[51]="DNS Management"
STACK_NAMES[52]="SSL/TLS"
STACK_NAMES[53]="Terminal UI Development"
STACK_NAMES[54]="IPC Mechanisms"
STACK_NAMES[55]="Advanced Debugging & Profiling"
STACK_NAMES[56]="Security Auditing & Forensics"
STACK_NAMES[57]="Advanced Data Structures"
STACK_NAMES[58]="API & Web Services"
STACK_NAMES[59]="Multi-Cluster Orchestration"

TOTAL_STACKS=59

print_header() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║     🐚 Full Stack Bash Course - Progress Tracker 🐚       ║"
    echo "║              59 STACKS - Complete Course                  ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
}

load_progress() {
    if [ -f "$PROGRESS_FILE" ]; then
        cat "$PROGRESS_FILE"
    else
        echo ""
    fi
}

get_completed_count() {
    load_progress | wc -w
}

get_level() {
    local stack=$1
    if [ $stack -le 10 ]; then
        echo "Beginner"
    elif [ $stack -le 20 ]; then
        echo "Intermediate"
    elif [ $stack -le 30 ]; then
        echo "Advanced"
    elif [ $stack -le 40 ]; then
        echo "Expert"
    elif [ $stack -le 46 ]; then
        echo "Master"
    else
        echo "Expert Edition"
    fi
}

mark_complete() {
    local stack_num=$1
    if ! grep -q "^${stack_num}$" "$PROGRESS_FILE" 2>/dev/null; then
        echo "$stack_num" >> "$PROGRESS_FILE"
        echo "✓ Marked Stack $stack_num (${STACK_NAMES[$stack_num]}) as complete!"
    else
        echo "Stack $stack_num is already marked as complete."
    fi
}

show_progress() {
    print_header
    
    local completed=($(load_progress))
    local completed_count=${#completed[@]}
    local percentage=$((completed_count * 100 / TOTAL_STACKS))
    
    # Progress bar (59 segments)
    printf "${GREEN}Progress: [${NC}"
    for i in $(seq 1 $TOTAL_STACKS); do
        if echo "${completed[@]}" | grep -qw "$i"; then
            printf "${GREEN}█${NC}"
        else
            printf "░"
        fi
    done
    printf "${GREEN}]${NC} %d%% (%d/%d)\n" "$percentage" "$completed_count" "$TOTAL_STACKS"
    echo ""
    
    # Stack details by level
    echo -e "${GREEN}═══════════════════════ BEGINNER (1-10) ════════════════${NC}"
    for i in $(seq 1 10); do
        if echo "${completed[@]}" | grep -qw "$i"; then
            printf "  ✅ Stack %2d: %-35s\n" "$i" "${STACK_NAMES[$i]}"
        else
            printf "  ❌ Stack %2d: %-35s\n" "$i" "${STACK_NAMES[$i]}"
        fi
    done
    
    echo -e "${YELLOW}═══════════════════════ INTERMEDIATE (11-20) ════════════════${NC}"
    for i in $(seq 11 20); do
        if echo "${completed[@]}" | grep -qw "$i"; then
            printf "  ✅ Stack %2d: %-35s\n" "$i" "${STACK_NAMES[$i]}"
        else
            printf "  ❌ Stack %2d: %-35s\n" "$i" "${STACK_NAMES[$i]}"
        fi
    done
    
    echo -e "${MAGENTA}═══════════════════════ ADVANCED (21-30) ════════════════${NC}"
    for i in $(seq 21 30); do
        if echo "${completed[@]}" | grep -qw "$i"; then
            printf "  ✅ Stack %2d: %-35s\n" "$i" "${STACK_NAMES[$i]}"
        else
            printf "  ❌ Stack %2d: %-35s\n" "$i" "${STACK_NAMES[$i]}"
        fi
    done
    
    echo -e "${RED}═══════════════════════ EXPERT (31-40) ════════════════${NC}"
    for i in $(seq 31 40); do
        if echo "${completed[@]}" | grep -qw "$i"; then
            printf "  ✅ Stack %2d: %-35s\n" "$i" "${STACK_NAMES[$i]}"
        else
            printf "  ❌ Stack %2d: %-35s\n" "$i" "${STACK_NAMES[$i]}"
        fi
    done
    
    echo -e "${BLUE}═══════════════════════ MASTER (41-46) ════════════════${NC}"
    for i in $(seq 41 46); do
        if echo "${completed[@]}" | grep -qw "$i"; then
            printf "  ✅ Stack %2d: %-35s\n" "$i" "${STACK_NAMES[$i]}"
        else
            printf "  ❌ Stack %2d: %-35s\n" "$i" "${STACK_NAMES[$i]}"
        fi
    done

    echo -e "${CYAN}═══════════════════════ EXPERT EDITION (47-59) ════════════════${NC}"
    for i in $(seq 47 $TOTAL_STACKS); do
        if echo "${completed[@]}" | grep -qw "$i"; then
            printf "  ✅ Stack %2d: %-35s\n" "$i" "${STACK_NAMES[$i]}"
        else
            printf "  ❌ Stack %2d: %-35s\n" "$i" "${STACK_NAMES[$i]}"
        fi
    done
    
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo -e "Total completed: ${GREEN}$completed_count${NC} / $TOTAL_STACKS stacks"
    if [ $completed_count -eq $TOTAL_STACKS ]; then
        echo -e "${GREEN}🎓 Congratulations! You are now a Full Stack Bash Developer! 🐚${NC}"
    fi
    echo "════════════════════════════════════════════════════════════"
    echo ""
}

reset_progress() {
    echo "Are you sure you want to reset ALL progress? (y/n)"
    read -r confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        > "$PROGRESS_FILE"
        echo "Progress reset! Start fresh!"
    else
        echo "Reset cancelled."
    fi
}

case "${1:-show}" in
    show)
        show_progress
        ;;
    mark)
        if [ -z "${2:-}" ]; then
            echo "Usage: $0 mark <stack_number>"
            echo "Example: $0 mark 5"
            exit 1
        fi
        mark_complete "$2"
        show_progress
        ;;
    reset)
        reset_progress
        ;;
    *)
        echo "Usage: $0 {show|mark|reset}"
        echo ""
        echo "Commands:"
        echo "  show          Show progress (default)"
        echo "  mark <n>     Mark stack n as complete"
        echo "               Example: $0 mark 5"
        echo "  reset         Reset all progress"
        echo ""
        echo "Example workflow:"
        echo "  $0 mark 1     # Mark Stack 1 complete"
        echo "  $0 mark 10    # Mark Stack 10 complete"
        echo "  $0 show       # View progress"
        exit 1
        ;;
esac
