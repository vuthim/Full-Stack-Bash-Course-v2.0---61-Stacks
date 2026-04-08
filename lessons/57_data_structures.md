# 📊 STACK 57: ADVANCED DATA STRUCTURES
## Trees, Graphs, and Complex Data in Bash

**Wait, Data Structures in Bash?** Yes! While Bash isn't a programming language designed for complex data structures, you CAN implement them using arrays, associative arrays, and clever string manipulation. It's like building a Swiss Army knife out of paperclips - not the ideal tool, but surprisingly capable!

**Why Learn This?** Understanding data structures makes you a better programmer overall. Even if you'd use Python for production, knowing how to implement a linked list in Bash deepens your algorithmic thinking.

---

## 🔰 What You'll Learn

| Structure | What It Is | Bash Implementation | Common Use Case |
|-----------|------------|---------------------|-----------------|
| **Linked lists** | Chain of connected nodes | Arrays with value|next pairs | Task queues |
| **Stacks and queues** | LIFO/FIFO collections | Arrays with push/pop | Undo/redo, job scheduling |
| **Trees and hierarchies** | Parent-child relationships | Nested arrays or path strings | File systems, org charts |
| **Graph structures** | Connected nodes with edges | Adjacency lists in arrays | Network topology, dependencies |
| **Hash tables** | Key-value lookups | Associative arrays (`declare -A`) | Config maps, caches |

### The Data Structures Reality Check
```
Bash for data structures: "Can I do this?" → Yes! "Should I?" → For simple tasks, yes.
For complex data processing, use Python/Perl/Ruby.
Bash is great for: small datasets, quick scripts, learning concepts.
```

**Pro Tip:** Bash associative arrays (`declare -A`) are your most powerful data structure tool. They're like Python dictionaries - instant key-value lookups!

---

## 🔗 Linked Lists

### Basic Linked List
```bash
#!/bin/bash
# linked_list.sh

# Node structure: value|next
# Implementation using arrays

declare -a LIST_DATA
declare -a LIST_NEXT
HEAD=-1
TAIL=-1

# Add element to list
add_element() {
    local value="$1"
    local index=${#LIST_DATA[@]}
    
    LIST_DATA[index]="$value"
    LIST_NEXT[index]=-1
    
    if [ "$HEAD" -eq -1 ]; then
        HEAD=$index
        TAIL=$index
    else
        LIST_NEXT[TAIL]=$index
        TAIL=$index
    fi
}

# Traverse list
traverse_list() {
    local current=$HEAD
    while [ "$current" -ne -1 ]; do
        echo "${LIST_DATA[current]}"
        current=${LIST_NEXT[current]}
    done
}

# Find element
find_element() {
    local value="$1"
    local current=$HEAD
    
    while [ "$current" -ne -1 ]; do
        if [ "${LIST_DATA[current]}" = "$value" ]; then
            echo "Found at index: $current"
            return 0
        fi
        current=${LIST_NEXT[current]}
    done
    echo "Not found"
    return 1
}

# Delete element
delete_element() {
    local value="$1"
    local current=$HEAD
    local prev=-1
    
    while [ "$current" -ne -1 ]; do
        if [ "${LIST_DATA[current]}" = "$value" ]; then
            if [ "$prev" -eq -1 ]; then
                HEAD=${LIST_NEXT[current]}
            else
                LIST_NEXT[prev]=${LIST_NEXT[current]}
            fi
            return 0
        fi
        prev=$current
        current=${LIST_NEXT[current]}
    done
    return 1
}

# Usage
add_element "apple"
add_element "banana"
add_element "cherry"

echo "List contents:"
traverse_list

find_element "banana"
delete_element "banana"
echo "After deletion:"
traverse_list
```

---

## 📚 Stacks & Queues

### Stack Implementation
```bash
#!/bin/bash
# stack.sh

declare -a STACK
TOP=-1

push() {
    STACK+=("$1")
    ((TOP++))
}

pop() {
    if [ "$TOP" -lt 0 ]; then
        echo "Stack underflow"
        return 1
    fi
    local value="${STACK[TOP]}"
    unset 'STACK[TOP]'
    ((TOP--))
    echo "$value"
}

peek() {
    if [ "$TOP" -lt 0 ]; then
        echo "Stack empty"
        return 1
    fi
    echo "${STACK[TOP]}"
}

is_empty() {
    [ "$TOP" -lt 0 ]
}

# Usage
push "first"
push "second"
push "third"

echo "Peek: $(peek)"
echo "Pop: $(pop)"
echo "Pop: $(pop)"
echo "Pop: $(pop)"
```

