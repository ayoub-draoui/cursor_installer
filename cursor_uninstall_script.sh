#!/usr/bin/env bash
#
# Cursor AI Complete Uninstaller Script
# Removes ALL traces of Cursor AI from your system
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
readonly WARNING="${YELLOW}⚠${RESET}"

# Configuration - All possible Cursor locations
readonly INSTALL_DIR="$HOME/.local/share/cursor"
readonly DESKTOP_FILE="$HOME/.local/share/applications/cursor-ai.desktop"
readonly CONFIG_DIR="$HOME/.config/cursor"
readonly CONFIG_DIR_ALT="$HOME/.config/Cursor"
readonly CACHE_DIR="$HOME/.cache/cursor"
readonly CACHE_DIR_ALT="$HOME/.cache/Cursor"
readonly LOCAL_STATE="$HOME/.local/state/cursor"
readonly VSCODE_STORAGE="$HOME/.vscode/extensions"
readonly CODE_USER_DIR="$HOME/.cursor"

# Additional storage locations
readonly XDG_DATA="$HOME/.local/share/Cursor"
readonly XDG_CONFIG="$HOME/.config/Cursor User Data"
readonly GNOME_KEYRING="cursor"  # Keyring entries
readonly KDE_WALLET="cursor"     # KDE Wallet entries

# Global tracking
TOTAL_SIZE=0
ITEMS_REMOVED=0
BACKUP_DIR="$HOME/cursor-backup-$(date +%Y%m%d-%H%M%S)"

# Helper functions
info() { echo -e "${ARROW} $*"; }
success() { echo -e "${CHECK} $*"; }
warning() { echo -e "${WARNING} $*"; }
error() { echo -e "${CROSS} $*" >&2; }
section() { echo -e "\n${BLUE}${BOLD}▶ $*${RESET}"; }

# Calculate directory size
get_dir_size() {
  local dir=$1
  if [ -d "$dir" ]; then
    du -sb "$dir" 2>/dev/null | cut -f1
  else
    echo 0
  fi
}

# Format bytes to human readable
format_size() {
  local bytes=$1
  if [ "$bytes" -lt 1024 ]; then
    echo "${bytes}B"
  elif [ "$bytes" -lt 1048576 ]; then
    echo "$(( bytes / 1024 ))KB"
  elif [ "$bytes" -lt 1073741824 ]; then
    echo "$(( bytes / 1048576 ))MB"
  else
    echo "$(( bytes / 1073741824 ))GB"
  fi
}

# Print header
print_header() {
  echo -e "${RED}${BOLD}"
  echo "╔═══════════════════════════════════════════╗"
  echo "║   Cursor AI Complete Uninstaller          ║"
  echo "║   Removes Everything - No Traces Left     ║"
  echo "╚═══════════════════════════════════════════╝"
  echo -e "${RESET}"
}

# Scan for all Cursor files
scan_cursor_files() {
  section "Scanning for Cursor AI files..."
  
  local locations=(
    "$INSTALL_DIR"
    "$DESKTOP_FILE"
    "$CONFIG_DIR"
    "$CONFIG_DIR_ALT"
    "$CACHE_DIR"
    "$CACHE_DIR_ALT"
    "$LOCAL_STATE"
    "$CODE_USER_DIR"
    "$XDG_DATA"
    "$XDG_CONFIG"
  )
  
  echo ""
  echo "Found the following Cursor-related items:"
  echo ""
  
  local found_items=0
  
  for location in "${locations[@]}"; do
    if [ -e "$location" ]; then
      local size=$(get_dir_size "$location")
      TOTAL_SIZE=$((TOTAL_SIZE + size))
      found_items=$((found_items + 1))
      
      if [ -d "$location" ]; then
        local count=$(find "$location" -type f 2>/dev/null | wc -l)
        printf "  ${YELLOW}📁${RESET} %-50s %8s (%s files)\n" \
          "$location" "$(format_size $size)" "$count"
      else
        printf "  ${YELLOW}📄${RESET} %-50s %8s\n" \
          "$location" "$(format_size $size)"
      fi
    fi
  done
  
  # Search for additional Cursor files in common locations
  info "Searching for additional Cursor files..."
  local extra_files=$(find "$HOME" -maxdepth 4 \( \
    -iname "*cursor*.AppImage" -o \
    -iname "*cursor*.deb" -o \
    -iname "*cursor*.rpm" -o \
    -iname ".cursor*" -o \
    -path "*/cursor/*" \
  \) -type f 2>/dev/null | grep -v ".backup-" | grep -v "cursor_installer" || true)
  
  if [ -n "$extra_files" ]; then
    echo ""
    warning "Additional files found:"
    echo "$extra_files" | while read -r file; do
      local size=$(du -sb "$file" 2>/dev/null | cut -f1)
      TOTAL_SIZE=$((TOTAL_SIZE + size))
      printf "  ${YELLOW}📄${RESET} %-50s %8s\n" "$file" "$(format_size $size)"
      found_items=$((found_items + 1))
    done
  fi
  
  echo ""
  if [ $found_items -eq 0 ]; then
    success "No Cursor files found - system is clean!"
    exit 0
  else
    info "Total items found: ${BOLD}$found_items${RESET}"
    info "Total size: ${BOLD}$(format_size $TOTAL_SIZE)${RESET}"
  fi
}

