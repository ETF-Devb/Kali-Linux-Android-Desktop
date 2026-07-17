<h1 align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="15" width="0px"/>
  🐉 Kali Linux XFCE4 Desktop on Android
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="15" width="0px"/>
</h1>

<p align="center">
  <img src="https://img.shields.io/badge/OS-Kali%20NetHunter-c6a0f6?style=for-the-badge&logo=kalilinux&logoColor=363a4f&labelColor=363a4f" alt="Kali Linux" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Termux-8aadf4?style=for-the-badge&logo=android&logoColor=363a4f&labelColor=363a4f" alt="Android" />
  <img src="https://img.shields.io/badge/GUI-XFCE4%20Desktop-a6da95?style=for-the-badge&logo=xfce&logoColor=363a4f&labelColor=363a4f" alt="XFCE" />
  <img src="https://img.shields.io/badge/Theme-Catppuccin-f5a97f?style=for-the-badge&labelColor=363a4f" alt="Theme" />
</p>

<p align="center">
  A professional, hardware-accelerated <strong>Kali Linux XFCE4 Desktop</strong> deployment framework for Android via <strong>Termux-X11</strong>. Engineered with kernel-level phantom process limit bypasses, automated <code>systemd</code> bug patching, and an intelligent Bubblewrap (<code>bwrap</code>) sandbox wrapper for flawless GUI application execution.
</p>

---

## `  SYSTEM `  ` 00 `  ` CORE DOWNLOADS & DEPENDENCIES ` 

Before initiating the deployment protocol, you **must** install the official base environments below. Click the interactive powerline badges to download the latest builds directly:

<p align="center">
  <a href="https://github.com/termux/termux-app/releases/latest" target="_blank">
    <img src="https://img.shields.io/badge/1._DOWNLOAD-TERMUX_APP-8aadf4?style=for-the-badge&logo=termux&logoColor=363a4f&label=OFFICIAL%20F--DROID&labelColor=eff1f5" alt="Download Termux App" />
  </a>
  <a href="https://github.com/termux/termux-x11/releases/latest" target="_blank">
    <img src="https://img.shields.io/badge/2._DOWNLOAD-TERMUX__X11-a6da95?style=for-the-badge&logo=android&logoColor=363a4f&label=NIGHTLY%20BUILD&labelColor=8aadf4" alt="Download Termux X11" />
  </a>
</p>

> [!WARNING]  
> **DO NOT** download Termux from the Google Play Store. It is deprecated, unmaintained, and will cause dependency failures during installation.

---

## `  KALI `  ` 01 `  ` ENVIRONMENT PREPARATION & BYPASS ` 

Initialize Termux repositories, install essential networking and X11 packages, and execute the Android 12+ Phantom Process Killer bypass to prevent system freezes during heavy compilation:

```bash
pkg update -y && pkg upgrade -y
pkg install wget curl root-repo x11-repo termux-x11-nightly git -y

# Disable Android Phantom Process Killer (Requires Root authorization for su)
su -c "device_config put activity_manager max_phantom_processes 2147483647 && settings put global settings_enable_monitor_phantom_procs false"

```

---

## ` KALI`  `02`  `AUTOMATED NETHUNTER DEPLOYMENT` 

Fetch and execute the official Offensive Security NetHunter installer. During the interactive setup prompt, **select Option `2**` to deploy the full/minimal custom rootfs package:

```bash
wget -O install-nethunter-termux [https://offs.ec/2MceZWr](https://offs.ec/2MceZWr)
chmod +x install-nethunter-termux
./install-nethunter-termux

```

---

## ` KALI`  `03`  `CHROOT CONFIGURATION & BWRAP PATCH` 

Execute the following block to enter the Kali Linux root environment automatically, configure DNS resolution, patch systemd installation constraints, install the XFCE4 desktop, and deploy an intelligent `bwrap` interceptor (allowing Chromium and VS Code to run without sandbox crashes):

