#!/bin/bash
# 🐚 Full Stack Bash Course - Main Launcher
# 61 STACKS Complete! (59 + 2 NEW: 3B, 12B)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# Options
set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LESSONS_DIR="$SCRIPT_DIR/lessons"
SOLUTIONS_DIR="$SCRIPT_DIR/solutions"
DATA_DIR="$SCRIPT_DIR/data"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"
TOTAL_STACKS=61

# Load progress if available
load_progress() {
    local progress_file="$SCRIPT_DIR/.progress"
    if [ -f "$progress_file" ]; then
        cat "$progress_file"
    fi
}

save_progress() {
    local stack_num=$1
    local progress_file="$SCRIPT_DIR/.progress"
    if ! grep -q "^${stack_num}$" "$progress_file" 2>/dev/null; then
        echo "$stack_num" >> "$progress_file"
    fi
}

show_banner() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                           ║${NC}"
    echo -e "${CYAN}║   ${WHITE}🐚 FULL STACK BASH COURSE - 61 STACKS 🐚${CYAN}║${NC}"
    echo -e "${CYAN}║   ${WHITE}Complete Shell Scripting Mastery${CYAN}         ║${NC}"
    echo -e "${CYAN}║   ${YELLOW}⭐ NEW: Stack 3B (Safety) & 12B (Portability)${CYAN}  ║${NC}"
    echo -e "${CYAN}║                                                           ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Show progress
    local completed_count=$(load_progress | wc -w)
    local percent=$(( (completed_count * 100) / TOTAL_STACKS ))
    local bar_len=40
    local filled=$(( (completed_count * bar_len) / TOTAL_STACKS ))
    local empty=$(( bar_len - filled ))
    
    printf "${YELLOW}📊 Progress: [%-s%-s] %d%% (%d/%d)${NC}\n" \
        "$(printf '#%.0s' $(seq 1 $filled 2>/dev/null || true))" \
        "$(printf '-%.0s' $(seq 1 $empty 2>/dev/null || true))" \
        "$percent" "$completed_count" "$TOTAL_STACKS"
    
    if [ "$completed_count" -ge "$TOTAL_STACKS" ]; then
        echo -e "${MAGENTA}🏆 COURSE COMPLETE! Type 'C' to get your certificate!${NC}"
    fi
    echo ""
}

generate_certificate() {
    local completed_count=$(load_progress | wc -w)
    if [ "$completed_count" -lt "$TOTAL_STACKS" ]; then
        echo -e "${RED}You must complete all 61 stacks to earn your certificate!${NC}"
        sleep 2
        return
    fi
    
    clear
    echo -e "${CYAN}📜 GENERATING CERTIFICATE...${NC}"
    sleep 1
    
    local cert_file="$SCRIPT_DIR/BASH_MASTER_CERTIFICATE.txt"
    cat > "$cert_file" << EOF
 *******************************************************************************
 *                                                                             *
 *                      🐚 FULL STACK BASH DEVELOPER 🐚                         *
 *                                                                             *
 *                          CERTIFICATE OF MASTERY                             *
 *                                                                             *
 *         This certifies that the user has successfully completed             *
 *         all 61 Stacks of the Complete Shell Scripting Course.              *
 *                                                                             *
 *         Topics Mastered:                                                    *
 *         - Fundamentals & File Ops       - Advanced Scripting & Debugging    *
 *         - Quoting, Expansion, Safety    - POSIX Portability                 *
 *         - Text Processing (Grep/Awk)     - Automation & Cron Scheduling      *
 *         - DevOps, Production, Security  - APIs, Debugging, Orchestration    *
 *                                                                             *
 *         Date: $(date)                                               *
 *                                                                             *
 *******************************************************************************
EOF
    cat "$cert_file"
    echo ""
    echo -e "${GREEN}Certificate saved to: $cert_file${NC}"
    read -p "Press Enter to continue..."
}