# Confirm uninstallation with detailed options
confirm_uninstall() {
  echo ""
  echo -e "${RED}${BOLD}⚠️  WARNING: Complete Removal${RESET}"
  echo ""
  echo "This will remove ALL traces of Cursor AI including:"
  echo "  • Application files and binaries"
  echo "  • All extensions and plugins"
  echo "  • Configuration and settings"
  echo "  • Cache and temporary files"
  echo "  • Authentication tokens and credentials"
  echo "  • User data and workspaces"
  echo "  • Desktop launchers and shell aliases"
  echo "  • System keyring/wallet entries"
  echo ""
  
  # Option to create backup
  echo -n "Create backup before removal? [Y/n] "
  read -r create_backup
  echo ""
  
  if [[ ! "$create_backup" =~ ^[Nn]$ ]]; then
    BACKUP_ENABLED=true
    info "Backup will be created at: $BACKUP_DIR"
    echo ""
  else
    BACKUP_ENABLED=false
  fi
  
  echo -n "${RED}${BOLD}Proceed with complete removal? [y/N] ${RESET}"
  read -r confirm
  
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    info "Uninstallation cancelled."
    exit 0
  fi
  
  echo ""
}

# Create backup if requested
create_backup() {
  if [ "$BACKUP_ENABLED" = true ]; then
    section "Creating backup..."
    
    mkdir -p "$BACKUP_DIR"
    
    local backed_up=0
    for dir in "$CONFIG_DIR" "$CONFIG_DIR_ALT" "$CODE_USER_DIR"; do
      if [ -d "$dir" ]; then
        local basename=$(basename "$dir")
        cp -r "$dir" "$BACKUP_DIR/$basename" 2>/dev/null || true
        if [ -d "$BACKUP_DIR/$basename" ]; then
          success "Backed up: $basename"
          backed_up=$((backed_up + 1))
        fi
      fi
    done
    
    if [ $backed_up -gt 0 ]; then
      success "Backup created at: $BACKUP_DIR"
    else
      warning "No configuration to backup"
      rmdir "$BACKUP_DIR" 2>/dev/null || true
    fi
    
    echo ""
  fi
}

# Remove application directory
remove_app_directory() {
  section "Removing application files..."
  
  local dirs=(
    "$INSTALL_DIR"
    "$XDG_DATA"
  )
  
  for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
      local size=$(get_dir_size "$dir")
      rm -rf "$dir"
      success "Removed: $dir ($(format_size $size))"
      ITEMS_REMOVED=$((ITEMS_REMOVED + 1))
    fi
  done
}

# Remove configuration files
remove_configuration() {
  section "Removing configuration files..."
  
  local dirs=(
    "$CONFIG_DIR"
    "$CONFIG_DIR_ALT"
    "$CODE_USER_DIR"
    "$XDG_CONFIG"
    "$LOCAL_STATE"
  )
  
  for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
      local size=$(get_dir_size "$dir")
      rm -rf "$dir"
      success "Removed: $dir ($(format_size $size))"
      ITEMS_REMOVED=$((ITEMS_REMOVED + 1))
    fi
  done
}

# Remove cache and temporary files
remove_cache() {
  section "Removing cache and temporary files..."
  
  local dirs=(
    "$CACHE_DIR"
    "$CACHE_DIR_ALT"
    "/tmp/cursor-*"
    "$HOME/.tmp/cursor"
  )
  
  for pattern in "${dirs[@]}"; do
    for dir in $pattern; do
      if [ -e "$dir" ]; then
        local size=$(get_dir_size "$dir")
        rm -rf "$dir"
        success "Removed: $dir ($(format_size $size))"
        ITEMS_REMOVED=$((ITEMS_REMOVED + 1))
      fi
    done
  done
  
  # Clean XDG runtime directory
  if [ -n "$XDG_RUNTIME_DIR" ] && [ -d "$XDG_RUNTIME_DIR" ]; then
    find "$XDG_RUNTIME_DIR" -iname "*cursor*" -exec rm -rf {} + 2>/dev/null || true
  fi
}

