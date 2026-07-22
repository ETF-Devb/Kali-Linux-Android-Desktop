#!/bin/bash
# ==============================================================================
#  KALI LINUX XFCE DEPLOYER (ENTERPRISE / ANTI-FREEZE EDITION)
#  Engineered for Termux-X11 | High Performance & Minimal Footprint
# ==============================================================================
set -e

# --- Catppuccin Mocha Colors (TrueColor) ---
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_CYAN='\033[38;2;148;226;213m'   # Teal
C_GREEN='\033[38;2;166;227;161m'  # Green
C_BLUE='\033[38;2;137;180;250m'   # Blue
C_PURPLE='\033[38;2;203;166;247m' # Mauve
C_YELLOW='\033[38;2;249;226;175m' # Yellow

# --- Output Badges ---
B_SYS="${C_CYAN}${C_BOLD}[SYSTEM]${C_RESET}"
B_NET="${C_BLUE}${C_BOLD}[NETWORK]${C_RESET}"
B_GUI="${C_PURPLE}${C_BOLD}[DESKTOP]${C_RESET}"
B_TOOL="${C_YELLOW}${C_BOLD}[TOOLKIT]${C_RESET}"
B_OK="${C_GREEN}${C_BOLD}[SUCCESS]${C_RESET}"
B_WARN="${C_YELLOW}${C_BOLD}[ACTION]${C_RESET}"

clear
echo -e "${C_PURPLE}${C_BOLD}==================================================================${C_RESET}"
echo -e "  ${C_BLUE}${C_BOLD}KALI LINUX XFCE DEPLOYER${C_RESET} | ${C_CYAN}ENTERPRISE ANTI-FREEZE EDITION${C_RESET}"
echo -e "  ${C_YELLOW}Automated GUI & Toolkit Framework - Engineered by ETF-Devb${C_RESET}"
echo -e "${C_PURPLE}${C_BOLD}==================================================================${C_RESET}"

# 1. Update Termux Host Packages
echo -e "\n${B_SYS} Step 1/6: Preparing Termux Host Environment..."
pkg update -y
pkg upgrade -y
pkg install -y wget curl root-repo x11-repo termux-x11-nightly pulseaudio

# 2. Download NetHunter Deployer
echo -e "\n${B_NET} Step 2/6: Fetching Official NetHunter Script..."
wget -O install-nethunter-termux https://offs.ec/2MceZWr
chmod +x install-nethunter-termux

echo -e "\n${B_WARN} --------------------------------------------------"
echo -e "${C_YELLOW}${C_BOLD}SELECT OPTION 2 WHEN PROMPTED (Minimal RootFS)${C_RESET}"
echo -e "${B_WARN} --------------------------------------------------"
read -p "Press [ENTER] to launch NetHunter Installer..."

./install-nethunter-termux

# 3. Inject Anti-Freeze Patches & GUI inside NetHunter
echo -e "\n${B_GUI} Step 3/6: Injecting Anti-Freeze Patches & Core XFCE Desktop..."
nh -r bash << 'INSIDE_KALI'
set -e

# A. DNS Resolution Fix (Bypass Read-Only restriction gracefully)
rm -f /etc/resolv.conf 2>/dev/null || true
echo "nameserver 8.8.8.8" > /etc/resolv.conf 2>/dev/null || true

# B. Prevent Systemd Postinst Failures
mkdir -p /var/lib/dpkg/info
echo -e "#!/bin/sh\nexit 0" > /var/lib/dpkg/info/systemd.postinst
chmod +x /var/lib/dpkg/info/systemd.postinst

# C. Anti-Freeze: Bypass initramfs-tools & Neutralize Hanging DPKG Triggers
echo -e "#!/bin/sh\nexit 0" > /usr/sbin/update-initramfs
chmod +x /usr/sbin/update-initramfs
rm -f /var/lib/dpkg/info/initramfs-tools.triggers
rm -f /var/lib/dpkg/info/libgdk-pixbuf*.triggers

# D. Package Manager Fixes
dpkg --configure -a || true
apt update
apt --fix-broken install -y

# E. Deploy Core Desktop Environment
DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    xfce4 \
    xfce4-terminal \
    xfce4-whiskermenu-plugin \
    dbus-x11 \
    pulseaudio

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

# 4. Smart Deployment of Toolkits & Theming
echo -e "\n${B_TOOL} Step 4/6: Deploying Advanced Toolkits & Aesthetics..."

echo -e "${C_CYAN}[+] Installing Kali Themes & Wallpapers...${C_RESET}"
DEBIAN_FRONTEND=noninteractive apt install -y kali-themes kali-wallpapers

echo -e "${C_CYAN}[+] Updating Repositories & Installing Kali Menu...${C_RESET}"
apt update -y
DEBIAN_FRONTEND=noninteractive apt install -y kali-menu

echo -e "${C_CYAN}[+] Installing Top 10 Security Auditing Tools...${C_RESET}"
DEBIAN_FRONTEND=noninteractive apt install -y kali-tools-top10

echo -e "${C_CYAN}[+] Installing Vulnerability Analysis Suite...${C_RESET}"
DEBIAN_FRONTEND=noninteractive apt install -y kali-tools-vulnerability-analysis

echo -e "${C_CYAN}[+] Installing Information Gathering Toolkit...${C_RESET}"
DEBIAN_FRONTEND=noninteractive apt install -y kali-tools-information-gathering

# G. Automate Kali-Dark & Accent Preferences
dbus-launch bash -c "
    xfconf-query -c xsettings -p /Net/ThemeName -s 'Kali-Dark' --create -t string
    xfconf-query -c xsettings -p /Net/IconThemeName -s 'Kali-Dark' --create -t string
    xfconf-query -c xfwm4 -p /general/theme -s 'Kali-Dark' --create -t string
" || true
INSIDE_KALI

# 5. Generate Launcher Script
echo -e "\n${B_SYS} Step 5/6: Generating Desktop Launcher (start-gui.sh)..."
cat << 'LAUNCHER' > start-gui.sh
#!/bin/bash
C_GREEN='\033[38;2;166;227;161m'
C_RESET='\033[0m'

pkill -f termux-x11 || true
pkill -f dbus-launch || true
pkill -f xfce4 || true

termux-x11 :1 -listen tcp &
sleep 2
echo -e "${C_GREEN}[✔] Display Server Started! Open Termux-X11 App now.${C_RESET}"
nh -r dbus-launch --exit-with-session env DISPLAY=127.0.0.1:1 GALLIUM_DRIVER=llvmpipe xfce4-session
LAUNCHER
chmod +x start-gui.sh

# 6. Finished
echo -e "\n${B_OK} Step 6/6: INSTALLATION COMPLETED SUCCESSFULLY!"
echo -e "Launch Desktop anytime using: ${C_GREEN}${C_BOLD}./start-gui.sh${C_RESET}\n"
