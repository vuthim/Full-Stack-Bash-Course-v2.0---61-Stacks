# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-03-19 - Expert Edition

### Added
- **Stack 3B**: Quoting, Expansion & Safe File Handling
  - Single quotes vs double quotes
  - Shell expansion (brace, tilde, parameter, command, arithmetic)
  - `"$@"` vs `"$*"`
  - Word splitting dangers
  - Shell options (shopt)
  - mapfile/readarray
  - IFS usage

- **Stack 12B**: Bash Portability & POSIX
  - POSIX vs Bash feature comparison
  - Shebang decisions
  - Writing portable scripts
  - Testing for POSIX compliance
  - Cross-platform library patterns

- **Expanded Stack 12**: Comprehensive error handling
  - `set -euo pipefail` with caveats
  - Professional `trap` usage (ERR, EXIT, INT, RETURN)
  - Complete `getopts` parsing

### Changed
- **Stack 21**: Renamed from "Web Scraping" to "Advanced curl & Data Extraction"
- Electives clearly labeled with [ELECTIVE] tag
- Updated COURSE_OUTLINE.md to 61 stacks
- Enhanced start_course.sh with new lessons

### Electives Labeled
- Stack 25: Zsh Essentials [ELECTIVE]
- Stack 26: Vim for Scripters [ELECTIVE]
- Stack 42: Raspberry Pi Projects [ELECTIVE]
- Stack 43: Windows WSL [ELECTIVE]
- Stack 59: Multi-Cluster Orchestration [ELECTIVE]

---

## [1.0.0] - 2024-03-16 - Initial Release

### Added
- 59 comprehensive lessons covering:
  - Bash Fundamentals (Stacks 1-10)
  - Core Skills (Stacks 11-20)
  - Automation (Stacks 21-30)
  - DevOps (Stacks 31-40)
  - Expert (Stacks 41-50)
  - Master (Stacks 51-59)

- 59 solution files
- Interactive course launcher (`start_course.sh`)
- Sample data files
- Practice exercises
- Progress tracking system

### Features
- Beginner to Expert learning path
- DevOps and Cloud automation
- Production-ready scripts
- Real-world examples
