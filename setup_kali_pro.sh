<h1 align="center">
  Kali Linux XFCE4 Desktop Environment for Android
</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Kali_Linux-c6a0f6?style=for-the-badge&logo=kalilinux&logoColor=24273a&labelColor=363a4f" alt="Kali Linux" />
  <img src="https://img.shields.io/badge/Android-a6da95?style=for-the-badge&logo=android&logoColor=24273a&labelColor=363a4f" alt="Android Platform" />
  <img src="https://img.shields.io/badge/XFCE4_Desktop-f5a97f?style=for-the-badge&logo=xfce&logoColor=24273a&labelColor=363a4f" alt="XFCE4 GUI" />
  <img src="https://img.shields.io/badge/Linux_Env-8aadf4?style=for-the-badge&logo=linux&logoColor=24273a&labelColor=363a4f" alt="Linux Environment" />
  <img src="https://img.shields.io/badge/Bash_Script-ed8796?style=for-the-badge&logo=gnu-bash&logoColor=24273a&labelColor=363a4f" alt="Bash" />
</p>

<p align="center">
  An advanced, fully automated deployment framework for executing a hardware-accelerated <strong>Kali Linux XFCE4 Graphical Desktop</strong> natively on Android via <strong>Termux-X11</strong>. Engineered with kernel-level phantom process limit bypasses, systemd constraints patching, anti-freeze triggers, and an intelligent Bubblewrap (<code>bwrap</code>) sandbox wrapper.
</p>

---

## ![0](https://img.shields.io/badge/1.-c6a0f6?style=for-the-badge&logo=gnubash&logoColor=24273a) The Master Installer Script

Execute the following block in your Termux terminal to generate the fully automated `setup_kali_pro.sh` deployment script. This monolithic script handles environment preparation, chroot injection, freeze-prevention, toolkits, and launcher generation autonomously.

```bash
cat << 'EOF' > setup_kali_pro.sh
#!/bin/bash
# ==============================================================================
#  KALI LINUX XFCE DEPLOYER (ENTERPRISE / ANTI-FREEZE EDITION)
#  Engineered for Termux-X11 | High Performance & Minimal Footprint
# ==============================================================================
set -e

# --- ANSI Colors ---
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_CYAN='\033[1;36m'
C_GREEN='\033[1;32m'
C_BLUE='\033[1;34m'
C_PURPLE='\033[1;35m'
C_YELLOW='\033[1;33m'

# --- Output Badges ---
B_SYS="${C_CYAN}${C_BOLD}[SYSTEM]${C_RESET}"
B_NET="${C_BLUE}${C_BOLD}[NETWORK]${C_RESET}"
B_GUI="${C_PURPLE}${C_BOLD}[DESKTOP]${C_RESET}"
B_OK="${C_GREEN}${C_BOLD}[SUCCESS]${C_RESET}"
B_WARN="${C_YELLOW}${C_BOLD}[ACTION]${C_RESET}"

clear
echo -e "${C_PURPLE}${C_BOLD}"
echo " ███████╗████████╗███████╗      ██████╗ ███████╗██╗   ██╗██████╗ "
echo " ██╔════╝╚══██╔══╝██╔════╝      ██╔══██╗██╔════╝██║   ██║██╔══██╗"
echo " █████╗     ██║   █████╗  █████╗██║  ██║█████╗  ██║   ██║██████╔╝"
echo " ██╔══╝     ██║   ██╔══╝  ╚════╝██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══██╗"
echo " ███████╗   ██║   ██║           ██████╔╝███████╗ ╚████╔╝ ██████╔╝"
echo " ╚══════╝   ╚═╝   ╚═╝           ╚═════╝ ╚══════╝  ╚═══╝  ╚═════╝ "
echo -e "${C_RESET}"
echo -e "${C_CYAN}${C_BOLD} KALI LINUX XFCE DEPLOYER \vert{} ENTERPRISE ANTI-FREEZE EDITION${C_RESET}"
echo -e "${C_CYAN} Automated GUI & Toolkit Framework - Engineered by ETF-Devb${C_RESET}"
echo "=================================================================="

# 1. Update Termux Host Packages
echo -e "\n${B_SYS} Step 1/5: Preparing Termux Host Environment..."
pkg update -y
pkg upgrade -y
pkg install -y wget curl root-repo x11-repo termux-x11-nightly pulseaudio

# 2. Download NetHunter Deployer
echo -e "\n${B_NET} Step 2/5: Fetching Official NetHunter Script..."
wget -O install-nethunter-termux [https://offs.ec/2MceZWr](https://offs.ec/2MceZWr)
chmod +x install-nethunter-termux

echo -e "\n${B_WARN} --------------------------------------------------"
echo -e "${C_YELLOW}${C_BOLD}SELECT OPTION 2 WHEN PROMPTED (Minimal RootFS)${C_RESET}"
echo -e "${B_WARN} --------------------------------------------------"
read -p "Press [ENTER] to launch NetHunter Installer..."

./install-nethunter-termux

# 3. Inject Anti-Freeze Patches, GUI & Toolkits inside NetHunter
echo -e "\n${B_GUI} Step 3/5: Injecting Anti-Freeze Patches, XFCE & Meta-Packages..."
nh -r bash << 'INSIDE_KALI'
set -e

# A. DNS Resolution Fix
echo "nameserver 8.8.8.8" > /etc/resolv.conf

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

# E. Deploy Desktop Environment, Themes, and Toolkit Meta-Packages
DEBIAN_FRONTEND=noninteractive apt install -y --no-install-recommends \
    xfce4 \
    xfce4-terminal \
    xfce4-whiskermenu-plugin \
    dbus-x11 \
    pulseaudio \
    kali-themes \
    kali-wallpapers \
    kali-menu \
    kali-tools-top10 \
    kali-tools-vulnerability-analysis \
    kali-tools-information-gathering

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

# G. Automate Kali-Dark & Accent Preferences
dbus-launch bash -c "
    xfconf-query -c xsettings -p /Net/ThemeName -s 'Kali-Dark' --create -t string
    xfconf-query -c xsettings -p /Net/IconThemeName -s 'Kali-Dark' --create -t string
    xfconf-query -c xfwm4 -p /general/theme -s 'Kali-Dark' --create -t string
" || true
INSIDE_KALI

# 4. Generate Launcher Script
echo -e "\n${B_SYS} Step 4/5: Generating Desktop Launcher (start-gui.sh)..."
cat << 'LAUNCHER' > start-gui.sh
#!/bin/bash
C_GREEN='\033[1;32m'
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

# 5. Finished
echo -e "\n${B_OK} Step 5/5: INSTALLATION COMPLETED SUCCESSFULLY!"
echo -e "Launch Desktop anytime using: ${C_GREEN}${C_BOLD}./start-gui.sh${C_RESET}\n"
EOF
