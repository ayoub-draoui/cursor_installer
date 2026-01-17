#!/usr/bin/env bash
#
# DNS Troubleshooting and Fix Script
# Helps diagnose and fix DNS resolution issues
#

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BLUE}${BOLD}"
echo "╔══════════════════════════════════════════════╗"
echo "║   DNS Troubleshooting Helper                 ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${RESET}\n"

# Test 1: Basic connectivity
echo -e "${BLUE}[1/5]${RESET} Testing basic internet connectivity..."
if ping -c 1 8.8.8.8 &>/dev/null; then
  echo -e "  ${GREEN}✔${RESET} Internet connection is working"
else
  echo -e "  ${RED}✖${RESET} No internet connection detected"
  echo -e "  ${YELLOW}→${RESET} Check your network connection and try again"
  exit 1
fi

# Test 2: DNS resolution
echo -e "\n${BLUE}[2/5]${RESET} Testing DNS resolution..."

test_host() {
  local host=$1
  if nslookup "$host" &>/dev/null || host "$host" &>/dev/null; then
    echo -e "  ${GREEN}✔${RESET} Can resolve $host"
    return 0
  else
    echo -e "  ${RED}✖${RESET} Cannot resolve $host"
    return 1
  fi
}

DNS_WORKING=true
test_host "google.com" || DNS_WORKING=false
test_host "cursor.com" || DNS_WORKING=false
test_host "downloader.cursor.sh" || DNS_WORKING=false

if [ "$DNS_WORKING" = false ]; then
  echo -e "\n${YELLOW}DNS resolution is not working properly!${RESET}\n"
fi

# Test 3: Check current DNS servers
echo -e "\n${BLUE}[3/5]${RESET} Checking current DNS configuration..."
echo -e "  Current DNS servers:"

if [ -f /etc/resolv.conf ]; then
  grep "^nameserver" /etc/resolv.conf | while read -r line; do
    echo -e "    ${BLUE}→${RESET} $line"
  done
else
  echo -e "  ${YELLOW}⚠${RESET} /etc/resolv.conf not found"
fi

# Test 4: Test popular DNS servers
echo -e "\n${BLUE}[4/5]${RESET} Testing popular DNS servers..."

test_dns_server() {
  local name=$1
  local ip=$2
  
  if timeout 2 bash -c "echo > /dev/tcp/$ip/53" 2>/dev/null; then
    echo -e "  ${GREEN}✔${RESET} $name ($ip) - Reachable"
    return 0
  else
    echo -e "  ${RED}✖${RESET} $name ($ip) - Not reachable"
    return 1
  fi
}

test_dns_server "Google DNS" "8.8.8.8"
test_dns_server "Cloudflare DNS" "1.1.1.1"
test_dns_server "OpenDNS" "208.67.222.222"

# Test 5: Offer solutions
echo -e "\n${BLUE}[5/5]${RESET} Solutions and recommendations"
echo ""

if [ "$DNS_WORKING" = false ]; then
  echo -e "${YELLOW}${BOLD}Your DNS is not working. Here are your options:${RESET}\n"
  
  echo -e "${BOLD}Option 1: Temporarily add Google DNS${RESET}"
  echo "Run these commands:"
  echo -e "  ${BLUE}sudo bash -c 'echo \"nameserver 8.8.8.8\" > /etc/resolv.conf'${RESET}"
  echo -e "  ${BLUE}sudo bash -c 'echo \"nameserver 8.8.4.4\" >> /etc/resolv.conf'${RESET}"
  echo ""
  
  echo -e "${BOLD}Option 2: Use NetworkManager${RESET}"
  if command -v nmcli &>/dev/null; then
    CONNECTION=$(nmcli -t -f NAME connection show --active | head -n1)
    echo "Your active connection: $CONNECTION"
    echo "Run:"
    echo -e "  ${BLUE}nmcli con mod \"$CONNECTION\" ipv4.dns \"8.8.8.8 8.8.4.4\"${RESET}"
    echo -e "  ${BLUE}nmcli con down \"$CONNECTION\" && nmcli con up \"$CONNECTION\"${RESET}"
  else
    echo "NetworkManager not detected"
  fi
  echo ""
  
  echo -e "${BOLD}Option 3: Edit netplan (Ubuntu/Debian)${RESET}"
  if [ -d /etc/netplan ]; then
    echo "Edit your netplan config in /etc/netplan/"
    echo "Add under your connection:"
    echo "  nameservers:"
    echo "    addresses: [8.8.8.8, 8.8.4.4]"
    echo "Then run: sudo netplan apply"
  fi
  echo ""
  
  echo -e "${BOLD}Option 4: Manual download (Recommended!)${RESET}"
  echo "1. Open browser and go to: https://cursor.com/download"
  echo "2. Download the Linux AppImage file"
  echo "3. Make it executable: chmod +x ~/Downloads/cursor*.AppImage"
  echo "4. Extract it: ~/Downloads/cursor*.AppImage --appimage-extract"
  echo "5. Move to final location:"
  echo "   mkdir -p ~/.local/share/cursor"
  echo "   mv squashfs-root ~/.local/share/cursor/"
  echo ""
  
  # Offer to fix DNS automatically
  echo -n "Would you like me to temporarily fix DNS using Google DNS? [y/N] "
  read -r fix_dns
  
  if [[ "$fix_dns" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Backing up current DNS config..."
    sudo cp /etc/resolv.conf /etc/resolv.conf.backup
    
    echo "Setting Google DNS..."
    sudo bash -c 'cat > /etc/resolv.conf << EOF
# Temporary DNS fix
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF'
    
    echo -e "${GREEN}✔${RESET} DNS temporarily fixed!"
    echo ""
    echo "Testing..."
    if nslookup cursor.com &>/dev/null; then
      echo -e "${GREEN}✔${RESET} DNS is now working!"
      echo ""
      echo "You can now run the installer: ./cursor_install_script.sh"
      echo ""
      echo "To restore original DNS later:"
      echo "  sudo mv /etc/resolv.conf.backup /etc/resolv.conf"
    else
      echo -e "${RED}✖${RESET} DNS still not working. Try manual download."
    fi
  fi
else
  echo -e "${GREEN}✔${RESET} Your DNS is working fine!"
  echo ""
  echo "If the installer still fails, it might be a temporary issue."
  echo "Try again in a few minutes or use manual download:"
  echo "  https://cursor.com/download"
fi

echo ""