```bash
nh -r -c "bash -s" << 'EOF'
# Configure reliable DNS resolution
echo "nameserver 8.8.8.8" > /etc/resolv.conf
apt update && apt upgrade -y

# Bypass systemd post-installation dependency locks
echo '#!/bin/sh' > /var/lib/dpkg/info/systemd.postinst
echo 'exit 0' >> /var/lib/dpkg/info/systemd.postinst
chmod +x /var/lib/dpkg/info/systemd.postinst
dpkg --configure systemd
dpkg --configure -a
apt --fix-broken install -y && apt upgrade -y

# Install Desktop Environment, DBus, Audio server & Terminal
apt install xfce4 xfce4-goodies dbus-x11 pulseaudio xfce4-terminal -y

# Deploy Intelligent Bubblewrap (bwrap) Sandbox Interceptor
rm -f /usr/bin/bwrap
cat << 'BWRAP_EOF' > /usr/bin/bwrap
#!/bin/bash
while [ $# -gt 0 ]; do
    case "$1" in
        --setenv)
            export "$2"="$3"
            shift 3
            ;;
        --ro-bind|--ro-bind-try|--bind|--bind-try|--symlink|--file|--bind-data|--ro-bind-data|--dev-bind|--dev-bind-try)
            shift 3
            ;;
        --chdir|--tmpfs|--dir|--proc|--dev|--seccomp|--add-seccomp-fd|--block-fd|--userns|--pidns|--uid|--gid|--hostname|--unsetenv|--remount-ro|--exec-label)
            shift 2
            ;;
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
BWRAP_EOF
chmod +x /usr/bin/bwrap

# Deploy Official Kali Themes, Menus & Security Meta-Packages
apt install kali-themes kali-wallpapers -y
apt update && apt install kali-menu -y
apt install kali-tools-top10 kali-tools-vulnerability-analysis kali-tools-information-gathering -y
EOF

```

---

## ` KALI`  `04`  `EXECUTION SHORTCUT GENERATION` 

Create a global executable command (`start-kali`) in Termux to automate background cleanup, initialize the X11 TCP display server, and launch the XFCE4 session with LLVMpipe rendering:

```bash
cat << 'EOF' > $PREFIX/bin/start-kali
#!/data/data/com.termux/files/usr/bin/bash
pkill -f termux-x11 ; pkill -f dbus-launch ; pkill -f xfce4
termux-x11 :1 -listen tcp &
sleep 2
nh -r -c "env DISPLAY=127.0.0.1:1 GALLIUM_DRIVER=llvmpipe dbus-launch --exit-with-session xfce4-session"
EOF
chmod +x $PREFIX/bin/start-kali

```

---

## ` EXEC`  `05`  `SYSTEM LAUNCH PROTOCOL` 

To boot into your Kali Linux Graphical Workspace, follow this simple two-step sequence:

1. Open the **Termux-X11** app on your Android device and leave it running in the background.
2. Return to your **Termux** terminal interface and execute:

```bash
start-kali

```

---

## ` EXEC`  `06`  `PROCESS TERMINATION & KILL SWITCH` 

To safely detach from the desktop workspace, kill all active X-Server display daemons, terminate background audio services, and unmount the filesystem cleanly:

```bash
pkill -9 -f termux-x11 && pkill -9 -f dbus-launch && pkill -9 -f xfce4

```

---

## ` WARN`  `07`  `COMPLETE UNINSTALLATION PROTOCOL` 

> [!CAUTION]
> Executing this command sequence will permanently delete the entire Kali NetHunter filesystem, installed security tools, and configurations from your Android storage.

To cleanly remove NetHunter and restore Termux to its initial state without residue:

```bash
# 1. Terminate all active X11 graphics and chroot processes
pkill -9 -f termux-x11 ; pkill -9 -f xfce4

# 2. Revoke write permissions and delete NetHunter rootfs directories
chmod -R 777 kali-* 2>/dev/null
rm -rf kali-* install-nethunter-termux

# 3. Remove custom launcher binaries and symlinks
rm -f $PREFIX/bin/start-kali
rm -f $PREFIX/bin/nh$PREFIX/bin/nethunter

echo -e "\033[0;32m[+] Kali Linux filesystem and custom binaries successfully removed.\033[0m"

```

---
