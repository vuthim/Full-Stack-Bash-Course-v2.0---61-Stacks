# 📝 STACK 26: VIM FOR SCRIPTERS [ELECTIVE]
## The Power Editor for Bash Developers

**What is Vim?** Vim is like a power tool for text editing. Once you learn the basic gestures, you can edit text incredibly fast - no mouse needed! It has a learning curve, but the payoff is huge.

**Why Learn It?** Vim is installed on virtually every Linux server. When you SSH into a remote machine, vim might be your only option for editing files.

---

## 🔰 Why Vim?

Vim (Vi Improved) is a highly configurable text editor included in most Unix systems. It allows for extremely efficient editing, especially for programmers.

### Benefits for Scripters
- ✅ **Speed**: Keyboard-only, no mouse needed (hands never leave home row!)
- ✅ **Power**: Built-in regex, macro recording, multi-file editing
- ✅ **Ubiquity**: Available on virtually every Linux system (your rescue tool!)
- ✅ **Customization**: Highly configurable via .vimrc

### The Vim Mindset Shift
```
Normal editors: Type → Click to move → Type more
Vim:            Think → Command → Done!

Example: "Delete everything inside these quotes"
Normal: Click, hold, drag, delete
Vim:      di"    (done!)
```

**Pro Tip:** You don't need to memorize everything. Learn 5 commands, use them until they're muscle memory, then add 5 more.

---

## ⚡ Installing Vim

### Ubuntu/Debian
```bash
sudo apt update
sudo apt install vim
```

### Fedora/RHEL
```bash
sudo dnf install vim
```

### macOS
```bash
# Pre-installed or via Homebrew
brew install vim
```

---

## 🎯 Vim Modes

Vim has multiple modes - understanding them is key:

| Mode | Purpose | How to Exit |
|------|---------|-------------|
| Normal | Navigate and run commands | Press Esc |
| Insert | Type text | Press Esc |
| Visual | Select text | Press Esc |
| Command | Run ex commands | Press Enter |

### Mode Switching
```vim
i       " Enter Insert mode
a       " Append after cursor
A       " Append at end of line
o       " Open new line below
O       " Open new line above
v       " Visual mode
V       " Visual line mode
Ctrl+v  " Visual block mode
:       " Command mode
Esc     " Return to Normal mode
```

---

## 📖 Basic Navigation

### Character Navigation
```vim
h       " Left
j       " Down
k       " Up
l       " Right
```

### Word Navigation
```vim
w       " Forward to next word
b       " Back to previous word
e       " Forward to end of word
ge      " Back to end of previous word
```

### Line Navigation
```vim
0       " Beginning of line
$       " End of line
^       " First non-blank character
```

### Document Navigation
```vim
gg      " First line
G       " Last line
Ctrl+d  " Down half page
Ctrl+u  " Up half page
Ctrl+b  " Up one page
Ctrl+f  " Down one page
:100    " Go to line 100
```

### Search Navigation
```vim
/pattern    " Search forward
?pattern    " Search backward
n           " Next match
N           " Previous match
*           " Search word under cursor
#           " Search word backward
```

---

## ✏️ Basic Editing

### Inserting Text
```vim
i       " Insert before cursor
I       " Insert at beginning of line
a       " Append after cursor
A       " Append at end of line
o       " New line below
O       " New line above
```

### Deleting Text
```vim
x           " Delete character
X           " Delete character before
dw          " Delete word
dd          " Delete line
d$          " Delete to end of line
d0          " Delete to beginning of line
dgg         " Delete to beginning of file
dG          " Delete to end of file
```

### Copy and Paste
```vim
yy          " Yank (copy) line
y$          " Yank to end of line
yw          " Yank word
p           " Paste after cursor
P           " Paste before cursor
dd          " Delete and copy to register
xp          " Transpose characters
```

### Undo and Redo
```vim
u           " Undo
Ctrl+r      " Redo
U           " Undo all changes on line
```

---

## 🔧 Visual Mode

### Selecting Text
```vim
v       " Visual (character)
V       " Visual line
Ctrl+v  " Visual block
```

### In Visual Mode
```vim
y       " Yank selection
d       " Delete selection
c       " Change selection
>       " Indent
<       " Un-indent
```

### Practical Example
```vim
# Select multiple lines and indent
Vjj     " Select 3 lines
>       " Indent them
```

---

## 🔍 Search and Replace

### Basic Search
```vim
:/pattern     " Search forward
:?pattern    " Search backward
```

### Replace Command
```vim
:s/old/new/           " Replace first match on line
:s/old/new/g          " Replace all on line
:s/old/new/gc         " Replace all (confirm each)
:%s/old/new/g        " Replace all in file
:%s/old/new/gc       " Replace all (confirm)
```

### Regex Examples
```vim
# Replace with literal period
:%s/\./,/g

# Replace digits
:%s/[0-9]/X/g

# Replace word boundaries
:%s/\<old\>/new/g
```

---

## 📐 Indentation

