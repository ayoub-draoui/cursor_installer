## 📘Super Easy Guide to Installing Cursor AI on Linux

**For Beginners, Casual Users, and Non-Developers**
No tech jargon. No headaches. Just follow along!

---

### 🚀 What Is This?

This is a **simple one-file script** that installs [**Cursor AI**](https://cursor.so) — an AI-powered code editor based on Visual Studio Code — on your Linux system.
It’s made for **anyone**, even if you’ve never used the terminal much before.

---

### 🧠 What Is Cursor?

**Cursor** is like VS Code, but smarter. It has built-in AI features to:

* Suggest code
* Fix bugs
* Speed up your workflow

Think of it as **VS Code with AI superpowers**. And yes — it’s free.

---

### 💡 What This Script Does

✔️ Downloads the latest **Cursor AppImage**
✔️ Extracts and installs it to your local user folder
✔️ Adds a menu shortcut (like Chrome or LibreOffice)
✔️ Lets you launch it from the terminal using `cursor`
✔️ Shows nice progress steps and uses emojis for clarity

🧘 No need to memorize commands. The script will walk you through everything.

---
Here’s an **updated install script + uninstall script + README** for the **latest Cursor AI IDE (Linux)** 🛠️ — using the **newest stable AppImage build (v1.1.3 as of June 15 2025)** with correct download links and cleaner logic. ([Lanxk][1])

---

### 📌 What’s New

This update installs **Cursor AI IDE v1.1.3** — the latest stable Linux build available with improvements and new features. ([Lanxk][1])

---

### 🧠 What This Installer Does

✔ Downloads the **v1.1.3 AppImage**
✔ Extracts it to `~/.local/share/cursor`
✔ Adds a **menu launcher**
✔ Optional terminal alias: `cursor`
✔ Clean and non-root install

---

### ⚠️ Requirements

Ensure these are installed first:

```bash
sudo apt install curl desktop-file-utils
# or equivalent for your distro
```

---

### 🚀 How to Install

1. Save the updated install script as `install.sh`.
2. Make executable:

```bash
chmod +x install.sh
./install.sh
```

3. Follow prompts.

---

### 🧹 How to Uninstall

Save and run the uninstall script:

```bash
chmod +x uninstall.sh
./uninstall.sh
```

---

### 📁 File Locations

| Purpose   | Path                                            |
| --------- | ----------------------------------------------- |
| App files | `~/.local/share/cursor`                         |
| Launcher  | `~/.local/share/applications/cursor-ai.desktop` |
| Icon      | Inside the AppImage extract                     |
| Alias     | Appended to your shell rc                       |

---