search_lessons() {
    clear
    echo -e "${CYAN}🔍 SEARCH LESSONS${NC}"
    echo ""
    read -p "Enter keyword: " keyword
    if [ -z "$keyword" ]; then return; fi
    
    echo -e "${YELLOW}Matches found:${NC}"
    # Use find to avoid "too many arguments" and grep to search content
    find "$LESSONS_DIR" -maxdepth 1 -name "*.md" -exec grep -il "$keyword" {} + | sort | while read -r file; do
        local base=$(basename "$file")
        local stack_num=$(echo "$base" | cut -d'_' -f1)
        local title=$(echo "$base" | cut -d'_' -f2- | sed 's/\.md//' | tr '_' ' ')
        echo -e "${GREEN}Stack $stack_num:${NC} $title"
    done
    echo ""
    read -p "Press Enter to continue..."
}

suggest_next_lesson() {
    local completed=($(load_progress | sort -n))
    local next=""
    
    # Check if specific lessons are completed
    local has_3b=$(echo "${completed[@]}" | grep -c "3B" || true)
    local has_12b=$(echo "${completed[@]}" | grep -c "12B" || true)
    
    # If we haven't done 3B after stack 3, suggest it
    if [ "$has_3b" -eq 0 ]; then
        # Check if stacks 1-3 are done
        for s in 1 2 3; do
            if ! echo "${completed[@]}" | grep -qw "$s"; then
                next=""
                break
            fi
            next=""
        done
        if [ -z "$next" ] && [ "$has_3b" -eq 0 ]; then
            next="3B"
        fi
    fi
    
    # If we haven't done 12B after stack 12, suggest it
    if [ -z "$next" ] && [ "$has_12b" -eq 0 ]; then
        for s in $(seq 1 12); do
            if ! echo "${completed[@]}" | grep -qw "$s"; then
                next=""
                break
            fi
            next=""
        done
        if [ -z "$next" ] && [ "$has_12b" -eq 0 ]; then
            next="12B"
        fi
    fi
    
    # Otherwise, find next uncompleted standard lesson
    if [ -z "$next" ]; then
        for i in $(seq 1 59); do
            if ! echo "${completed[@]}" | grep -qw "$i"; then
                next="$i"
                break
            fi
        done
    fi
    
    if [ -n "$next" ] && [ "$next" -le 61 ] 2>/dev/null || [ "$next" = "3B" ] || [ "$next" = "12B" ]; then
        echo -e "${YELLOW}💡 Suggested Next: Stack $next${NC}"
    fi
}

show_lesson_range() {
    local color=$1
    local heading=$2
    shift 2

    echo -e "${color}┌───────────────────────────────────────${NC}${color} ${heading} ─${NC}"
    while [ "$#" -gt 0 ]; do
        local left_num=$1
        local left_title=$2
        shift 2

        if [ "$#" -gt 0 ]; then
            local right_num=$1
            local right_title=$2
            shift 2
            printf "%b│%b %b%-2s.%b %-28s %b%-2s.%b %s\n" \
                "$color" "$NC" "$color" "$left_num" "$NC" "$left_title" "$color" "$right_num" "$NC" "$right_title"
        else
            printf "%b│%b %b%-2s.%b %s\n" \
                "$color" "$NC" "$color" "$left_num" "$NC" "$left_title"
        fi
    done
    echo -e "${color}└───────────────────────────────────────┘${NC}"
}

