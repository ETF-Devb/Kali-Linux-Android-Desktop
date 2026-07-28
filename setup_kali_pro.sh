#!/bin/bash
# ==============================================================================
#  KALI LINUX ULTRA-FAST & STABLE DEPLOYER (NO FREEZE & NO BLACK SCREEN)
#  Minimal GUI + Kali Menu + Audio + Mousepad ONLY
# ==============================================================================
set -e

clear
echo -e "\033[1;35m==================================================================\033[0m"
echo -e "  \033[1;32mKALI LIGHTWEIGHT DEPLOYER (STABLE & FAST)\033[0m"
echo -e "\033[1;35m==================================================================\033[0m"

# 1. Termux Host Packages
echo -e "\n\033[1;36m[1/5] Preparing Termux Host...\033[0m"
pkg update -y && pkg upgrade -y
pkg install -y wget curl root-repo x11-repo termux-x11-nightly pulseaudio

# 2. NetHunter Installer
echo -e "\n\033[1;36m[2/5] Fetching NetHunter Script...\033[0m"
wget -O install-nethunter-termux https://offs.ec/2MceZWr
chmod +x install-nethunter-termux

echo -e "\n\033[1;33m--------------------------------------------------\033[0m"
echo -e "\033[1;31m IMPORTANT:\033[1;33m SELECT OPTION 2 WHEN PROMPTED (Minimal)\033[0m"
echo -e "\033[1;33m--------------------------------------------------\033[0m"
read -p "Press [ENTER] to launch Installer..."

./install-nethunter-termux

# 3. Inside Kali setup (Safe & Fast Mode)
echo -e "\n\033[1;36m[3/5] Installing GUI & Fixing Icons safely...\033[0m"
nh -r bash << 'INSIDE_KALI'
set -e

# Fix DNS just in case
echo "nameserver 8.8.8.8" > /etc/resolv.conf 2>/dev/null || true

# Temporarily disable heavy triggers to prevent PRoot freeze
mv /usr/bin/gtk-update-icon-cache /usr/bin/gtk-update-icon-cache.bak 2>/dev/null || true
mv /usr/bin/update-mime-database /usr/bin/update-mime-database.bak 2>/dev/null || true
ln -sf /bin/true /usr/bin/gtk-update-icon-cache
ln -sf /bin/true /usr/bin/update-mime-database
ln -sf /bin/true /usr/bin/mandb

dpkg --configure -a || true
apt update

# Install Minimal Packages
DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    wget curl ca-certificates \
    xfce4-session xfwm4 xfce4-panel xfce4-terminal xfce4-whiskermenu-plugin \
    dbus-x11 pulseaudio kali-menu mousepad \
    librsvg2-common shared-mime-info

# CRITICAL FIX: Remove the problematic sandboxing packages that cause the black screen crash
DEBIAN_FRONTEND=noninteractive apt purge -y glycin-loaders glycin-thumbnailers || true

# Restore triggers
rm -f /usr/bin/gtk-update-icon-cache /usr/bin/update-mime-database
mv /usr/bin/gtk-update-icon-cache.bak /usr/bin/gtk-update-icon-cache 2>/dev/null || true
mv /usr/bin/update-mime-database.bak /usr/bin/update-mime-database 2>/dev/null || true

# Build Caches Safely (Prevents invisible icons)
echo "[*] Building icon cache..."
gdk-pixbuf-query-loaders > /usr/lib/aarch64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache || true
update-mime-database /usr/share/mime || true
gtk-update-icon-cache -f -t /usr/share/icons/Adwaita || true

# Single Wallpaper Configuration
mkdir -p /usr/share/images/desktop-base
wget -qO /usr/share/images/desktop-base/kali-wallpaper.png https://raw.githubusercontent.com/KaliLinux/kali-wallpapers/main/src/kali-dark-16x9.png || true
ln -sf /usr/share/images/desktop-base/kali-wallpaper.png /etc/alternatives/desktop-background || true

INSIDE_KALI

# 4. Generate Launcher
echo -e "\n\033[1;36m[4/5] Creating Launcher Script...\033[0m"
cat << 'LAUNCHER' > start-gui.sh
#!/bin/bash
pkill -f termux-x11 || true
pkill -f dbus-launch || true
pkill -f xfce4 || true

termux-x11 :1 -listen tcp &
sleep 2
echo -e "\033[1;32m[✔] Server Started! Switch to Termux-X11 App.\033[0m"
nh -r dbus-launch --exit-with-session env DISPLAY=127.0.0.1:1 GALLIUM_DRIVER=llvmpipe xfce4-session
LAUNCHER
chmod +x start-gui.sh

# 5. Finished
echo -e "\n\033[1;32m[✔] DONE! System is lightweight, fixed, and ready.\033[0m"
echo -e "Start the desktop anytime with: \033[1;33m./start-gui.sh\033[0m\n"