### Basic Indent
```vim
>>       " Indent line
<<       " Un-indent line
5>>      " Indent 5 lines
5==      " Re-indent 5 lines
```

### Auto-indent
```vim
# In Command mode
=

# Auto-indent current paragraph
=ap

# In insert mode
Ctrl+t     " Indent
Ctrl+d     " Un-indent
```

---

## 🔄 Macros

### Recording a Macro
```vim
q[a-z]     " Start recording to register a-z
...        " Your commands
q          " Stop recording
```

### Playing a Macro
```vim
@[a-z]     " Play macro from register a-z
@@         " Repeat last macro
100@a      " Play macro 100 times
```

### Practical Example
```vim
# Add ; to end of multiple lines
qa         " Start recording
$          " Go to end of line
a;         " Add semicolon
Esc        " Exit insert mode
j          " Move down
q          " Stop recording
10@a       " Apply to next 10 lines
```

---

## ⚙️ Configuration (~/.vimrc)

### Basic Settings
```vim
" ~/.vimrc

" Enable syntax highlighting
syntax on

" Enable line numbers
set number

" Enable mouse support
set mouse=a

" Enable incremental search
set incsearch

" Highlight search results
set hlsearch

" Enable auto-indent
set autoindent
set smartindent

" Enable filetype detection
filetype plugin indent on

" Set tab width
set tabstop=4
set shiftwidth=4
set expandtab

" Show line/column
set ruler

" Enable hidden buffers
set hidden
```

### Custom Key Mappings
```vim
" Leader key
let mapleader = ","

" Quick save
nnoremap <leader>w :w<CR>

" Quick quit
nnoremap <leader>q :q<CR>

" Save and quit
nnoremap <leader>x :wq<CR>

" Move lines up/down
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
```

### Plugin: vim-plug
```vim
" Install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

" Add to .vimrc
call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
call plug#end()
```

---

## 🎯 Essential Plugins

### NERDTree (File Browser)
```vim
Plug 'preservim/nerdtree'
nnoremap <leader>n :NERDTreeToggle<CR>
```

### vim-airline (Status Bar)
```vim
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
```

### vim-gitgutter (Git Integration)
```vim
Plug 'airblade/vim-gitgutter'
```

### coc.nvim (Intellisense)
```vim
Plug 'neoclide/coc.nvim', {'branch': 'release'}
```

---

## 🔢 Numbers and Counts

### Prefix Commands with Numbers
```vim
5j       " Move down 5 lines
3w       " Move forward 3 words
10x      " Delete 10 characters
2dd      " Delete 2 lines
5yy      " Yank 5 lines
```

---

## 📋 Vim for Bash Scripts

### Shebang Line
```bash
#!/bin/bash
```

### Common Editing Tasks
```vim
# Comment multiple lines
Ctrl+v
jjjj
I#
Esc

# Uncomment
Ctrl+v
jjjj
x

# Move a block
剪切多行
p
```

---

## 🏆 Practice Exercises

### Exercise 1: Basic Navigation
```bash
# Create a test file
cat > test.txt << 'EOF'
Line one
Line two
Line three
Line four
Line five
EOF

vim test.txt

# Practice:
# j, k, h, l - movement
# w, b - word movement
# gg, G - document navigation
# / - search
# :q! to quit without saving
```

### Exercise 2: Editing
```vim
# Practice these commands:
i       " Insert text
dd      " Delete line
yy      " Copy line
p       " Paste
u       " Undo
Ctrl+r  " Redo
```

### Exercise 3: Search and Replace
```vim
# Replace all 'foo' with 'bar'
:%s/foo/bar/g

# Replace with confirmation
:%s/foo/bar/gc
```

### Exercise 4: Create a Macro
```vim
# Add line numbers to start of each line
qa
I# 
Esc
j
q
5@a
```

---

## 📋 Vim Cheat Sheet

### Movement
| Command | Action |
|---------|--------|
| `h/j/k/l` | Left/Down/Up/Right |
| `w/b/e` | Word forward/back/end |
| `gg/G` | File start/end |
| `/` | Search |

### Editing
| Command | Action |
|---------|--------|
| `i/a` | Insert before/after |
| `dd` | Delete line |
| `yy` | Yank line |
| `p/P` | Paste after/before |
| `u` | Undo |

### Other
| Command | Action |
|---------|--------|
| `:w` | Save |
| `:q` | Quit |
| `:wq` | Save and quit |
| `Esc` | Exit mode |

---

## ✅ Stack 26 Complete!

You learned:
- ✅ What is Vim and why use it
- ✅ Vim modes (Normal, Insert, Visual, Command)
- ✅ Navigation commands
- ✅ Basic editing (insert, delete, copy, paste)
- ✅ Search and replace
- ✅ Macros
- ✅ Configuration and plugins

### Next: Stack 27 - Systemd Deep Dive →

---

## 📝 Challenge: Vim as Your Editor

1. Create a proper ~/.vimrc with useful settings
2. Install vim-plug and a few useful plugins
3. Practice until you can edit without looking at the keyboard

---

*End of Stack 26*