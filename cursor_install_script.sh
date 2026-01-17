#!/usr/bin/env bash
#
# Cursor AI Installer Script (Always Latest Version)
# Website: https://cursor.com
# Maintained: January 2026
#
set -e

# Colors and symbols
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly BOLD='\033[1m'
readonly RESET='\033[0m'
readonly CHECK="${GREEN}✔${RESET}"
readonly CROSS="${RED}✖${RESET}"
readonly ARROW="${BLUE}➤${RESET}"

# Helper functions
step() { echo -e "\n${BLUE}${BOLD}📦 $*${RESET}"; }
info() { echo -e "${ARROW} $*"; }
success() { echo -e "${CHECK} $*"; }
error() { echo -e "${CROSS} $*" >&2; }
warning() { echo -e "${YELLOW}⚠${RESET} $*"; }

# Configuration
readonly INSTALL_DIR="$HOME/.local/share/cursor"
readonly APPIMAGE_NAME="cursor-latest.AppImage"
readonly DESKTOP_FILE="$HOME/.local/share/applications/cursor-ai.desktop"
readonly APP_RUN_PATH="$INSTALL_DIR/squashfs-root/AppRun"
readonly ICON_PATH="$INSTALL_DIR/squashfs-root/co.anysphere.cursor.png"
readonly TMP_DIR="$(mktemp -d)"

# Download URLs (fallbacks in order of preference)
readonly DOWNLOAD_URLS=(
  "https://downloads.cursor.com/production/2ca326e0d1ce10956aea33d54c0e2d8c13c58a32/linux/x64/Cursor-2.3.41-x86_64.AppImage"
  "https://downloader.cursor.sh/linux/appImage/x64"
  "https://cursor.sh/linux/appImage/x64"
)

# Cleanup on exit
trap 'rm -rf "$TMP_DIR"' EXIT

# Check if running as root
if [ "$EUID" -eq 0 ]; then
  error "Please do not run this script as root or with sudo."
  info "This is a user-level installation."
  exit 1
fi

