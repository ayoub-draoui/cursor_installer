#!/usr/bin/env bash

# Cursor AI Uninstaller
echo "🧹 This will remove Cursor AI."
read -p "Proceed? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled."
    exit 0
fi

# Remove app directory
if [ -d "$HOME/.local/share/cursor" ]; then
    rm -rf "$HOME/.local/share/cursor"
    echo "✅ Removed Cursor directory."
else
    echo "ℹ️ None found."
fi

# Remove desktop entry
if [ -f "$HOME/.local/share/applications/cursor-ai.desktop" ]; then
    rm "$HOME/.local/share/applications/cursor-ai.desktop"
    echo "✅ Removed desktop shortcut."
else
    echo "ℹ️ Desktop entry not found."
fi

# Remove alias
sed -i '/alias cursor=/d' "$HOME/.bashrc" "$HOME/.zshrc" 2>/dev/null || true
echo "✅ Removed terminal alias (if existed)."

update-desktop-database "$HOME/.local/share/applications" &>/dev/null || true
echo -e "\n🎉 Cursor AI removed."
