# 📝 STACK 26: VIM FOR SCRIPTERS [ELECTIVE]
## The Power Editor for Bash Developers

**What is Vim?** Think of Vim as a keyboard-driven text editor that lets you edit files at lightning speed once you learn its commands. Unlike mouse-based editors, Vim keeps your hands on the keyboard, making you incredibly efficient after practice.

**Why Learn It?** Vim is available on almost every Linux system you'll encounter. When you SSH into a remote server to fix a script or configure a service, Vim is often your only editing option - making it an essential skill for any bash scripter or system administrator.

---

## 🔰 Why Vim?

Vim (Vi Improved) is a highly configurable text editor that's stood the test of time - it's been around since 1991 and is still widely used today. What makes Vim special is its modal editing approach, which separates different editing tasks into distinct modes for maximum efficiency.

### Benefits for Scripters
- ✅ **Lightning Fast Editing**: Once you learn the commands, you'll edit text faster than with any mouse-based editor
- ✅ **Built-in Power Tools**: Regular expressions, macros, and multi-file editing are all available without plugins
- ✅ **Works Everywhere**: Vim (or its predecessor Vi) is installed on virtually every Unix/Linux system - your go-to editor when nothing else is available
- ✅ **Highly Customizable**: Tailor Vim exactly to your workflow with the .vimrc configuration file
- ✅ **Lightning Fast Startup**: Opens instantly, even on older hardware
- ✅ **No Mouse Required**: Keep your hands on the keyboard for maximum productivity

### Understanding Vim's Approach
Traditional editors make you constantly switch between keyboard and mouse:
```
Traditional: Type → Reach for mouse → Click to position → Type more
Vim:         Think → Keyboard command → Done!
```

**Real Example:** To change text inside quotes:
- Traditional: Click at start quote, hold mouse, drag to end quote, press delete, type new text
- Vim: Type `ci"` (change inside quotes), type your new text, press Escape

**Getting Started Tip:** Don't try to learn everything at once. Focus on mastering just these 5 essential commands first:
1. `i` - Insert text
2. `Esc` - Return to normal mode
3. `:w` - Save file
4. `:q` - Quit Vim
5. `dd` - Delete a line

Once these feel natural, add 5 more commands to your repertoire. This gradual approach prevents overwhelm and builds lasting muscle memory.

---

## ⚡ Installing Vim

Vim typically comes pre-installed on most Linux distributions and macOS. If it's not already installed, here's how to get it:

### Ubuntu/Debian
```bash
# Update package list first (good practice)
sudo apt update
# Install Vim
sudo apt install vim
# Verify installation
vim --version
```

### Fedora/RHEL
```bash
# Install Vim
sudo dnf install vim
# Verify installation
vim --version
```

### macOS
```bash
# Check if Vim is already installed (it usually is)
vim --version

# If not installed or you want a newer version via Homebrew:
brew install vim
```

**Quick Test:** After installation, try opening Vim with `vim` and then type `:q` followed by Enter to quit. If you see the Vim interface briefly, you're good to go!

**Note:** On some minimal server installations, you might only have `vi` available (the original version). While `vi` works, Vim offers many enhancements that make it much more user-friendly. The commands we'll cover work in both editors, but Vim is preferred when available.

---

## 🎯 Understanding Vim's Modes

One of the things that makes Vim unique (and initially confusing for beginners) is its modal interface. Instead of having one mode where you both type text and navigate, Vim separates these into different modes. Think of it like having different tools in your toolbox - each mode is optimized for a specific task.

| Mode | What You Do There | How to Get There | How to Leave |
|------|-------------------|------------------|--------------|
| **Normal** | Navigate through text, delete, copy, paste, run commands | Default mode when you start Vim | Press `Esc` |
| **Insert** | Actually type and edit text | Press `i`, `a`, `I`, `A`, `o`, or `O` | Press `Esc` |
| **Visual** | Select text to apply operations to | Press `v`, `V`, or `Ctrl+v` | Press `Esc` |
| **Command** | Run complex commands like save, quit, search and replace | Press `:` (colon) | Press `Enter` to execute or `Esc` to cancel |

### Simple Mode Switching Guide
Here are the most common ways to switch between modes:

```vim
i       " Enter Insert mode (insert before cursor)
a       " Append after cursor (like pressing right arrow then typing)
A       " Jump to end of line and start typing
o       " Create new line below current line and start typing
O       " Create new line above current line and start typing
v       " Start selecting text character by character
V       " Start selecting whole lines
Ctrl+v  " Start selecting rectangular blocks of text
:       " Jump to command mode at bottom of screen
Esc     " Always goes back to Normal mode (your safe place!)
```