### Queue Implementation
```bash
#!/bin/bash
# queue.sh

declare -a QUEUE
FRONT=0
REAR=-1

enqueue() {
    QUEUE+=("$1")
    ((REAR++))
}

dequeue() {
    if [ $FRONT -gt $REAR ]; then
        echo "Queue underflow"
        return 1
    fi
    local value="${QUEUE[$FRONT]}"
    unset 'QUEUE[$FRONT]'
    ((FRONT++))
    echo "$value"
}

peek() {
    if [ $FRONT -gt $REAR ]; then
        echo "Queue empty"
        return 1
    fi
    echo "${QUEUE[$FRONT]}"
}

size() {
    echo $((REAR - FRONT + 1))
}

# Usage
enqueue "first"
enqueue "second"
enqueue "third"

echo "Size: $(size)"
echo "Dequeue: $(dequeue)"
echo "Dequeue: $(dequeue)"
echo "Peek: $(peek)"
echo "Dequeue: $(dequeue)"
```

---

## 🌳 Trees

### Binary Search Tree
```bash
#!/bin/bash
# bst.sh

# BST using associative arrays
declare -A LEFT RIGHT VALUE

insert_node() {
    local value="$1"
    local node=${2:-root}
    
    if [ -z "${VALUE[$node]:-}" ]; then
        VALUE[$node]="$value"
        return
    fi
    
    if [ "$value" -lt "${VALUE[$node]}" ]; then
        local left="${node}_L"
        if [ -z "${VALUE[$left]:-}" ]; then
            LEFT[$node]="$left"
        fi
        insert_node "$value" "$left"
    else
        local right="${node}_R"
        if [ -z "${VALUE[$right]:-}" ]; then
            RIGHT[$node]="$right"
        fi
        insert_node "$value" "$right"
    fi
}

# In-order traversal
inorder() {
    local node=${1:-root}
    
    if [ -n "${LEFT[$node]:-}" ]; then
        inorder "${LEFT[$node]}"
    fi
    
    echo -n "${VALUE[$node]:-} "
    
    if [ -n "${RIGHT[$node]:-}" ]; then
        inorder "${RIGHT[$node]}"
    fi
}

# Search
search() {
    local value="$1"
    local node=${2:-root}
    
    if [ -z "${VALUE[$node]:-}" ]; then
        return 1
    fi
    
    if [ "$value" -eq "${VALUE[$node]}" ]; then
        echo "Found at $node"
        return 0
    fi
    
    if [ "$value" -lt "${VALUE[$node]}" ]; then
        search "$value" "${LEFT[$node]:-}"
    else
        search "$value" "${RIGHT[$node]:-}"
    fi
}

# Usage
insert_node 50
insert_node 30
insert_node 70
insert_node 20
insert_node 40
insert_node 60
insert_node 80

echo "In-order traversal:"
inorder | fmt

search 40
search 90
```

### Directory Tree
```bash
#!/bin/bash
# dir_tree.sh

print_tree() {
    local dir="$1"
    local prefix="$2"
    local is_last="$3"
    
    local name=$(basename "$dir")
    local connector="├── "
    [ "$is_last" = "true" ] && connector="└── "
    
    echo "${prefix}${connector}${name}/"
    
    local items=($(ls -A "$dir" 2>/dev/null))
    local total=${#items[@]}
    local count=0
    
    for item in "${items[@]}"; do
        ((count++))
        local is_last_item=$([ $count -eq $total ] && echo "true" || echo "false")
        
        if [ -d "$dir/$item" ]; then
            local new_prefix="$prefix"
            [ "$is_last" = "true" ] && new_prefix="$prefix   " || new_prefix="$prefix│  "
            print_tree "$dir/$item" "$new_prefix" "$is_last_item"
        else
            local conn="├── "
            [ "$is_last_item" = "true" ] && conn="└── "
            echo "${prefix}${conn}${item}"
        fi
    done
}

# Usage
print_tree "/path/to/dir" "" "true"
```

---

## 🔀 Graphs