show_menu() {
    show_banner
    suggest_next_lesson
    echo -e "${BOLD}📚 SELECT A STACK:${NC}"
    echo ""
    
    show_lesson_range "$GREEN" "Beginner" \
        1 "Bash Fundamentals" \
        6 "Control Flow" \
        2 "File & Directory Ops" \
        7 "Loops" \
        3 "File Viewing & Editing" \
        8 "Functions" \
        4 "Text Processing" \
        9 "I/O Redirection" \
        5 "Variables & Data Types" \
        10 "Regular Expressions" \
        "3B" "Quoting & Safety ⭐NEW" \
        "12B" "POSIX Portability ⭐NEW"

    show_lesson_range "$YELLOW" "Intermediate" \
        11 "Process Management" \
        16 "SSH & Remote" \
        12 "Advanced Scripting" \
        17 "Network Scripting" \
        13 "Cron & Scheduling" \
        18 "System Monitoring" \
        14 "Git for Scripters" \
        19 "AWS CLI Scripting" \
        15 "Docker & Bash" \
        20 "Database Operations"

    show_lesson_range "$MAGENTA" "Advanced" \
        21 "Advanced curl & jq" \
        26 "[ELEC] Vim Editor" \
        22 "Testing Bash Scripts" \
        27 "Systemd" \
        23 "Security Scripting" \
        28 "Package Management" \
        24 "Backup Strategies" \
        29 "CI/CD Pipelines" \
        25 "[ELEC] Zsh Essentials" \
        30 "Logging"

    show_lesson_range "$RED" "Expert" \
        31 "Kubernetes" \
        36 "Terraform" \
        32 "User Management" \
        37 "Prometheus/Grafana" \
        33 "LVM" \
        38 "Ansible" \
        34 "NFS/Samba" \
        39 "System Hardening" \
        35 "Firewall & Security" \
        40 "GitLab CI/CD"

    show_lesson_range "$BLUE" "Master" \
        41 "Performance Tuning" \
        44 "ShellCheck" \
        42 "[ELEC] Raspberry Pi" \
        45 "Advanced Patterns" \
        43 "[ELEC] WSL Windows" \
        46 "Career & Production"

    show_lesson_range "$CYAN" "Expert Edition" \
        47 "Advanced Git" \
        54 "IPC Mechanisms" \
        48 "Load Balancing" \
        55 "Advanced Debugging" \
        49 "High Availability" \
        56 "Security Forensics" \
        50 "Email Server" \
        57 "Data Structures" \
        51 "DNS Management" \
        58 "API Services" \
        52 "SSL/TLS" \
        59 "[ELEC] Multi-Cluster" \
        53 "Terminal UI Dev"
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}F.${NC}  Search Lessons      ${CYAN}A.${NC}  Practice Exercises"
    echo -e "${CYAN}S.${NC}  View Solutions      ${CYAN}P.${NC}  Progress Tracker"
    echo -e "${CYAN}D.${NC}  Sample Data Files   ${CYAN}C.${NC}  Get Certificate"
    echo -e "${CYAN}Q.${NC}  Quit${NC}"
    echo ""
    echo -n "Enter your choice: "
}

