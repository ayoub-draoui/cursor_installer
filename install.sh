#!/usr/bin/env bash

# Cursor AI Installer Script (Updated to Latest Version v1.1.3)
# Website: https://cursor.so
# Installer Maintainer: Updated by ChatGPT

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'
CHECK="${GREEN}✔${RESET}"
CROSS="${RED}✖${RESET}"

# Spinner
spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  tput civis
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r  ${BLUE}↻ ${spinstr:RANDOM%${#spinstr}:1} $SPINNER_MSG...${RESET}"
    sleep "$delay"
  done
  tput cnorm
  printf "\r  ${GREEN}✔ $SPINNER_MSG completed.${RESET}\n"
}

# Helpers
step() { echo -e "\n${BLUE}${BOLD}📦 $*${RESET}"; }
info() { echo -e "${BLUE}${BOLD}➤ $*${RESET}"; }
success() { echo -e "$CHECK $*"; }
error() { echo -e "$CROSS $*" >&2; }

# Variables
INSTALL_DIR="$HOME/.local/share/cursor"
APPIMAGE_NAME="Cursor-1.1.3-x86_64.AppImage"
APPIMAGE_URL="https://downloads.cursor.com/production/979ba33804ac150108481c14e0b5cb970bda3266/linux/x64/$APPIMAGE_NAME"
DESKTOP_FILE="$HOME/.local/share/applications/cursor-ai.desktop"
APP_RUN_PATH="$INSTALL_DIR/squashfs-root/AppRun"
ICON_PATH="$INSTALL_DIR/squashfs-root/co.anysphere.cursor.png"

# Check Dependencies
REQUIRED=("curl" "update-desktop-database")
for cmd in "${REQUIRED[@]}"; do
  if ! command -v "$cmd" &>/dev/null; then
    error "Required command '$cmd' not found. Install it and retry."
    exit 1
  fi
done

# Already Installed?
if [[ -f "$APP_RUN_PATH" ]]; then
  info "Cursor AI already installed."
  echo -n "Reinstall/update? [y/N] "
  read -r yn
  if [[ ! "$yn" =~ ^[Yy]$ ]]; then
    info "Okay, exiting."
    exit 0
  fi
  rm -rf "$INSTALL_DIR"
fi

# Install
step "Installing Cursor AI IDE (v1.1.3)"

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR" || exit 1

step "Downloading AppImage v1.1.3"
SPINNER_MSG="Downloading Cursor"
curl -sSL "$APPIMAGE_URL" -o "$APPIMAGE_NAME" & spinner $!

chmod +x "$APPIMAGE_NAME"

step "Extracting AppImage"
SPINNER_MSG="Extracting AppImage"
./"$APPIMAGE_NAME" --appimage-extract > /dev/null 2>&1 & spinner $!
wait

rm -f "$APPIMAGE_NAME"
success "AppImage extracted and temporary file removed."

# Desktop Entry
step "Creating desktop launcher"
mkdir -p "$(dirname "$DESKTOP_FILE")"
cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=Cursor AI IDE
Comment=AI-powered code editor
Exec=$APP_RUN_PATH
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Development;IDE;
EOF

chmod +x "$DESKTOP_FILE"
update-desktop-database "$HOME/.local/share/applications" &>/dev/null

# Alias Option
echo -n "Add terminal alias 'cursor'? [y/N] "
read -r addalias
if [[ "$addalias" =~ ^[Yy]$ ]]; then
  SHELLRC="$HOME/.bashrc"
  [[ $SHELL =~ "zsh" ]] && SHELLRC="$HOME/.zshrc"
  echo "alias cursor=\"$APP_RUN_PATH\"" >> "$SHELLRC"
  success "Alias added to $SHELLRC"
  info "Reload with: source $SHELLRC"
fi

echo -e "\n${GREEN}${BOLD}🎉 Cursor AI v1.1.3 installed!${RESET}"
echo "• Open from applications menu"
echo "• Run: $APP_RUN_PATH"
[[ "$addalias" =~ ^[Yy]$ ]] && echo "• Or type: cursor"
exit 0