### Adjacency List Graph
```bash
#!/bin/bash
# graph.sh

declare -A ADJACENCY
declare -a VERTICES

add_vertex() {
    local v="$1"
    VERTICES+=("$v")
    ADJACENCY[$v]=""
}

add_edge() {
    local from="$1"
    local to="$2"
    
    if [ -z "${ADJACENCY[$from]:-}" ]; then
        ADJACENCY[$from]="$to"
    else
        ADJACENCY[$from]="${ADJACENCY[$from]} $to"
    fi
}

add_undirected_edge() {
    add_edge "$1" "$2"
    add_edge "$2" "$1"
}

# BFS
bfs() {
    local start="$1"
    local visited=()
    local queue=("$start")
    
    while [ ${#queue[@]} -gt 0 ]; do
        local current="${queue[0]}"
        queue=("${queue[@]:1}")
        
        if [[ " ${visited[@]} " =~ " $current " ]]; then
            continue
        fi
        
        visited+=("$current")
        echo -n "$current "
        
        for neighbor in ${ADJACENCY[$current]:-}; do
            if [[ ! " ${visited[@]} " =~ " $neighbor " ]]; then
                queue+=("$neighbor")
            fi
        done
    done
    echo
}

# DFS
dfs() {
    local node="$1"
    shift
    local visited=("$@")
    
    if [[ " ${visited[@]} " =~ " $node " ]]; then
        return
    fi
    
    visited+=("$node")
    echo -n "$node "
    
    for neighbor in ${ADJACENCY[$node]:-}; do
        dfs "$neighbor" "${visited[@]}"
    done
}

# Usage
for v in A B C D E; do add_vertex "$v"; done

add_undirected_edge "A" "B"
add_undirected_edge "A" "C"
add_undirected_edge "B" "D"
add_undirected_edge "C" "D"
add_undirected_edge "D" "E"

echo "BFS from A:"
bfs "A"

echo "DFS from A:"
dfs "A"
echo ""
```

---

## 🗺️ Hash Tables (Associative Arrays)

### Basic Hash Table
```bash
#!/bin/bash
# hash_table.sh

declare -A HASH_TABLE

# Set value
set() {
    local key="$1"
    local value="$2"
    HASH_TABLE[$key]="$value"
}

# Get value
get() {
    local key="$1"
    echo "${HASH_TABLE[$key]:-}"
}

# Delete
delete() {
    local key="$1"
    unset 'HASH_TABLE[$key]'
}

# Check existence
exists() {
    local key="$1"
    [ -n "${HASH_TABLE[$key]:-}" ]
}

# Get all keys
keys() {
    echo "${!HASH_TABLE[@]}"
}

# Get all values
values() {
    echo "${HASH_TABLE[@]}"
}

# Size
size() {
    echo "${#HASH_TABLE[@]}"
}

# Usage
set "name" "John"
set "age" "30"
set "city" "New York"

echo "Name: $(get "name")"
echo "Age: $(get "age")"

echo "All keys: $(keys)"
echo "All values: $(values)"
echo "Size: $(size)"

if exists "name"; then
    echo "Name exists"
fi
```

### Hash Table with Multiple Values
```bash
#!/bin/bash
# multi_hash.sh

declare -A STUDENTS

# Add student (key format: student_ID)
add_student() {
    local id="$1"
    local name="$2"
    local grade="$3"
    
    STUDENTS["${id}_name"]="$name"
    STUDENTS["${id}_grade"]="$grade"
}

get_student() {
    local id="$1"
    echo "Name: ${STUDENTS[${id}_name]:-N/A}"
    echo "Grade: ${STUDENTS[${id}_grade]:-N/A}"
}

list_students() {
    local ids=$(echo "${!STUDENTS[@]}" | tr ' ' '\n' | grep '_name$' | sed 's/_name//')
    echo "$ids"
}

# Usage
add_student "001" "Alice" "A"
add_student "002" "Bob" "B"
add_student "003" "Charlie" "A"

echo "Student 001:"
get_student "001"

echo "All student IDs:"
list_students
```

---

## 🔄 Sorting Algorithms

### Bubble Sort
```bash
#!/bin/bash
# bubble_sort.sh

bubble_sort() {
    local -a arr=("$@")
    local n=${#arr[@]}
    
    for ((i = 0; i < n - 1; i++)); do
        for ((j = 0; j < n - i - 1; j++)); do
            if [ "${arr[j]}" -gt "${arr[$((j + 1))]}" ]; then
                # Swap
                temp="${arr[j]}"
                arr[j]="${arr[$((j + 1))]}"
                arr[$((j + 1))]="$temp"
            fi
        done
    done
    
    echo "${arr[@]}"
}

# Usage
arr=(64 34 25 12 22 11 90)
sorted=($(bubble_sort "${arr[@]}"))
echo "Sorted: ${sorted[@]}"
```

