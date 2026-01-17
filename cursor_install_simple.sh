#!/usr/bin/env bash
#
# Cursor AI Simple Installer
# Direct download from cursor.com - No DNS issues!
#

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

# Configuration
INSTALL_DIR="$HOME/.local/share/cursor"
DESKTOP_FILE="$HOME/.local/share/applications/cursor-ai.desktop"

# Direct download URL (works even with DNS issues)
DOWNLOAD_URL="https://downloads.cursor.com/production/2ca326e0d1ce10956aea33d54c0e2d8c13c58a32/linux/x64/Cursor-2.3.41-x86_64.AppImage"

echo -e "${BLUE}${BOLD}"
echo "╔═══════════════════════════════════════════╗"
echo "║   Cursor AI Simple Installer             ║"
echo "║   Direct Download - No DNS Issues         ║"
echo "╚═══════════════════════════════════════════╝"
echo -e "${RESET}\n"

# Check if already installed
if [ -d "$INSTALL_DIR/squashfs-root" ]; then
    echo -e "${YELLOW}⚠${RESET} Cursor is already installed."
    echo -n "Reinstall? [y/N] "
    read -r yn
    if [[ ! "$yn" =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi
    rm -rf "$INSTALL_DIR"
fi

# Create temp directory
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

echo -e "${BLUE}→${RESET} Downloading Cursor AI..."
echo "  URL: $DOWNLOAD_URL"

cd "$TMP_DIR"

# Download
if command -v curl &>/dev/null; then
    curl -L --progress-bar -o cursor.AppImage "$DOWNLOAD_URL"
elif command -v wget &>/dev/null; then
    wget --show-progress -O cursor.AppImage "$DOWNLOAD_URL"
else
    echo -e "${RED}✖${RESET} Neither curl nor wget found!"
    echo "Install with: sudo apt install curl"
    exit 1
fi

# Verify download
if [ ! -f cursor.AppImage ] || [ $(stat -c%s cursor.AppImage) -lt 10485760 ]; then
    echo -e "${RED}✖${RESET} Download failed or file is too small"
    exit 1
fi

echo -e "${GREEN}✔${RESET} Download completed"

# Make executable
chmod +x cursor.AppImage

# Extract
echo -e "${BLUE}→${RESET} Extracting AppImage..."
if ! ./cursor.AppImage --appimage-extract > /dev/null 2>&1; then
    echo -e "${RED}✖${RESET} Extraction failed"
    echo -e "${YELLOW}Note:${RESET} You might need libfuse2:"
    echo "  sudo apt install libfuse2"
    exit 1
fi

echo -e "${GREEN}✔${RESET} Extraction completed"

# Install
echo -e "${BLUE}→${RESET} Installing to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
mv squashfs-root "$INSTALL_DIR/"

# Create desktop entry
echo -e "${BLUE}→${RESET} Creating launcher..."
mkdir -p "$(dirname "$DESKTOP_FILE")"

# Find icon
ICON=$(find "$INSTALL_DIR/squashfs-root" -name "*.png" | head -n1)
[ -z "$ICON" ] && ICON="cursor"

cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=Cursor AI
Comment=AI-powered code editor
Exec=$INSTALL_DIR/squashfs-root/AppRun %U
Icon=$ICON
Terminal=false
Type=Application
Categories=Development;IDE;TextEditor;
StartupWMClass=Cursor
EOF

chmod +x "$DESKTOP_FILE"
update-desktop-database "$HOME/.local/share/applications" &>/dev/null || true

echo -e "${GREEN}✔${RESET} Desktop launcher created"

# Offer alias
echo ""
echo -n "Add terminal alias 'cursor'? [y/N] "
read -r add_alias

if [[ "$add_alias" =~ ^[Yy]$ ]]; then
    SHELL_RC="$HOME/.bashrc"
    [[ $SHELL =~ "zsh" ]] && SHELL_RC="$HOME/.zshrc"
    
    if ! grep -q "alias cursor=" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# Cursor AI" >> "$SHELL_RC"
        echo "alias cursor='$INSTALL_DIR/squashfs-root/AppRun'" >> "$SHELL_RC"
        echo -e "${GREEN}✔${RESET} Alias added to $SHELL_RC"
        echo -e "${BLUE}→${RESET} Reload with: source $SHELL_RC"
    fi
fi

# Success
echo ""
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}🎉 Cursor AI installed successfully!${RESET}"
echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo "Launch from:"
echo "  • Applications menu (search 'Cursor AI')"
echo "  • Terminal: $INSTALL_DIR/squashfs-root/AppRun"
[[ "$add_alias" =~ ^[Yy]$ ]] && echo "  • Terminal: cursor (after reload)"
echo ""