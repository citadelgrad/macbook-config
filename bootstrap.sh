#!/bin/bash
# Purpose:
#	* bootstrap machine in order to prepare for ansible playbook run
#   * Updated for Apple Silicon (M1/M2/M3/M4) Macs - January 2025

set -e

# Change to the script's directory so relative paths work
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Detect architecture and set Homebrew prefix
if [[ $(uname -m) == "arm64" ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
else
    HOMEBREW_PREFIX="/usr/local"
fi

echo "Info   | Detected  | Architecture: $(uname -m)"
echo "Info   | Using     | Homebrew prefix: $HOMEBREW_PREFIX"

# Download and install Command Line Tools if no developer tools exist
#       * previous evaluation didn't work completely, due to gcc binary existing for vanilla os x install
#       * gcc output on vanilla osx box:
#       * 'xcode-select: note: no developer tools were found at '/Applications/Xcode.app', requesting install.
#       * Choose an option in the dialog to download the command line developer tools'
#
# Evaluate 2 conditions
#       * ensure dev tools are installed by checking the output of gcc
#       * check to see if gcc binary even exists ( original logic )
# if either of the conditions are met, install dev tools
if [[ $(/usr/bin/gcc 2>&1) =~ "no developer tools were found" ]] || [[ ! -x /usr/bin/gcc ]]; then
    echo "Info   | Install   | xcode"
    xcode-select --install
    echo "Info   | Waiting   | Press any key after Xcode tools installation completes..."
    read -n 1 -s
fi

# Download and install Homebrew
if [[ ! -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
    echo "Info   | Install   | homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session and configure shell
    echo "Info   | Configure | Adding Homebrew to PATH"
    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

    # Add to .zprofile for future sessions (Apple Silicon specific)
    if [[ $(uname -m) == "arm64" ]]; then
        if ! grep -q '/opt/homebrew/bin/brew shellenv' ~/.zprofile 2>/dev/null; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        fi
    fi
fi

# Ensure Homebrew is in PATH for this session
eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

# Download and install Ansible
if ! command -v ansible &> /dev/null; then
    echo "Info   | Install   | Ansible"
    brew update
    brew install ansible
fi

# Install Ansible collections
echo "Info   | Install   | Ansible collections"
ansible-galaxy collection install -r requirements.yml

# Run the playbook
echo "Info   | Running   | Ansible playbook"
ansible-playbook local.yml -K
