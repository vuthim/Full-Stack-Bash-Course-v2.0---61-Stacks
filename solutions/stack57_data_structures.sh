#!/bin/bash
# Stack 57 Solution: Advanced Data Structures - Data Structure Examples

set -euo pipefail

NAME="Data Structures"
VERSION="1.0.0"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $*"; }

show_usage() {
    cat << EOF
$NAME v$VERSION - Advanced Data Structures in Bash

Usage: $0 [STRUCTURE]

STRUCTURES:
    array                Dynamic array example
    linked-list          Linked list example
    hash-table           Hash table example
    stack                Stack implementation
    queue                Queue implementation
    tree                 Tree example

EXAMPLES:
    $0 stack
    $0 hash-table
EOF
}

array_example() {
    echo "Dynamic Array:"
    declare -a arr=()
    
    for i in {1..5}; do
        arr+=("$i")
        echo "Added: $i, Size: ${#arr[@]}"
    done
    
    echo "Array: ${arr[@]}"
}

linked_list_example() {
    echo "Linked List:"
    
    declare -A node_1=( [value]=1 [next]=node_2 )
    declare -A node_2=( [value]=2 [next]=node_3 )
    declare -A node_3=( [value]=3 [next]=null )
    
    current="node_1"
    while [ "$current" != "null" ]; do
        echo "Value: ${!current}[value]}"
        current=${!current}[next]}
    done
}

hash_table_example() {
    echo "Hash Table:"
    declare -A hash=()
    
    hash[apple]=5
    hash[banana]=3
    hash[orange]=8
    
    for key in "${!hash[@]}"; do
        echo "$key: ${hash[$key]}"
    done
}

stack_example() {
    echo "Stack (LIFO):"
    declare -a stack=()
    
    push() { stack+=("$1"); }
    pop() { stack=("${stack[@]:0:${#stack[@]}-1}"); }
    
    push 1; push 2; push 3
    echo "After push 1,2,3: ${stack[@]}"
    pop
    echo "After pop: ${stack[@]}"
}

queue_example() {
    echo "Queue (FIFO):"
    declare -a queue=()
    
    enqueue() { queue+=("$1"); }
    dequeue() { local first="$queue"; queue=("${queue[@]:1}"); echo "$first"; }
    
    enqueue 1; enqueue 2; enqueue 3
    echo "After enqueue 1,2,3: ${queue[@]}"
    dequeue
    echo "After dequeue: ${queue[@]}"
}

tree_example() {
    echo "Binary Tree (simplified):"
    echo "       root"
    echo "      /    \\"
    echo "    left   right"
    echo "   /   \\"
    echo " leaf leaf"
}

main() {
    local struct=${1:-}
    
    case $struct in
        array) array_example ;;
        linked-list) linked_list_example ;;
        hash-table) hash_table_example ;;
        stack) stack_example ;;
        queue) queue_example ;;
        tree) tree_example ;;
        -h|--help|*) show_usage ;;
    esac
}

main "$@"