**Beginner's Safety Tip:** If you ever get confused about which mode you're in, just press `Esc` twice. This will always bring you back to Normal mode where you can safely navigate and orient yourself.

**Visual Mode Explained:** Visual mode is where you select text before doing something with it (like deleting, copying, or changing it). Think of it as highlighting text in a word processor, but keyboard-driven:
- Press `v` then move cursor to highlight individual characters
- Press `V` then move cursor to highlight whole lines
- Press `Ctrl+v` then move cursor to highlight rectangular blocks (great for editing columns)

**Command Mode Shortcut:** When you press `:`, you'll see a colon appear at the bottom left of the screen. This is where you type commands like:
- `:w` to save
- `:q` to quit
- `:wq` to save and quit
- `:q!` to quit without saving
- `:s/old/new/g` to replace text

---

## 📖 Making Sense of Vim Navigation

At first glance, Vim's navigation might seem strange - why use `hjkl` instead of the arrow keys? The answer is efficiency: keeping your fingers on the home row (where your fingers naturally rest) means you never have to reach for the arrow keys or mouse. Once you build muscle memory, `hjkl` becomes second nature.

Think of Vim navigation as having different "gears" for different situations:
- **Character-by-character** (`hjkl`) for fine adjustments
- **Word-level** (`w b e ge`) for moving through text semantically
- **Line-level** (`0 $ ^`) for jumping to specific parts of lines
- **Document-level** (`gg G`) for navigating large files quickly
- **Page-level** (`Ctrl+f/b Ctrl+d/u`) for scrolling through screens
- **Search-based** (`/ ? n N * #`) for jumping to specific content

### 🎯 Character Navigation (The Home Row)
```vim
h       " Move left  (think: h is left)
j       " Move down  (think: j looks like a down arrow)
k       " Move up    (think: k points up)
l       " Move right (think: l is right)
```

**Pro Tip:** If you're coming from traditional editors where you used arrow keys, try this exercise: open any text file in Vim and practice moving around using only `hjkl` for 5 minutes. It will feel awkward at first, but soon you'll appreciate not having to move your hand to the arrow keys.

### 📝 Word Navigation (Thinking in Words)
Instead of moving character by character, these commands let you jump from word to word:
```vim
w       " Forward to the start of the next word
b       " Back to the start of the previous word
e       " Forward to the end of the current word
ge      " Back to the end of the previous word
```

**Example:** With cursor at the beginning of "hello world":
- Press `w` → cursor jumps to "world"
- Press `b` → cursor jumps back to "hello"
- Press `e` → cursor jumps to the 'o' in "hello"
- Press `ge` → cursor jumps to the 'h' in "hello"

**When to use which:** 
- Use `w` and `b` when you want to edit at word boundaries
- Use `e` and `ge` when you want to manipulate the end of words

### 📏 Line Navigation (Jumping Within a Line)
These commands let you instantly jump to specific parts of the current line:
```vim
0       " Jump to the very beginning of the line (column 0)
$       " Jump to the very end of the line
^       " Jump to the first actual character (skips leading spaces)
```

**Example:** With cursor in the middle of "   indented text":
- Press `0` → cursor jumps to before the first space
- Press `^` → cursor jumps to the 'i' in "indented"
- Press `$` → cursor jumps to after the 't' in "text"

### 📚 Document Navigation (Moving Through Files)
For navigating larger chunks of your file:
```vim
gg      " Jump to the first line of the file
G       " Jump to the last line of the file
:number " Jump to a specific line number (e.g., :42 goes to line 42)
```

**Paging Commands** (like scrolling with a mouse, but keyboard-driven):
```vim
Ctrl+f  " Forward one full page (f = forward)
Ctrl+b  " Backward one full page  (b = back)
Ctrl+d  " Down half a page        (d = down)
Ctrl+u  " Up half a page          (u = up)
```

**Example:** In a 100-line file:
- Press `gg` → you're at line 1
- Press `G` → you're at line 100
- Press `50G` or `:50` → you're at line 50
- Press `Ctrl+f` → you scroll down roughly 30-40 lines (depends on your screen size)

### 🔍 Search-Based Navigation (Jumping to Content)
Instead of counting lines or words, search for what you're looking for:
```vim
/pattern    " Search forward for text (type pattern then Enter)
?pattern    " Search backward for text
n           " Repeat last search in same direction
N           " Repeat last search in opposite direction
*           " Search for the word under cursor (forward)
#           " Search for the word under cursor (backward)
```

**Real-World Example:** You're editing a bash script and want to find all instances of a variable named `count`:
1. Press `/` then type `count` and hit Enter → jumps to first `count`
2. Press `n` → jumps to next `count`
3. Press `N` → jumps to previous `count`
4. Or place cursor on any `count` and press `#` → jumps to previous `count`, then `n` to go forward

