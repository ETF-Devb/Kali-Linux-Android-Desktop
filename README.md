<h1 align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="15" width="0px"/>
  🐉 Kali Linux Desktop on Android (Termux-X11)
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/misc/transparent.png" height="15" width="0px"/>
</h1>

<p align="center">
  <img src="https://img.shields.io/badge/OS-Kali%20NetHunter-c6a0f6?style=for-the-badge&logo=kalilinux&logoColor=363a4f&labelColor=363a4f" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Termux-8aadf4?style=for-the-badge&logo=android&logoColor=363a4f&labelColor=363a4f" />
  <img src="https://img.shields.io/badge/GUI-XFCE4%20Desktop-a6da95?style=for-the-badge&logo=xfce&logoColor=363a4f&labelColor=363a4f" />
  <img src="https://img.shields.io/badge/Theme-Catppuccin-f5a97f?style=for-the-badge&labelColor=363a4f" />
</p>

<p align="center">
  A professional, fully automated deployment suite for running a hardware-accelerated **Kali Linux XFCE4 Desktop Environment** on Android natively via **Termux-X11**. Engineered with smart application sandboxing bypasses (`bwrap`), Android 12+ phantom process limits patching, and automated pre-configuration of core pentesting toolkits.
</p>

---

### [ >_ CORE_RESOURCES ]

Before initiating the deployment, ensure your Android device has the required base environments installed from official sources:

<p align="left">
  <a href="https://github.com/termux/termux-app/releases/latest">
    <img src="https://img.shields.io/badge/1._TERMUX_APP-(F--Droid_Only)-8aadf4?style=for-the-badge&logo=termux&logoColor=363a4f&labelColor=363a4f" />
  </a>
  <a href="https://github.com/termux/termux-x11/releases/latest">
    <img src="https://img.shields.io/badge/2._TERMUX--X11-(Nightly_Builds)-c6a0f6?style=for-the-badge&logo=android&logoColor=363a4f&labelColor=363a4f" />
  </a>
</p>

> [!WARNING]  
> **DO NOT** download Termux from the Google Play Store, as it is deprecated and will cause broken dependencies. Always use the F-Droid or official GitHub releases.

---

### [ >_ INSTALLATION_FLOW ]

#### 1. Environment Preparation & Phantom Process Fix
Open Termux, update the base repositories, and apply the Android 12+ process limit bypass (requires Root authorization for the `su` command):

```bash
pkg update -y && pkg upgrade -y
pkg install wget curl root-repo x11-repo termux-x11-nightly git -y

# Disable Android Phantom Process Killer (Prevents system freezes)
su -c "device_config put activity_manager max_phantom_processes 2147483647 && settings put global settings_enable_monitor_phantom_procs false"

```

#### 2. Automated NetHunter Deployment

Fetch and execute the official installer. When prompted during the setup, **select Option `2**` (Full/Minimal custom image):

```bash
wget -O install-nethunter-termux [https://offs.ec/2MceZWr](https://offs.ec/2MceZWr)
chmod +x install-nethunter-termux
./install-nethunter-termux

```

#### 3. Deep System Configuration & Bubblewrap Patch

Once installed, execute the following block to enter the Kali root environment, fix systemd constraints, deploy the smart `bwrap` bypass (allowing Chromium/VSCode to run flawlessly), and install Kali themes and pentesting tools:

```bash
nh -r -c "bash -s" << 'EOF'
echo "nameserver 8.8.8.8" > /etc/resolv.conf
apt update && apt upgrade -y

# Patch systemd post-install constraints
echo '#!/bin/sh' > /var/lib/dpkg/info/systemd.postinst
echo 'exit 0' >> /var/lib/dpkg/info/systemd.postinst
chmod +x /var/lib/dpkg/info/systemd.postinst
dpkg --configure systemd
dpkg --configure -a
apt --fix-broken install -y && apt upgrade -y

# Install Desktop Environment, Audio & Terminal
apt install xfce4 xfce4-goodies dbus-x11 pulseaudio xfce4-terminal -y

# Deploy Smart Bubblewrap (bwrap) Interceptor
rm -f /usr/bin/bwrap
cat << 'BWRAP_EOF' > /usr/bin/bwrap
#!/bin/bash
while [ $# -gt 0 ]; do
    case "$1" in
        --setenv) export "$2"="$3"; shift 3 ;;
        --ro-bind|--ro-bind-try|--bind|--bind-try|--symlink|--file|--bind-data|--ro-bind-data|--dev-bind|--dev-bind-try) shift 3 ;;
        --chdir|--tmpfs|--dir|--proc|--dev|--seccomp|--add-seccomp-fd|--block-fd|--userns|--pidns|--uid|--gid|--hostname|--unsetenv|--remount-ro|--exec-label) shift 2 ;;
        *)
            resolved=$(command -v "$1" 2>/dev/null)
            if [ -n "$resolved" ] && [ -f "$resolved" ] && [ -x "$resolved" ]; then
                shift; exec "$resolved" "$@"
            else
                shift
            fi
            ;;
    esac
done
BWRAP_EOF
chmod +x /usr/bin/bwrap

# Install Official Kali Themes, Menus & Security Tools
apt install kali-themes kali-wallpapers -y
apt update && apt install kali-menu -y
apt install kali-tools-top10 kali-tools-vulnerability-analysis kali-tools-information-gathering -y
EOF

```

#### 4. Create Global Launcher Shortcut

Create a single command shortcut to launch your desktop effortlessly:

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

### [ !_ EXECUTION_PROTOCOL ]

To boot into your Kali Linux Graphical Workspace, simply follow this two-step sequence:

1. Open the **Termux-X11** app and leave it running in the background.
2. Switch back to your **Termux** terminal and execute:

```bash
start-kali

```

---

### [ X_ KILL_SWITCH ]

To forcefully terminate all active X11 sessions, background audio daemons, and unmount the Kali filesystem cleanly:

```bash
pkill -9 -f termux-x11 && pkill -9 -f dbus-launch && pkill -9 -f xfce4

```

---

### [ ⚠️_ COMPLETE_UNINSTALLATION ]

> [!CAUTION]
> Executing this protocol will permanently wipe the Kali NetHunter filesystem, all installed security tools, and configurations from your device.

To completely remove Kali NetHunter and all associated custom shortcuts from Termux:

```bash
# 1. Terminate all running sessions
pkill -9 -f termux-x11 ; pkill -9 -f xfce4

# 2. Remove NetHunter rootfs and installation files
chmod -R 777 kali-* 2>/dev/null
rm -rf kali-* install-nethunter-termux

# 3. Remove custom launcher binaries
rm -f $PREFIX/bin/start-kali
rm -f $PREFIX/bin/nh$PREFIX/bin/nethunter

echo -e "\033[0;32m[+] Kali NetHunter has been completely removed from your system.\033[0m"

```
