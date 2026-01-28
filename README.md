# macOS Configuration

Ansible playbook for automated macOS setup on Apple Silicon Macs. Sets up a complete development environment with modern CLI tools, applications, and shell configuration.

## Quick Start

```bash
# Clone the repo
git clone git@github.com:citadelgrad/macOS-config.git
cd macOS-config

# Run bootstrap (installs Xcode CLI tools, Homebrew, Ansible, then runs playbook)
./bootstrap.sh
```

The bootstrap script will prompt for your password (required for some installations).

## What Gets Installed

### Applications (Homebrew Casks)

| Category | Apps |
|----------|------|
| **Browsers** | Firefox, Brave, Arc |
| **Productivity** | Slack, LibreOffice, Rectangle, Raycast, Itsycal, Maccy, Alt-Tab, Stats, The Unarchiver, AppCleaner |
| **Media** | SoundSource, VLC |
| **Developer** | iTerm2, VS Code, Cursor, Postman, GitHub Desktop, OrbStack |

### CLI Tools (Homebrew Formulae)

#### Modern Replacements

| Tool | Replaces | Description |
|------|----------|-------------|
| `bat` | `cat` | Syntax highlighting, line numbers |
| `lsd` | `ls` | Icons, git status, tree view |
| `eza` | `ls` | Modern ls (alternative to lsd) |
| `fd` | `find` | Faster, respects .gitignore |
| `ripgrep` (`rg`) | `grep` | Faster, smarter defaults |
| `fzf` | - | Fuzzy finder for everything |
| `zoxide` | `cd` | Smarter directory jumping |
| `tldr` | `man` | Simplified, practical examples |
| `uutils-coreutils` | GNU coreutils | Rust-based, efficient `tail -f` using kqueue |

#### Git Tools
- `git`, `gh` (GitHub CLI), `git-delta` (better diffs), `git-lfs`, `git-secrets`

#### Other CLI
- `jq`/`yq` (JSON/YAML processing)
- `tmux` (terminal multiplexer)
- `direnv` (per-directory environment)
- `tree` (directory visualization)
- `httpie` (user-friendly HTTP client)

### Cloud & DevOps
- AWS: `awscli`, `aws-cdk`, `aws-sam-cli`
- Kubernetes: `kubectl`, `helm`
- Infrastructure: `terraform`

### Development Languages

#### Python (via pyenv)
- `pyenv` and `pyenv-virtualenv` for version management
- Build dependencies: openssl, readline, sqlite3, xz, zlib
- Image libraries: libtiff, libjpeg, webp, little-cms2

#### Node.js (via fnm)
- `fnm` (Fast Node Manager) for version management
- `yarn` package manager

### Shell Configuration

#### Zsh (default macOS shell)
- Oh-My-Zsh with plugins: git, django, python, pip, celery, postgres, brew, macos
- Zsh plugins via Homebrew: autosuggestions, syntax-highlighting

#### Configured Aliases

```bash
# Modern CLI (auto-configured if tools exist)
ls    → lsd
ll    → lsd -la
cat   → bat --paging=never
tail  → uu-tail    # Rust-based, uses kqueue
head  → uu-head
# Note: fd is installed but not aliased (syntax differs from find)

# Django
sh+        → ./manage.py shell_plus
runserver  → ./manage.py runserver_plus

# Git (supplements oh-my-zsh)
gst, gco, gcm, gp, gl
```

#### Tool Integrations
- `direnv` - auto-load .envrc files
- `fnm` - auto-switch Node versions on cd
- `pyenv` - Python version management
- `zoxide` - smart cd with `z` command
- `fzf` - fuzzy completion (Ctrl+R for history)

## Project Structure

```
macOS-config/
├── bootstrap.sh          # Initial setup script
├── local.yml             # Main playbook
├── hosts                 # Inventory (localhost)
├── requirements.yml      # Ansible Galaxy dependencies
└── roles/
    ├── common/           # Apps and CLI tools
    │   └── tasks/main.yml
    ├── homebrew/         # Homebrew updates
    │   └── tasks/main.yml
    ├── python/           # pyenv and pip config
    │   ├── tasks/main.yml
    │   └── files/pip.conf
    └── zsh/              # Shell configuration
        ├── tasks/main.yml
        └── files/zshrc
```

## Running Individual Roles

Use tags to run specific parts:

```bash
# Just browsers
ansible-playbook local.yml -K --tags browsers

# Just CLI tools
ansible-playbook local.yml -K --tags cli-tools

# Just cloud/DevOps tools
ansible-playbook local.yml -K --tags cloud

# Just zsh configuration
ansible-playbook local.yml -K --tags zsh
```

## Customization

### Adding Applications

Edit `roles/common/tasks/main.yml`:

```yaml
# For GUI apps (casks)
- name: Install my apps
  community.general.homebrew_cask:
    name:
      - my-app
    state: present

# For CLI tools (formulae)
- name: Install my tools
  community.general.homebrew:
    name:
      - my-tool
    state: present
```

### Modifying Shell Config

Edit `roles/zsh/files/zshrc` - this file replaces `~/.zshrc` on each run.

## Requirements

- macOS 13.0 (Ventura) or newer
- Apple Silicon (M1/M2/M3/M4) or Intel Mac
- Internet connection

## Notes

### uutils-coreutils

The playbook installs `uutils-coreutils`, a Rust rewrite of GNU coreutils. The zshrc uses aliases (`tail → uu-tail`) instead of PATH modification to avoid breaking pyenv's `readlink` dependency.

### Why Both lsd and eza?

Both are modern `ls` replacements. The config defaults to `lsd` (better git integration and icons) but includes `eza` as an alternative. Edit the zshrc aliases to switch.

## Troubleshooting

**pyenv errors with "readlink: Invalid argument"**

This happens if uutils `readlink` shadows the system one. The zshrc uses aliases instead of PATH to prevent this.

**Ansible "module not found" errors**

Run: `ansible-galaxy collection install -r requirements.yml`

**Permission denied during bootstrap**

The `-K` flag prompts for sudo password. Some casks require admin rights.
