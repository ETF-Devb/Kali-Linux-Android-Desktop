#!/bin/bash
# ==============================================================================
#  KALI LINUX XFCE DEPLOYER (FIXED & OPTIMIZED EDITION)
#  Engineered for Termux-X11 | GUI Only, No Metasploit, 1 Wallpaper
# ==============================================================================
set -e

# --- Colors ---
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_CYAN='\033[38;2;148;226;213m'
C_GREEN='\033[38;2;166;227;161m'
C_BLUE='\033[38;2;137;180;250m'
C_PURPLE='\033[38;2;203;166;247m'
C_YELLOW='\033[38;2;249;226;175m'

clear
echo -e "${C_PURPLE}${C_BOLD}==================================================================${C_RESET}"
echo -e "  ${C_BLUE}${C_BOLD}KALI LINUX XFCE DEPLOYER${C_RESET} | ${C_CYAN}MINIMAL GUI EDITION${C_RESET}"
echo -e "  ${C_YELLOW}Automated GUI, Kali-Dark Theme, NO HACKING TOOLS${C_RESET}"
echo -e "${C_PURPLE}${C_BOLD}==================================================================${C_RESET}"

# 1. Update Termux Host Packages
echo -e "\n${C_CYAN}${C_BOLD}[SYSTEM]${C_RESET} Step 1/6: Preparing Termux Environment..."
pkg update -y && pkg upgrade -y
pkg install -y wget curl root-repo x11-repo termux-x11-nightly pulseaudio

# 2. Download NetHunter Deployer
echo -e "\n${C_BLUE}${C_BOLD}[NETWORK]${C_RESET} Step 2/6: Fetching NetHunter Script..."
wget -O install-nethunter-termux https://offs.ec/2MceZWr
chmod +x install-nethunter-termux

echo -e "\n${C_YELLOW}${C_BOLD}--------------------------------------------------${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD} IMPORTANT: SELECT OPTION 2 WHEN PROMPTED (Minimal RootFS)${C_RESET}"
echo -e "${C_YELLOW}${C_BOLD}--------------------------------------------------${C_RESET}"
read -p "Press [ENTER] to launch Installer..."

./install-nethunter-termux

# 3. Inject Anti-Freeze Patches & Install GUI
echo -e "\n${C_PURPLE}${C_BOLD}[DESKTOP]${C_RESET} Step 3 & 4: Injecting Patches, XFCE, and Kali Themes..."
nh -r bash << 'INSIDE_KALI'
set -e

# A. DNS Fix
echo "nameserver 8.8.8.8" > /etc/resolv.conf 2>/dev/null || true

# B. Prevent Systemd & initramfs Failures
mkdir -p /var/lib/dpkg/info
echo -e "#!/bin/sh\nexit 0" > /var/lib/dpkg/info/systemd.postinst
echo -e "#!/bin/sh\nexit 0" > /usr/sbin/update-initramfs
chmod +x /var/lib/dpkg/info/systemd.postinst /usr/sbin/update-initramfs
rm -f /var/lib/dpkg/info/initramfs-tools.triggers

# C. Anti-Freeze: Bypass man-db (Fixing the 88% hang)
rm -f /var/lib/dpkg/info/man-db.triggers 2>/dev/null || true
echo -e "#!/bin/sh\nexit 0" > /usr/bin/mandb
chmod +x /usr/bin/mandb

# D. Package Manager Fixes
dpkg --configure -a || true
apt update
apt --fix-broken install -y

# E. Deploy Core Desktop, Kali Menu, Themes & Required Tools (INCLUDES WGET/CURL FIX)
DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    wget \
    curl \
    ca-certificates \
    xfce4 \
    xfce4-terminal \
    xfce4-whiskermenu-plugin \
    dbus-x11 \
    pulseaudio \
    kali-themes \
    kali-defaults \
    kali-menu \
    desktop-base \
    gtk2-engines-pixbuf \
    mousepad \
    htop

# F. Smart Bubblewrap (bwrap) Sandbox Interceptor
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

# G. Single Famous Kali Wallpaper Download
mkdir -p /usr/share/images/desktop-base
wget -qO /usr/share/images/desktop-base/kali-wallpaper.png https://raw.githubusercontent.com/KaliLinux/kali-wallpapers/main/src/kali-dark-16x9.png || true
ln -sf /usr/share/images/desktop-base/kali-wallpaper.png /etc/alternatives/desktop-background || true

# H. Automate Kali-Dark Theme Preferences (With D-Bus daemon active)
mkdir -p /var/run/dbus /run/dbus
dbus-daemon --system --fork 2>/dev/null || true
dbus-launch bash -c "
    xfconf-query -c xsettings -p /Net/ThemeName -s 'Kali-Dark' --create -t string || true
    xfconf-query -c xsettings -p /Net/IconThemeName -s 'Kali-Dark' --create -t string || true
    xfconf-query -c xfwm4 -p /general/theme -s 'Kali-Dark' --create -t string || true
" || true
INSIDE_KALI

# 5. Generate Launcher Script
echo -e "\n${C_CYAN}${C_BOLD}[SYSTEM]${C_RESET} Step 5/6: Generating start-gui.sh..."
cat << 'LAUNCHER' > start-gui.sh
#!/bin/bash
pkill -f termux-x11 || true
pkill -f dbus-launch || true
pkill -f xfce4 || true

termux-x11 :1 -listen tcp &
sleep 2
echo -e "\033[38;2;166;227;161m\033[1m[✔] Display Server Started! Open Termux-X11 App now.\033[0m"
nh -r dbus-launch --exit-with-session env DISPLAY=127.0.0.1:1 GALLIUM_DRIVER=llvmpipe xfce4-session
LAUNCHER
chmod +x start-gui.sh

# 6. Finished
echo -e "\n${C_GREEN}${C_BOLD}[SUCCESS]${C_RESET} Step 6/6: INSTALLATION COMPLETED SUCCESSFULLY!"
echo -e "Launch Desktop anytime using: \033[38;2;166;227;161m\033[1m./start-gui.sh\033[0m\n"