### Quick Sort
```bash
#!/bin/bash
# quick_sort.sh

quick_sort() {
    local -a arr=("$@")
    local pivot=$1
    shift
    
    local -a less=()
    local -a greater=()
    
    for item in "$@"; do
        if [ "$item" -le "$pivot" ]; then
            less+=("$item")
        else
            greater+=("$item")
        fi
    done
    
    if [ ${#less[@]} -gt 1 ]; then
        less=($(quick_sort "${less[@]}"))
    fi
    
    if [ ${#greater[@]} -gt 1 ]; then
        greater=($(quick_sort "${greater[@]}"))
    fi
    
    echo "${less[@]} $pivot ${greater[@]}"
}

# Usage
arr=(10 80 30 90 40 50 70)
sorted=($(quick_sort "${arr[@]}"))
echo "Sorted: ${sorted[@]}"
```

---

## 🏆 Practice Exercises

### Exercise 1: Linked List
Implement a doubly linked list

### Exercise 2: Graph Algorithms
Implement Dijkstra's algorithm

### Exercise 3: Priority Queue
Implement a priority queue

---

## 🎓 Final Project: The Bash Data Structures Library

Now that you've mastered advanced data concepts, let's see how a professional Software Engineer might implement computer science fundamentals using only Bash. We'll examine the "Data Structures Library" — a collection of scripts that implement Dynamic Arrays, Linked Lists, Stacks, Queues, and even basic Trees.

### What the Bash Data Structures Library Does:
1. **Implements LIFO Stacks** (Last-In, First-Out) for managing nested operations.
2. **Creates FIFO Queues** (First-In, First-Out) for task processing and job scheduling.
3. **Builds Linked Lists** using associative arrays to "point" from one data node to another.
4. **Demonstrates Hash Tables** using Bash's built-in associative arrays for instant data lookups.
5. **Simulates Binary Trees** using structured naming conventions for parent/child relationships.
6. **Manages Dynamic Arrays** that grow and shrink automatically as data is added or removed.

### Key Snippet: Implementing a Stack (Push/Pop)
Bash arrays can be used to simulate a stack by always adding and removing from the "end" of the list.

```bash
# Define our stack array
declare -a my_stack=()

push() {
    # Add a new element to the end
    my_stack+=("$1")
}

pop() {
    # 1. Get the last index
    local last_idx=$((${#my_stack[@]} - 1))
    
    # 2. Extract the value
    local value="${my_stack[$last_idx]}"
    
    # 3. Rebuild the array without the last element
    my_stack=("${my_stack[@]:0:$last_idx}")
    
    echo "$value"
}
```

### Key Snippet: The Associative "Linked List"
Because Bash doesn't have "pointers" like C++, we use associative arrays to link one node name to the next.

```bash
# Define nodes as associative arrays
declare -A node_1=( [val]="Start" [next]="node_2" )
declare -A node_2=( [val]="Middle" [next]="node_3" )
declare -A node_3=( [val]="End"    [next]="null" )

# Traverse the list
current="node_1"
while [ "$current" != "null" ]; do
    # Use variable indirection to read the values
    val_ref="${current}[val]"
    next_ref="${current}[next]"
    
    echo "Processing: ${!val_ref}"
    current="${!next_ref}"
done
```

**Pro Tip:** While most people use Bash for simple commands, knowing how to implement these structures allows you to solve complex computational problems without needing a "heavier" language like Python or Go!

---

## ✅ Stack 57 Complete!

Congratulations! You've successfully mastered "Computer Science in the Shell"! You can now:
- ✅ **Build complex data models** using advanced Bash arrays
- ✅ **Implement Stacks and Queues** for sophisticated script logic
- ✅ **Use Linked Lists** to manage dynamic data relationships
- ✅ **Master Associative Arrays** for high-speed "Key-Value" storage
- ✅ **Understand Binary Trees** and hierarchical data structures
- ✅ **Choose the right structure** for any computational problem

### What's Next?
In the next stack, we'll dive into **API & Web Services**. You'll learn how to make your data structures "talk" to the world by building and consuming RESTful APIs using pure Bash!

**Next: Stack 58 - API & Web Services →**

---

*End of Stack 57*