# Remove extensions
remove_extensions() {
  section "Removing extensions..."
  
  local ext_dirs=(
    "$HOME/.cursor/extensions"
    "$HOME/.vscode-cursor/extensions"
    "$CONFIG_DIR/extensions"
    "$CONFIG_DIR_ALT/extensions"
  )
  
  local removed=0
  for ext_dir in "${ext_dirs[@]}"; do
    if [ -d "$ext_dir" ]; then
      local count=$(find "$ext_dir" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)
      local size=$(get_dir_size "$ext_dir")
      rm -rf "$ext_dir"
      success "Removed $count extensions from: $ext_dir ($(format_size $size))"
      removed=$((removed + 1))
      ITEMS_REMOVED=$((ITEMS_REMOVED + 1))
    fi
  done
  
  if [ $removed -eq 0 ]; then
    info "No extensions found"
  fi
}

# Remove authentication and credentials
remove_credentials() {
  section "Removing authentication tokens and credentials..."
  
  # Remove stored tokens and auth files
  local auth_patterns=(
    "$CONFIG_DIR*/User/globalStorage/cursor.auth"
    "$CONFIG_DIR*/Cookies"
    "$CONFIG_DIR*/Cookies-journal"
    "$CONFIG_DIR*/Local Storage"
    "$CONFIG_DIR*/Session Storage"
    "$HOME/.cursor-token"
    "$HOME/.cursor/credentials"
  )
  
  local removed=0
  for pattern in "${auth_patterns[@]}"; do
    for file in $pattern; do
      if [ -e "$file" ]; then
        rm -rf "$file"
        success "Removed: $(basename "$file")"
        removed=$((removed + 1))
      fi
    done
  done
  
  # Try to remove from GNOME Keyring (if available)
  if command -v secret-tool &>/dev/null; then
    info "Checking GNOME Keyring..."
    secret-tool search application cursor 2>/dev/null | \
      grep -o 'attribute.label = .*' | \
      cut -d'"' -f2 | \
      while read -r label; do
        secret-tool clear label "$label" 2>/dev/null && \
          success "Removed keyring entry: $label" || true
      done
  fi
  
  # Try to remove from KDE Wallet (if available)
  if command -v kwalletcli &>/dev/null; then
    info "Checking KDE Wallet..."
    kwalletcli -f cursor 2>/dev/null | \
      while read -r entry; do
        kwalletcli -f cursor -e "$entry" 2>/dev/null && \
          success "Removed wallet entry: $entry" || true
      done
  fi
  
  if [ $removed -gt 0 ]; then
    success "Removed $removed credential files"
  else
    info "No credential files found"
  fi
}

# Remove desktop entry
remove_desktop_entry() {
  section "Removing desktop launchers..."
  
  local desktop_files=(
    "$DESKTOP_FILE"
    "$HOME/.local/share/applications/cursor.desktop"
    "$HOME/.local/share/applications/Cursor.desktop"
    "/usr/share/applications/cursor*.desktop"
  )
  
  local removed=0
  for pattern in "${desktop_files[@]}"; do
    for file in $pattern; do
      if [ -f "$file" ]; then
        rm -f "$file"
        success "Removed: $(basename "$file")"
        removed=$((removed + 1))
        ITEMS_REMOVED=$((ITEMS_REMOVED + 1))
      fi
    done
  done
  
  # Update desktop database
  if command -v update-desktop-database &>/dev/null; then
    update-desktop-database "$HOME/.local/share/applications" &>/dev/null 2>&1 || true
    update-desktop-database /usr/share/applications &>/dev/null 2>&1 || true
  fi
  
  # Clear icon cache
  if command -v gtk-update-icon-cache &>/dev/null; then
    gtk-update-icon-cache -f -t ~/.local/share/icons &>/dev/null 2>&1 || true
  fi
  
  if [ $removed -eq 0 ]; then
    info "No desktop files found"
  fi
}

# Remove shell aliases and PATH entries
remove_shell_config() {
  section "Removing shell configuration..."
  
  local shell_configs=(
    "$HOME/.bashrc"
    "$HOME/.bash_profile"
    "$HOME/.zshrc"
    "$HOME/.zprofile"
    "$HOME/.profile"
    "$HOME/.config/fish/config.fish"
  )
  
  local timestamp=$(date +%Y%m%d-%H%M%S)
  local removed=0
  
  for rc in "${shell_configs[@]}"; do
    if [ -f "$rc" ]; then
      # Create backup
      cp "$rc" "$rc.backup-$timestamp"
      
      # Remove cursor-related lines
      local original_lines=$(wc -l < "$rc")
      sed -i.tmp \
        -e '/# Cursor AI/d' \
        -e '/cursor/Id' \
        -e '/CURSOR_/d' \
        -e '/\.cursor/d' \
        "$rc"
      
      local new_lines=$(wc -l < "$rc")
      local diff=$((original_lines - new_lines))
      
      rm -f "$rc.tmp"
      
      if [ $diff -gt 0 ]; then
        success "Cleaned $(basename "$rc") ($diff lines removed)"
        removed=$((removed + 1))
      fi
    fi
  done
  
  if [ $removed -gt 0 ]; then
    info "Shell config backups saved with .backup-$timestamp extension"
  else
    info "No shell configuration found"
  fi
}