**Search Tips:**
- Searches are case-sensitive by default (`Count` ≠ `count`)
- To make searches case-insensitive, add `\c`: `/count\c`
- To force case-sensitive, add `\C`: `/count\C`
- Press `Esc` to cancel a search in progress
- Your last search stays active until you do another search

---

## ✏️ Basic Editing: Making Changes to Text

Now that you can navigate, let's learn how to actually change text. Vim's editing commands are incredibly powerful because they're combinable - you can often combine a motion (where to go) with an action (what to do there).

Think of it as verb-adverb pairs in English:
- Verb (what to do): `d` = delete, `c` = change, `y` = yank (copy)
- Adverb (where/how much): `w` = word, `$` = to end of line, `j` = down one line

So `dw` = delete word, `d$` = delete to end of line, `cw` = change word, `yw` = yank (copy) word.

### 📝 Inserting Text: Getting Into Insert Mode

To actually type and edit text, you need to be in Insert mode. These commands all put you in Insert mode at different locations:

```vim
i       " Insert text BEFORE the cursor (think: i = insert)
I       " Insert text at the BEGINNING of the line (think: I = insert at line start)
a       " Append text AFTER the cursor (think: a = append)
A       " Append text at the END of the line (think: A = append at line end)
o       " Open a NEW line BELOW the current line and insert there
O       " Open a NEW line ABOVE the current line and insert there
```

**Insert Mode Tips:**
- Once in Insert mode, you can type freely like in any normal text editor
- To leave Insert mode and return to Normal mode, always press `Esc`
- The bottom-left of the screen will show "-- INSERT --" when you're in Insert mode
- If you see "-- INSERT --" and start typing but nothing happens, you probably forgot to press `i` first!

**Common Beginner Mistake:** Forgetting you're in Insert mode and trying to navigate with `hjkl`. Remember: letters only insert text in Insert mode! Press `Esc` first to go back to Normal mode.

### ✂️ Deleting Text: The Power of Combinations

Vim's delete command is `d`, and it becomes incredibly powerful when combined with motions:

```vim
x           " Delete the character UNDER the cursor (think: x marks the spot)
X           " Delete the character BEFORE the cursor (like backspace)
dw          " Delete from cursor to the start of the NEXT word
de          " Delete from cursor to the end of the CURRENT word
db          " Delete from cursor to the start of the PREVIOUS word
dd          " Delete the ENTIRE line (think: d d = delete line)
d$          " Delete from cursor to the END of the line
d0          " Delete from cursor to the BEGINNING of the line
dgg         " Delete from cursor to the BEGINNING of the file
dG          " Delete from cursor to the END of the file
df.         " Delete from cursor to the NEXT period (f = find)
dt.         " Delete from cursor UP TO the NEXT period (t = 'til)
```

**The Magic of Combination:** You can combine `d` with almost any motion:
- `d` + `w` = delete word
- `d` + `3w` = delete 3 words
- `d` + `}` = delete to next paragraph
- `d` + `/{pattern}` = delete until you find pattern
- `d` + `5j` = delete 5 lines down

**Delete Examples:**
1. To delete a word: Move cursor to beginning of word, type `dw`
2. To delete a sentence: Move to beginning, type `d)` 
3. To delete a paragraph: Move to beginning, type `d}` 
4. To delete HTML tags: `dt>` (delete up to next >) or `df<` (delete up to next <)

### 📋 Copy (Yank) and Paste: The Register System

In Vim, copying is called "yanking" (y), and it works similarly to deleting:

```vim
yy          " Yank (copy) the ENTIRE line (y y = yank line)
y$          " Yank from cursor to END of line
y0          " Yank from cursor to BEGINNING of line
yw          " Yank from cursor to start of NEXT word
yib         " Yank text INSIDE brackets (() [] {} <>)
yab         " Yank text AROUND brackets (includes the brackets)
""p         " Paste from the unnamed register (default)
"0p         " Paste from the yank register (last yanked text)
"1p         " Paste from the delete register (last deleted text)
p           " Paste AFTER the cursor
P           " Paste BEFORE the cursor
```

**Vim's Register System (The Clipboard on Steroids):**
Unlike most editors that have just one clipboard, Vim has multiple registers:
- Unnamed register `"` - holds the last delete/yank (what `p` and `P` use by default)
- Numbered registers `0`-`9` - `0` holds last yank, `1-9` hold last deletes (9 is oldest)
- Named registers `a`-`z` and `A`-`Z` - for your own use (capital letters append)
- Special registers like `+` for system clipboard, `*` for primary selection

