# 🚀 Cursor AI Installer for Linux

> **Simple, automated installer scripts for Cursor AI - the AI-powered code editor**

[![Cursor](https://img.shields.io/badge/Cursor-v2.3.41-blue)](https://cursor.com)
[![Linux](https://img.shields.io/badge/Platform-Linux-green)](https://www.linux.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

---

## 📖 What is This?

A collection of **automated installer scripts** for [Cursor AI](https://cursor.com) on Linux systems with multiple installation options:

✅ **Simple installer** - Direct download, works even with DNS issues  
✅ **Full-featured installer** - Multiple fallback URLs with comprehensive error handling  
✅ **Debug installer** - Troubleshooting tool for installation problems  
✅ **DNS fix tool** - Automatic DNS troubleshooting and repair  
✅ **Complete uninstaller** - Removes everything (extensions, cache, auth tokens, configs)  

**No root/sudo required** • **Beautiful progress indicators** • **Multiple installation methods**

---

## 🧠 What is Cursor?

**Cursor** is an AI-powered code editor built on Visual Studio Code. Think of it as VS Code with superpowers:

- 🤖 **AI Code Assistance** - Intelligent code suggestions and completions
- 🐛 **AI Debugging** - Debug Mode for complex bug hunting  
- ✍️ **Natural Language Coding** - Describe what you want, Cursor writes it
- 🎨 **Visual Editor** - Design and code with visual browser sidebar
- 🔄 **VS Code Compatible** - All your favorite extensions work
- 🚀 **Multi-agent Execution** - Parallel AI agents working together

**Current Version: v2.3.41 (January 2026)**

---

## 📦 Available Scripts

### 🎯 `cursor_install_simple.sh` ⭐ **RECOMMENDED**
**Best for:** Quick installation, DNS issues, or first-time users

- Direct download from `downloads.cursor.com`
- No DNS lookups needed (works even with DNS problems)
- Fastest and most reliable
- ~100 lines of simple code

```bash
chmod +x cursor_install_simple.sh
./cursor_install_simple.sh
```

### 🔧 `cursor_install_script.sh`
**Best for:** Advanced users who want all features

- Multiple fallback download URLs
- DNS resolution testing
- Comprehensive error handling
- Works with both `curl` and `wget`
- Detailed progress information

```bash
chmod +x cursor_install_script.sh
./cursor_install_script.sh
```

### 🐛 `cursor_install_debug.sh`
**Best for:** Troubleshooting installation problems

- Shows every step in detail
- Displays file type and size information
- Verifies download integrity
- Helps diagnose what's failing

```bash
chmod +x cursor_install_debug.sh
./cursor_install_debug.sh
```

### 🌐 `fix_dns_script.sh`
**Best for:** Fixing DNS resolution issues

- Tests internet connectivity
- Checks DNS servers
- Offers automatic DNS fix
- Multiple DNS configuration options

```bash
chmod +x fix_dns_script.sh
./fix_dns_script.sh
```

### 🗑️ `cursor_uninstall_script.sh`
**Best for:** Complete removal of Cursor AI

- Scans and shows all Cursor files before removal
- Removes extensions, cache, auth tokens, credentials
- Clears keyring/wallet entries
- Optional backup before removal
- Shows space freed

```bash
chmod +x cursor_uninstall_script.sh
./cursor_uninstall_script.sh
```

---

## 📋 Requirements

### System Requirements
- **OS:** Any modern Linux distribution (Ubuntu, Fedora, Arch, Debian, etc.)
- **Architecture:** x86_64 (64-bit)
- **RAM:** 4GB minimum, 8GB recommended
- **Disk Space:** ~500MB for installation

### Required Packages
```bash
# Ubuntu/Debian
sudo apt install curl wget file desktop-file-utils libfuse2

# Fedora/RHEL
sudo dnf install curl wget file desktop-file-utils fuse-libs

# Arch Linux
sudo pacman -S curl wget file desktop-file-utils fuse2
```

**Note:** For Ubuntu 24.04+, use `libfuse2t64` instead of `libfuse2`

---

## 🚀 Quick Start Guide

### Method 1: Simple Install (Recommended)

```bash
# Clone or download the scripts
git clone https://github.com/yourusername/cursor_installer.git
cd cursor_installer

# Run the simple installer
chmod +x cursor_install_simple.sh
./cursor_install_simple.sh
```

### Method 2: Advanced Install

```bash
chmod +x cursor_install_script.sh
./cursor_install_script.sh
```

### Method 3: Manual Download (If installers fail)

1. Visit https://cursor.com/download in your browser
2. Download the Linux AppImage
3. Run these commands:

```bash
cd ~/Downloads
chmod +x Cursor*.AppImage
./Cursor*.AppImage --appimage-extract
mkdir -p ~/.local/share/cursor
mv squashfs-root ~/.local/share/cursor/
```

Then create a launcher:
```bash
cat > ~/.local/share/applications/cursor-ai.desktop <<EOF
[Desktop Entry]
Name=Cursor AI
Exec=$HOME/.local/share/cursor/squashfs-root/AppRun
Icon=$HOME/.local/share/cursor/squashfs-root/co.anysphere.cursor.png
Type=Application
Categories=Development;
EOF
```

---

## 💻 Usage

### Launching Cursor

After installation, launch Cursor using any of these methods:

1. **Applications Menu** - Search for "Cursor AI"
2. **Terminal (direct)** - `~/.local/share/cursor/squashfs-root/AppRun`
3. **Terminal (alias)** - `cursor` (if you enabled the alias during installation)

### First Launch

1. Cursor may ask to integrate with your system → Click **Yes**
2. Configure your preferences
3. Sign in or continue as guest
4. Start coding with AI assistance!

---

## 🔄 Updating

To update to the latest version:

```bash
# Just run any installer again
./cursor_install_simple.sh

# Or the full installer
./cursor_install_script.sh
```

Choose **Yes** when asked to reinstall. Your settings will be preserved.

---

## 🗑️ Uninstallation

### Complete Removal

```bash
chmod +x cursor_uninstall_script.sh
./cursor_uninstall_script.sh
```

**What gets removed:**
- Application files and binaries
- Desktop launchers
- Shell aliases
- Extensions and plugins
- Configuration files
- Cache and temporary files
- Authentication tokens
- Keyring/wallet entries

**Features:**
- Shows exactly what will be removed (with file sizes)
- Optional backup before removal
- Displays space freed
- Verifies complete removal

---

## 🐛 Troubleshooting

### DNS Resolution Errors

**Error:** `curl: (6) Could not resolve host: downloader.cursor.sh`

**Solution 1 - Use simple installer (bypasses DNS issues):**
```bash
./cursor_install_simple.sh
```

**Solution 2 - Run DNS fix tool:**
```bash
chmod +x fix_dns_script.sh
./fix_dns_script.sh
```

**Solution 3 - Manual DNS fix:**
```bash
sudo bash -c 'echo "nameserver 8.8.8.8" > /etc/resolv.conf'
sudo bash -c 'echo "nameserver 8.8.4.4" >> /etc/resolv.conf'
```

### AppImage Won't Extract

**Error:** Extraction fails or AppImage won't run

**Solution - Install FUSE:**
```bash
# Ubuntu 22.04 and older
sudo apt install libfuse2

# Ubuntu 24.04+
sudo apt install libfuse2t64

# Fedora
sudo dnf install fuse-libs

# Arch
sudo pacman -S fuse2
```

### Permission Denied

**Error:** `Permission denied` when running scripts

**Solution:**
```bash
chmod +x cursor_install_simple.sh
# Never use sudo - this is a user-level installation!
```

### Icon Not Showing

**Solution:**
```bash
update-desktop-database ~/.local/share/applications
# Or log out and back in
```

### Alias Doesn't Work

**Solution:**
```bash
# Reload shell configuration
source ~/.bashrc  # or ~/.zshrc

# Check if alias exists
alias | grep cursor
```

---

## 📁 Installation Locations

| Item | Location |
|------|----------|
| **Application** | `~/.local/share/cursor/squashfs-root/` |
| **Desktop Entry** | `~/.local/share/applications/cursor-ai.desktop` |
| **Configuration** | `~/.config/cursor/` |
| **Cache** | `~/.cache/cursor/` |
| **Extensions** | `~/.cursor/extensions/` |
| **Alias** | `~/.bashrc` or `~/.zshrc` |

---

## 🔍 Technical Details

### How It Works

1. **Download** - Fetches AppImage from Cursor's CDN
2. **Verify** - Checks file size and type
3. **Extract** - Unpacks AppImage using built-in extraction
4. **Install** - Moves files to `~/.local/share/cursor/`
5. **Configure** - Creates desktop entry and optional alias

### Why AppImage?

- ✅ **Portable** - Single file with all dependencies
- ✅ **No Root** - User-level installation
- ✅ **Clean** - Easy complete removal
- ✅ **Universal** - Works on all Linux distributions

### Download URLs

The installers use these URLs in order:

1. `https://downloads.cursor.com/production/.../Cursor-2.3.41-x86_64.AppImage` (Direct, no DNS issues)
2. `https://downloader.cursor.sh/linux/appImage/x64` (Official latest)
3. `https://cursor.sh/linux/appImage/x64` (Fallback)

---

## 🆘 Getting Help

### Common Issues Checklist

- [ ] DNS working? → Run `./fix_dns_script.sh`
- [ ] libfuse2 installed? → `sudo apt install libfuse2`
- [ ] Enough disk space? → `df -h ~`
- [ ] Internet connection? → `ping 8.8.8.8`
- [ ] Download corrupted? → Run `./cursor_install_debug.sh`

### Debug Information

To get detailed debug info:
```bash
./cursor_install_debug.sh
```

This shows:
- URL accessibility
- Redirect locations
- File size and type
- Extraction process
- All intermediate steps

---

## 🤝 Contributing

Found a bug or want to improve the scripts?

1. **Report Issues** - Open an issue on GitHub
2. **Submit PRs** - Fork, improve, and submit pull requests
3. **Share Feedback** - Let us know what works and what doesn't

---

## 📄 License

These installer scripts are MIT licensed. Cursor AI itself is proprietary software by Anysphere, Inc.

---

## 🙏 Acknowledgments

- **Cursor Team** at [Anysphere](https://www.cursor.com) for creating an amazing AI code editor
- **Linux Community** for testing and feedback
- **Contributors** who helped improve these scripts

---

## 📚 Resources

- [Cursor Official Website](https://cursor.com)
- [Cursor Documentation](https://docs.cursor.com)
- [Cursor Changelog](https://cursor.com/changelog)
- [Cursor Community Forum](https://forum.cursor.com)
- [Alternative Versions](https://cursorhistory.com)

---

## ⚡ Quick Reference

```bash
# Install (Simple - Recommended)
chmod +x cursor_install_simple.sh && ./cursor_install_simple.sh

# Install (Full-featured)
chmod +x cursor_install_script.sh && ./cursor_install_script.sh

# Fix DNS issues
chmod +x fix_dns_script.sh && ./fix_dns_script.sh

# Debug installation
chmod +x cursor_install_debug.sh && ./cursor_install_debug.sh

# Uninstall completely
chmod +x cursor_uninstall_script.sh && ./cursor_uninstall_script.sh

# Launch Cursor
cursor  # if alias enabled
~/.local/share/cursor/squashfs-root/AppRun  # direct path
```

---

## 🎯 Which Installer Should I Use?

| Situation | Use This Script |
|-----------|----------------|
| **First time installing** | `cursor_install_simple.sh` ⭐ |
| **DNS errors (can't resolve host)** | `cursor_install_simple.sh` |
| **Want latest with fallbacks** | `cursor_install_script.sh` |
| **Installation keeps failing** | `cursor_install_debug.sh` |
| **DNS not working** | `fix_dns_script.sh` |
| **Want to remove everything** | `cursor_uninstall_script.sh` |

---

**Made with ❤️ for the Linux community**

*Last updated: January 17, 2026 • Cursor v2.3.41*