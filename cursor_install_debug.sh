#!/usr/bin/env bash
#
# Cursor AI Installer - DEBUG VERSION
# Use this if the normal installer fails
#
set -x  # Debug mode - show all commands

echo "=== Cursor AI Installer - Debug Mode ==="
echo "This will show detailed information about the download process"
echo ""

# Configuration
INSTALL_DIR="$HOME/.local/share/cursor"
APPIMAGE_URL="https://downloader.cursor.sh/linux/appImage/x64"
TMP_DIR="$(mktemp -d)"

cleanup() {
  echo ""
  echo "=== Cleanup ==="
  echo "Temporary directory: $TMP_DIR"
  echo "You can inspect files there before they're deleted"
  echo "Press Enter to cleanup and exit..."
  read -r
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

echo "=== Step 1: Testing Download URL ==="
echo "URL: $APPIMAGE_URL"
echo ""

# Test if URL is accessible
echo "Testing URL accessibility..."
if curl -I -L --max-time 10 "$APPIMAGE_URL" 2>&1 | head -20; then
  echo "✓ URL is accessible"
else
  echo "✗ URL test failed"
  exit 1
fi

echo ""
echo "=== Step 2: Following Redirects ==="
FINAL_URL=$(curl -Ls -o /dev/null -w %{url_effective} "$APPIMAGE_URL")
echo "Final URL after redirects: $FINAL_URL"
echo ""

echo "=== Step 3: Downloading AppImage ==="
echo "Download location: $TMP_DIR/cursor.AppImage"
echo ""

# Try download with verbose output
if curl -L --fail \
     --max-time 600 \
     --connect-timeout 30 \
     -o "$TMP_DIR/cursor.AppImage" \
     "$APPIMAGE_URL"; then
  echo ""
  echo "✓ Download completed"
else
  echo ""
  echo "✗ Download failed"
  exit 1
fi

echo ""
echo "=== Step 4: Verifying Downloaded File ==="
FILE="$TMP_DIR/cursor.AppImage"

if [ ! -f "$FILE" ]; then
  echo "✗ File does not exist!"
  exit 1
fi

# File size
SIZE=$(stat -c%s "$FILE" 2>/dev/null || stat -f%z "$FILE" 2>/dev/null)
echo "File size: $SIZE bytes ($(numfmt --to=iec-i --suffix=B $SIZE 2>/dev/null || echo "N/A"))"

# File type
echo "File type: $(file -b "$FILE")"

# First 100 bytes (to check if it's HTML error page)
echo ""
echo "First 100 bytes of file:"
head -c 100 "$FILE" | od -A x -t x1z -v
echo ""

# Check if it's an ELF executable
if file "$FILE" | grep -q "ELF"; then
  echo "✓ File is an ELF executable (AppImage)"
else
  echo "✗ File is NOT an ELF executable"
  echo ""
  echo "File might be an error page. Content preview:"
  head -n 50 "$FILE"
  exit 1
fi

echo ""
echo "=== Step 5: Making File Executable ==="
chmod +x "$FILE"
ls -lh "$FILE"

echo ""
echo "=== Step 6: Testing AppImage Extraction ==="
cd "$TMP_DIR" || exit 1
echo "Extracting..."

if ./cursor.AppImage --appimage-extract 2>&1 | head -20; then
  echo ""
  echo "✓ Extraction successful"
else
  echo ""
  echo "✗ Extraction failed"
  exit 1
fi

echo ""
echo "=== Step 7: Checking Extracted Files ==="
if [ -d "squashfs-root" ]; then
  echo "✓ squashfs-root directory exists"
  echo ""
  echo "Contents:"
  ls -la squashfs-root/ | head -20
  echo ""
  echo "Looking for AppRun:"
  ls -lh squashfs-root/AppRun 2>/dev/null || echo "✗ AppRun not found"
else
  echo "✗ squashfs-root directory not found"
  exit 1
fi

echo ""
echo "=== SUCCESS ==="
echo "The AppImage downloaded and extracted successfully!"
echo ""
echo "To complete installation, run:"
echo "  mv $TMP_DIR/squashfs-root $INSTALL_DIR/"
echo ""
echo "Or just run the normal installer again."
echo ""