**Register Examples:**
- `"ayy` - Yank line into register `a`
- `"ap` - Paste contents of register `a`
- `"Ayy` - Append another line to register `a` (note capital A)
- `"+y` - Yank to system clipboard (so you can Ctrl+V in other apps)
- `"+p` - Paste from system clipboard

**Practical Copy/Paste Workflow:**
1. Move to start of what you want to copy
2. Type `yw` to yank a word, or `yy` to yank a line, or `y2j` to yank 2 lines
3. Move to where you want to paste it
4. Type `p` to paste after cursor, or `P` to paste before

**Pro Tip:** If you just deleted something with `dw` or `dd` and want to put it back, just press `p` - the last deleted text is automatically available!

### ↩️ Undo and Redo: Your Safety Net

Everyone makes mistakes - Vim's undo/redo system is robust and works across sessions:

```vim
u           " Undo the last change (can press multiple times)
Ctrl+r      " Redo something you undid (think: Ctrl+r = redo)
U           " Undo ALL changes made to the current line
```

**Undo Tips:**
- Press `u` repeatedly to undo multiple changes
- Press `Ctrl+r` repeatedly to redo multiple undone changes
- Vim keeps an extensive undo history - you can often go back dozens of changes
- The undo history persists even after saving the file (unless you set 'noundofile')
- To see your undo history: `:undolist` (advanced feature)

**Example Workflow:**
1. Type "Hello world" 
2. Change it to "Hello Vim" with `dw` + insert "Vim"
3. Change your mind and want "Hello world" back - press `u`
4. Actually you liked "Hello Vim" after all - press `Ctrl+r`
5. Change it to "Hello Universe" with `cw` + type "Universe"
6. Decide you want the original - press `u` twice to get back to "Hello world"

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
5dd         " Cut 5 lines
p           " Paste after current line
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

## 🎓 Final Project: Vim Configuration Manager

Now that you've mastered the essential Vim commands, let's see how a professional scripter might automate their editor setup. We'll examine the "Vim Manager" — a tool that installs a pre-configured `.vimrc` file, sets up common keybindings, and manages plugins automatically.

### What the Vim Configuration Manager Does:
1. **Installs a Modern `.vimrc`** with smart defaults (line numbers, tab sizes, etc.).
2. **Sets Up Leader Keys** to create custom, multi-key shortcuts.
3. **Automates Plugin Installation** using the `vim-plug` manager.
4. **Configures Better Navigation** for moving between split windows.
5. **Manages Keymaps** programmatically, allowing you to audit your shortcuts.
6. **Creates Directory Structures** needed for Vim's internal workings.

### Key Snippet: The ".vimrc" Generator
The manager uses a "Here Document" (`cat > "$VIMRC" << 'EOF'`) to create a complete configuration file in one step. This ensures your setup is identical every time you run it.

```bash
cmd_install() {
    log "Installing Vim configuration..."
    
    cat > "$HOME/.vimrc" << 'EOF'
" --- BASIC SETTINGS ---
syntax on           " Enable color coding
set number          " Show line numbers
set relativenumber  " Show line numbers relative to cursor
set tabstop=4       " 1 Tab = 4 Spaces
set shiftwidth=4    " Indent by 4 spaces
set expandtab       " Use spaces instead of tabs
set hlsearch        " Highlight search results

" --- CUSTOM KEYMAPS ---
let mapleader = " "  " Use Space as the leader key

" Save with Space+w
nnoremap <leader>w :w<CR>
" Quit with Space+q
nnoremap <leader>q :q<CR>
EOF
}
```

### Key Snippet: Automated Plugin Installation
Vim can be controlled from the command line using the `+` flag. Our manager uses this to install plugins without you ever having to open the editor.

```bash
cmd_plugin_install() {
    log "Installing plugins..."
    # +PlugInstall: Run the plugin install command
    # +qall: Quit all windows after finishing
    vim +PlugInstall +qall 2>/dev/null || true
}
```

**Pro Tip:** Your `.vimrc` is your secret weapon. Automating its setup means you're always productive, no matter what server you're working on!

---

## ✅ Stack 26 Complete!

Congratulations! You've successfully unlocked the world's most powerful text editor! You can now:
- ✅ **Navigate at light-speed** without ever touching your mouse
- ✅ **Master Vim Modes** (Normal, Insert, Visual, and Command)
- ✅ **Edit text efficiently** using combinations of actions and motions
- ✅ **Search and replace** patterns across your entire file
- ✅ **Customize your editor** with a personalized `.vimrc` file
- ✅ **Automate plugin management** for a truly professional experience

### What's Next?
In the next stack, we'll dive into **Systemd Deep Dive**. You'll learn how to turn your scripts into background services that start automatically when your computer boots!

**Next: Stack 27 - Systemd Deep Dive →**

---

*End of Stack 26*