# Remove system-wide integrations
remove_system_integrations() {
  section "Removing system integrations..."
  
  # Remove MIME type associations
  local mime_file="$HOME/.local/share/applications/mimeapps.list"
  if [ -f "$mime_file" ]; then
    if grep -q "cursor" "$mime_file" 2>/dev/null; then
      sed -i.bak '/cursor/d' "$mime_file"
      success "Removed MIME type associations"
    fi
  fi
  
  # Remove from recent files
  local recent_file="$HOME/.local/share/recently-used.xbel"
  if [ -f "$recent_file" ]; then
    if grep -q "cursor" "$recent_file" 2>/dev/null; then
      sed -i.bak '/cursor/Id' "$recent_file"
      success "Cleaned recent files list"
    fi
  fi
  
  # Clear systemd user units if any
  local systemd_dir="$HOME/.config/systemd/user"
  if [ -d "$systemd_dir" ]; then
    find "$systemd_dir" -iname "*cursor*" -delete 2>/dev/null || true
  fi
}

# Remove additional files
remove_additional_files() {
  section "Removing additional files..."
  
  # Find and remove any remaining cursor-related files
  local patterns=(
    "*.AppImage"
    "*.deb"
    "*.rpm"
    ".cursor*"
  )
  
  local removed=0
  for pattern in "${patterns[@]}"; do
    find "$HOME" -maxdepth 4 -iname "*cursor*$pattern" -type f 2>/dev/null | \
      grep -v ".backup-" | grep -v "cursor_installer" | \
      while read -r file; do
        local size=$(du -sb "$file" 2>/dev/null | cut -f1)
        rm -f "$file"
        success "Removed: $file ($(format_size $size))"
        removed=$((removed + 1))
      done
  done
  
  if [ $removed -eq 0 ]; then
    info "No additional files found"
  fi
}

# Final cleanup and verification
final_cleanup() {
  section "Performing final cleanup..."
  
  # Remove empty parent directories
  local parent_dirs=(
    "$HOME/.local/share"
    "$HOME/.config"
    "$HOME/.cache"
  )
  
  for dir in "${parent_dirs[@]}"; do
    find "$dir" -type d -empty -iname "*cursor*" -delete 2>/dev/null || true
  done
  
  # Clear thumbnail cache for cursor icons
  if [ -d "$HOME/.cache/thumbnails" ]; then
    find "$HOME/.cache/thumbnails" -iname "*cursor*" -delete 2>/dev/null || true
  fi
  
  success "Cleanup completed"
}

# Verify removal
verify_removal() {
  section "Verifying removal..."
  
  local remaining=$(find "$HOME" -maxdepth 4 -iname "*cursor*" 2>/dev/null | \
    grep -v ".backup-" | \
    grep -v "cursor_installer" | \
    grep -v "cursor-backup-" || true)
  
  if [ -n "$remaining" ]; then
    warning "Some files may still exist:"
    echo "$remaining" | while read -r file; do
      echo "  • $file"
    done
    echo ""
    info "These might be user-created files. Review and remove manually if needed."
  else
    success "No Cursor-related files found - system is completely clean!"
  fi
}

# Print success message
print_success() {
  echo ""
  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${GREEN}${BOLD}✨ Cursor AI has been completely removed${RESET}"
  echo -e "${GREEN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo ""
  
  info "Removal summary:"
  echo "  • Items removed: ${BOLD}$ITEMS_REMOVED${RESET}"
  echo "  • Space freed: ${BOLD}$(format_size $TOTAL_SIZE)${RESET}"
  echo ""
  
  if [ "$BACKUP_ENABLED" = true ] && [ -d "$BACKUP_DIR" ]; then
    info "Backup saved at:"
    echo "  $BACKUP_DIR"
    echo ""
  fi
  
  info "Additional cleanup:"
  echo "  • Restart your shell or run: ${BOLD}source ~/.bashrc${RESET}"
  echo "  • Log out and back in to refresh desktop entries"
  echo "  • Run ${BOLD}history -c${RESET} to clear command history (optional)"
  echo ""
  
  success "Your system is now free of all Cursor AI traces!"
  echo ""
}

# Main uninstallation flow
main() {
  print_header
  scan_cursor_files
  confirm_uninstall
  create_backup
  
  remove_app_directory
  remove_configuration
  remove_cache
  remove_extensions
  remove_credentials
  remove_desktop_entry
  remove_shell_config
  remove_system_integrations
  remove_additional_files
  final_cleanup
  
  verify_removal
  print_success
}

# Run main function
main