# Check dependencies
check_dependencies() {
  local missing=()
  local cmds=("file")
  
  # Check for either curl or wget
  if ! command -v curl &>/dev/null && ! command -v wget &>/dev/null; then
    missing+=("curl or wget")
  fi
  
  for cmd in "${cmds[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      missing+=("$cmd")
    fi
  done
  
  if [ ${#missing[@]} -gt 0 ]; then
    error "Missing required commands: ${missing[*]}"
    info "Install them with:"
    echo "  Ubuntu/Debian: sudo apt install curl wget file desktop-file-utils"
    echo "  Fedora/RHEL:   sudo dnf install curl wget file desktop-file-utils"
    echo "  Arch:          sudo pacman -S curl wget file desktop-file-utils"
    exit 1
  fi
}

# Test DNS resolution
test_dns() {
  info "Testing DNS resolution..."
  
  # Test common DNS servers
  if ! ping -c 1 8.8.8.8 &>/dev/null; then
    warning "No internet connectivity detected"
    return 1
  fi
  
  # Test DNS
  if ! nslookup cursor.com &>/dev/null && ! host cursor.com &>/dev/null; then
    warning "DNS resolution issues detected"
    info "Trying to add Google DNS temporarily..."
    
    echo -e "\n${YELLOW}Your DNS might not be working properly.${RESET}"
    echo "Suggestions:"
    echo "  1. Check your internet connection"
    echo "  2. Try using Google DNS: Add to /etc/resolv.conf:"
    echo "     nameserver 8.8.8.8"
    echo "     nameserver 8.8.4.4"
    echo "  3. Or use Cloudflare DNS:"
    echo "     nameserver 1.1.1.1"
    echo "     nameserver 1.0.0.1"
    echo ""
    return 1
  fi
  
  success "DNS resolution working"
  return 0
}

# Check if already installed
check_existing() {
  if [[ -f "$APP_RUN_PATH" ]]; then
    warning "Cursor AI is already installed."
    echo -n "Do you want to reinstall/update? [y/N] "
    read -r yn
    if [[ ! "$yn" =~ ^[Yy]$ ]]; then
      info "Installation cancelled."
      exit 0
    fi
    step "Removing previous installation"
    rm -rf "$INSTALL_DIR"
    success "Previous installation removed"
  fi
}

# Download with fallback URLs
download_appimage() {
  step "Downloading latest Cursor AI AppImage"
  
  local download_file="$TMP_DIR/$APPIMAGE_NAME"
  local download_success=false
  
  # Determine which downloader to use
  local downloader=""
  if command -v curl &>/dev/null; then
    downloader="curl"
  elif command -v wget &>/dev/null; then
    downloader="wget"
  fi
  
  # Try each URL until one works
  for url in "${DOWNLOAD_URLS[@]}"; do
    info "Trying: $url"
    
    if [ "$downloader" = "curl" ]; then
      if curl -L --fail --progress-bar \
           --max-time 600 \
           --connect-timeout 30 \
           --user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
           -o "$download_file" \
           "$url" 2>&1; then
        download_success=true
        break
      else
        warning "Failed to download from $url"
      fi
    else
      if wget --timeout=600 \
           --connect-timeout=30 \
           --user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
           -O "$download_file" \
           "$url" 2>&1; then
        download_success=true
        break
      else
        warning "Failed to download from $url"
      fi
    fi
  done
  
  if [ "$download_success" = false ]; then
    error "Failed to download Cursor AI from all available sources."
    error ""
    error "Possible solutions:"
    error "  1. Check your internet connection: ping 8.8.8.8"
    error "  2. Check DNS: nslookup cursor.com"
    error "  3. Try manual download:"
    error "     Visit https://cursor.com/download in your browser"
    error "     Download the Linux AppImage"
    error "     Then run: ./cursor_install_script.sh --from-file /path/to/cursor.AppImage"
    error ""
    exit 1
  fi
  
  success "Download completed"
  
  # Verify download
  if [ ! -f "$download_file" ]; then
    error "Downloaded file not found."
    exit 1
  fi
  
  local file_size=$(stat -c%s "$download_file" 2>/dev/null || stat -f%z "$download_file" 2>/dev/null)
  
  if [ "$file_size" -lt 10485760 ]; then  # Less than 10MB
    error "Downloaded file is too small ($file_size bytes) - likely corrupted."
    error "File type: $(file "$download_file")"
    if [ "$file_size" -lt 2048 ]; then
      warning "File content (might be an error page):"
      cat "$download_file"
    fi
    exit 1
  fi
  
  # Check file type
  local file_type=$(file -b "$download_file")
  if [[ ! "$file_type" =~ "ELF" ]] && [[ ! "$file_type" =~ "executable" ]]; then
    error "Downloaded file is not an executable AppImage."
    error "File type detected: $file_type"
    exit 1
  fi
  
  chmod +x "$download_file"
  success "AppImage verified ($(numfmt --to=iec-i --suffix=B $file_size 2>/dev/null || echo "$file_size bytes"))"
}

# Extract AppImage
extract_appimage() {
  step "Extracting AppImage"
  
  mkdir -p "$INSTALL_DIR"
  cd "$TMP_DIR" || exit 1
  
  info "This may take a minute..."
  
  # Check if libfuse2 is installed
  if ! ldconfig -p | grep -q "libfuse.so.2"; then
    warning "libfuse2 not detected - extraction might need alternative method"
    info "Extracting without FUSE..."
    
    # Extract without running (for systems without FUSE)
    if command -v unsquashfs &>/dev/null; then
      unsquashfs -d squashfs-root "$APPIMAGE_NAME" &>/dev/null || true
    fi
  fi
  
  # Try normal extraction
  if [ ! -d "squashfs-root" ]; then
    if ! ./"$APPIMAGE_NAME" --appimage-extract > /dev/null 2>&1; then
      error "Failed to extract AppImage"
      error ""
      error "Your system might be missing libfuse2. Install it with:"
      error "  Ubuntu 20.04-22.04: sudo apt install libfuse2"
      error "  Ubuntu 24.04+:      sudo apt install libfuse2t64"
      error "  Fedora/RHEL:        sudo dnf install fuse-libs"
      error "  Arch:               sudo pacman -S fuse2"
      error ""
      exit 1
    fi
  fi
  
  # Move extracted files to install directory
  if [ -d "squashfs-root" ]; then
    mv squashfs-root "$INSTALL_DIR/"
    success "AppImage extracted successfully"
  else
    error "Extraction failed - squashfs-root directory not found"
    exit 1
  fi
  
  # Verify extraction
  if [ ! -f "$APP_RUN_PATH" ]; then
    error "AppRun file not found after extraction"
    exit 1
  fi
  
  chmod +x "$APP_RUN_PATH"
}

# Create desktop entry
create_desktop_entry() {
  step "Creating application launcher"
  
  mkdir -p "$(dirname "$DESKTOP_FILE")"
  
  # Find icon
  local icon_file="$ICON_PATH"
  if [ ! -f "$icon_file" ]; then
    icon_file=$(find "$INSTALL_DIR/squashfs-root" -name "*.png" | head -n1)
    if [ -z "$icon_file" ]; then
      warning "Icon file not found, using default"
      icon_file="cursor"
    fi
  fi
  
  cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=Cursor AI
GenericName=AI Code Editor
Comment=AI-powered code editor built on VS Code
Exec=$APP_RUN_PATH %U
Icon=$icon_file
Terminal=false
Type=Application
Categories=Development;IDE;TextEditor;
StartupWMClass=Cursor
MimeType=text/plain;inode/directory;
Keywords=cursor;ai;code;editor;ide;development;
EOF
  
  chmod +x "$DESKTOP_FILE"
  
  # Update desktop database
  if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "$HOME/.local/share/applications" &>/dev/null 2>&1 || true
  fi
  
  success "Desktop launcher created"
}

# Setup terminal alias
setup_alias() {
  echo ""
  echo -n "Add terminal alias 'cursor' for easy launch? [y/N] "
  read -r add_alias
  
  if [[ "$add_alias" =~ ^[Yy]$ ]]; then
    local shell_rc=""
    
    if [ -n "$ZSH_VERSION" ] || [[ "$SHELL" =~ "zsh" ]]; then
      shell_rc="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ] || [[ "$SHELL" =~ "bash" ]]; then
      shell_rc="$HOME/.bashrc"
    else
      shell_rc="$HOME/.profile"
    fi
    
    if grep -q "alias cursor=" "$shell_rc" 2>/dev/null; then
      warning "Alias already exists in $shell_rc"
    else
      echo "" >> "$shell_rc"
      echo "# Cursor AI IDE alias" >> "$shell_rc"
      echo "alias cursor='$APP_RUN_PATH'" >> "$shell_rc"
      success "Alias added to $shell_rc"
      info "Reload with: source $shell_rc"
    fi
  fi
}

# Print success message
print_success() {
  echo ""
  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${GREEN}${BOLD}🎉 Cursor AI installed successfully!${RESET}"
  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo ""
  echo -e "${ARROW} ${BOLD}How to launch:${RESET}"
  echo "  • From applications menu (search 'Cursor AI')"
  echo "  • Run: $APP_RUN_PATH"
  [[ "$add_alias" =~ ^[Yy]$ ]] && echo "  • Type: cursor (after reloading shell)"
  echo ""
  echo -e "${ARROW} ${BOLD}Installation location:${RESET}"
  echo "  $INSTALL_DIR"
  echo ""
  echo -e "${ARROW} ${BOLD}To uninstall:${RESET}"
  echo "  Run: ./uninstall.sh"
  echo ""
}

# Main installation flow
main() {
  echo -e "${BLUE}${BOLD}"
  echo "╔═══════════════════════════════════════════╗"
  echo "║   Cursor AI Installer for Linux          ║"
  echo "║   Latest Version - January 2026           ║"
  echo "╚═══════════════════════════════════════════╝"
  echo -e "${RESET}"
  
  check_dependencies
  test_dns || true  # Continue even if DNS test fails
  check_existing
  download_appimage
  extract_appimage
  create_desktop_entry
  setup_alias
  print_success
}

# Run main function
main "$@"