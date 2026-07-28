#!/bin/bash
# ==============================================================================
#  KALI LINUX PRO DEPLOYER FOR TERMUX (ENTERPRISE GRADE)
#  Minimal XFCE, Zero Hangs, No Dependency Cascades, 100% Stable
# ==============================================================================
set -e

clear
echo -e "\033[1;35m==================================================================\033[0m"
echo -e "  \033[1;32mKALI LIGHTWEIGHT DEPLOYER (ULTRA STABLE - NO CRASHES)\033[0m"
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

# 3. Inside Kali setup (Architectural Fixes & GUI)
echo -e "\n\033[1;36m[3/5] Applying Engineering Patches & Installing GUI...\033[0m"
nh -r bash << 'INSIDE_KALI'
set -e
export DEBIAN_FRONTEND=noninteractive

# A. Fix DNS & PRoot Systemd Hangs
echo "nameserver 8.8.8.8" > /etc/resolv.conf 2>/dev/null || true
mkdir -p /var/lib/dpkg/info
echo -e "#!/bin/sh\nexit 0" > /var/lib/dpkg/info/systemd.postinst
echo -e "#!/bin/sh\nexit 0" > /usr/sbin/update-initramfs
chmod +x /var/lib/dpkg/info/systemd.postinst /usr/sbin/update-initramfs
rm -f /var/lib/dpkg/info/initramfs-tools.triggers

# B. CRITICAL FIX: The Bubblewrap (bwrap) Interceptor
# This prevents GTK/Glycin black screens WITHOUT purging any critical XFCE dependencies.
echo "[*] Patching Sandbox to prevent crashes..."
rm -f /usr/bin/bwrap
cat << 'BWRAP' > /usr/bin/bwrap
#!/bin/bash
while [ $# -gt 0 ]; do
  case "$1" in
    --setenv) export "$2"="$3"; shift 3 ;;
    --ro-bind|--ro-bind-try|--bind|--bind-try|--symlink|--file|--bind-data|--ro-bind-data|--dev-bind|--dev-bind-try) shift 3 ;;
    --chdir|--tmpfs|--dir|--proc|--dev|--seccomp|--add-seccomp-fd|--block-fd|--userns|--pidns|--uid|--gid|--hostname|--unsetenv|--remount-ro|--exec-label) shift 2 ;;
    *)
      resolved=$(command -v "$1" 2>/dev/null)
      if [ -n "$resolved" ] && [ -f "$resolved" ] && [ -x "$resolved" ]; then
        shift
        exec "$resolved" "$@"
      else
        shift
      fi
      ;;
  esac
done
BWRAP
chmod +x /usr/bin/bwrap

# C. Temporarily bypass heavy GUI triggers to prevent PRoot freeze during install
mv /usr/bin/gtk-update-icon-cache /usr/bin/gtk-update-icon-cache.bak 2>/dev/null || true
mv /usr/bin/update-mime-database /usr/bin/update-mime-database.bak 2>/dev/null || true
ln -sf /bin/true /usr/bin/gtk-update-icon-cache
ln -sf /bin/true /usr/bin/update-mime-database
ln -sf /bin/true /usr/bin/mandb

# D. Clean broken dependencies and Install Minimal Packages securely
dpkg --configure -a || true
apt update -y
apt install -y --no-install-recommends \
    wget curl ca-certificates dbus-x11 pulseaudio \
    xfce4-session xfwm4 xfce4-panel xfce4-terminal xfce4-whiskermenu-plugin \
    kali-menu mousepad librsvg2-common shared-mime-info

# E. Restore triggers and Build Caches safely
rm -f /usr/bin/gtk-update-icon-cache /usr/bin/update-mime-database
mv /usr/bin/gtk-update-icon-cache.bak /usr/bin/gtk-update-icon-cache 2>/dev/null || true
mv /usr/bin/update-mime-database.bak /usr/bin/update-mime-database 2>/dev/null || true

echo "[*] Building icon cache safely..."
gdk-pixbuf-query-loaders > /usr/lib/aarch64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache || true
update-mime-database /usr/share/mime || true
gtk-update-icon-cache -f -t /usr/share/icons/Adwaita || true

# F. Single Wallpaper Configuration
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

# Ensure D-Bus directory exists for the session
nh -r mkdir -p /run/dbus /var/run/dbus

termux-x11 :1 -listen tcp &
sleep 2
echo -e "\033[1;32m[✔] Server Started! Switch to Termux-X11 App.\033[0m"
nh -r dbus-launch --exit-with-session env DISPLAY=127.0.0.1:1 GALLIUM_DRIVER=llvmpipe xfce4-session
LAUNCHER
chmod +x start-gui.sh

# 5. Finished
echo -e "\n\033[1;32m[✔] DONE! System is professionally deployed, stable, and ready.\033[0m"
echo -e "Start the desktop anytime with: \033[1;33m./start-gui.sh\033[0m\n"