show_practice() {
    clear
    echo -e "${CYAN}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}   🏋️ PRACTICE EXERCISES${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════${NC}"
    echo ""
    if [ -d "$SCRIPT_DIR/practice" ]; then
        echo "Available practice files:"
        ls -1 "$SCRIPT_DIR/practice/" 2>/dev/null || echo "No practice files yet"
    fi
    echo ""
    echo -e "${BOLD}📚 SELECT A STACK:${NC}"
    echo -e "${CYAN}   (Enter number 1-59, or 3B, 12B for new lessons)${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

show_solutions() {
    clear
    echo -e "${CYAN}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}   📝 SOLUTION FILES${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════${NC}"
    echo ""
    if [ -d "$SOLUTIONS_DIR" ]; then
        echo "Available solutions:"
        ls -1 "$SOLUTIONS_DIR/"
    else
        echo "No solutions available yet"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

show_data() {
    clear
    echo -e "${CYAN}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}   📁 SAMPLE DATA FILES${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════${NC}"
    echo ""
    if [ -d "$DATA_DIR" ]; then
        find "$DATA_DIR" -type f 2>/dev/null | head -20
    else
        echo "No sample data available yet"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

show_progress() {
    clear
    echo -e "${CYAN}══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}   📊 YOUR PROGRESS${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════════${NC}"
    echo ""
    
    local completed=($(load_progress))
    
    local level=""
    local stack_display=""
    
    # Standard stacks 1-50
    for i in $(seq 1 50); do
        case $i in
            1) level="Beginner" ;;
            11) level="Intermediate" ;;
            21) level="Advanced" ;;
            31) level="Expert" ;;
            41) level="Master" ;;
        esac
        
        if echo "${completed[@]}" | grep -qw "$i"; then
            echo -e "${GREEN}✅ Stack $i:${NC} Complete ($level)"
        else
            echo -e "${RED}❌ Stack $i:${NC} Not started ($level)"
        fi
    done
    
    # Stack 3B - Quoting & Safety
    if echo "${completed[@]}" | grep -qw "3B"; then
        echo -e "${GREEN}✅ Stack 3B:${NC} Complete (Beginner+)"
    else
        echo -e "${RED}❌ Stack 3B:${NC} Not started (Beginner+)"
    fi
    
    # Stack 12B - Portability
    if echo "${completed[@]}" | grep -qw "12B"; then
        echo -e "${GREEN}✅ Stack 12B:${NC} Complete (Intermediate+)"
    else
        echo -e "${RED}❌ Stack 12B:${NC} Not started (Intermediate+)"
    fi
    
    # Expert Edition stacks 51-59
    level="Expert Edition"
    for i in $(seq 51 59); do
        if echo "${completed[@]}" | grep -qw "$i"; then
            echo -e "${GREEN}✅ Stack $i:${NC} Complete ($level)"
        else
            echo -e "${RED}❌ Stack $i:${NC} Not started ($level)"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}Total: ${#completed[@]}/$TOTAL_STACKS stacks completed${NC}"
    echo ""
    echo -e "${CYAN}⭐ = Recommended for core Bash mastery${NC}"
    echo -e "${CYAN}[ELEC] = Elective (optional specialization)${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

read_lesson() {
    local num=$1
    local lesson_file=""
    
    # Handle special cases: 3B and 12B
    if [ "$num" = "3B" ] || [ "$num" = "3b" ]; then
        lesson_file="$LESSONS_DIR/03b_quoting_expansion.md"
        num="3B"
    elif [ "$num" = "12B" ] || [ "$num" = "12b" ]; then
        lesson_file="$LESSONS_DIR/12b_portability_posix.md"
        num="12B"
    else
        # Format number to 2 digits if single digit
        local formatted_num=$(printf "%02d" "$num" 2>/dev/null || echo "$num")
        
        # Find files starting with either the formatted or original number
        local matching_files=($(find "$LESSONS_DIR" -name "${formatted_num}_*.md" -o -name "${num}_*.md" | sort -u))
        
        if [ ${#matching_files[@]} -eq 0 ]; then
            echo -e "${RED}Lesson $num not found!${NC}"
            sleep 2
            return
        elif [ ${#matching_files[@]} -gt 1 ]; then
            echo -e "${YELLOW}Multiple lessons found for stack $num:${NC}"
            for i in "${!matching_files[@]}"; do
                echo -e "$((i+1)). $(basename "${matching_files[$i]}")"
            done
            read -p "Choose lesson (1-${#matching_files[@]}): " sub_choice
            if [[ "$sub_choice" =~ ^[0-9]+$ ]] && [ "$sub_choice" -le "${#matching_files[@]}" ]; then
                lesson_file="${matching_files[$((sub_choice-1))]}"
            else
                echo -e "${RED}Invalid choice!${NC}"
                sleep 1
                return
            fi
        else
            lesson_file="${matching_files[0]}"
        fi
    fi

    if [ -f "$lesson_file" ]; then
        save_progress "$num"
        less -R "$lesson_file"
    else
        echo -e "${RED}Error: File $lesson_file exists but is not readable.${NC}"
        sleep 2
    fi
}

main() {
    # Create progress file if not exists
    touch "$SCRIPT_DIR/.progress" 2>/dev/null || true
    
    while true; do
        show_menu
        read -p "Enter choice (number, A, S, P, D, Q): " choice
        echo ""
        
        case $choice in
            [0-9]*) read_lesson "$choice" ;;
            3b|3B) read_lesson "3B" ;;
            12b|12B) read_lesson "12B" ;;
            f|F) search_lessons ;;
            a|A) show_practice ;;
            s|S) show_solutions ;;
            p|P) show_progress ;;
            d|D) show_data ;;
            c|C) generate_certificate ;;
            q|Q) 
                echo -e "${GREEN}"
                echo "🎓 Congratulations on your learning journey!"
                echo "   You are now a Full Stack Bash Developer! 🐚"
                echo -e "${NC}"
                exit 0 
                ;;
            *) 
                echo -e "${RED}Invalid option! Press number (1-59), 3B, 12B, or letter.${NC}"
                sleep 1
                ;;
        esac
    done
}

main "$@"
