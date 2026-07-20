<h1 align="center">
  Kali Linux XFCE4 Desktop Environment for Android
</h1>

<p align="center">
  <img src="https://img.shields.io/badge/OS-Kali%20NetHunter-c6a0f6?style=for-the-badge&logo=kalilinux&logoColor=363a4f&labelColor=363a4f" alt="Kali Linux" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Termux-8aadf4?style=for-the-badge&logo=android&logoColor=363a4f&labelColor=363a4f" alt="Android Platform" />
  <img src="https://img.shields.io/badge/GUI-XFCE4%20Desktop-a6da95?style=for-the-badge&logo=xfce&logoColor=363a4f&labelColor=363a4f" alt="XFCE4 GUI" />
  <img src="https://img.shields.io/badge/Theme-Catppuccin%20Macchiato-f5a97f?style=for-the-badge&labelColor=363a4f" alt="Catppuccin Theme" />
  <img src="https://img.shields.io/badge/Shell-Bash%20Scripting-ed8796?style=for-the-badge&logo=gnu-bash&logoColor=363a4f&labelColor=363a4f" alt="Bash" />
</p>

<p align="center">
  An advanced, automated deployment framework for executing a hardware-accelerated <strong>Kali Linux XFCE4 Graphical Desktop</strong> natively on Android via <strong>Termux-X11</strong>. Engineered with kernel-level phantom process limit bypasses, systemd constraints patching, and an intelligent Bubblewrap (<code>bwrap</code>) sandbox wrapper for flawless application execution.
</p>

---

## 0. Core Dependencies & Architecture

Before initiating the deployment protocol, ensure the environment meets the required architecture standards. Do not utilize Google Play Store builds, as they contain deprecated API configurations.

<p align="left">
  <a href="https://github.com/termux/termux-app/releases/latest">
    <img src="https://img.shields.io/badge/1._TERMUX_APP-(F--Droid_Release)-8aadf4?style=for-the-badge&logo=termux&logoColor=363a4f&labelColor=363a4f" alt="Termux App" />
  </a>
  <a href="https://github.com/termux/termux-x11/releases/latest">
    <img src="https://img.shields.io/badge/2._TERMUX--X11-(Nightly_Build)-c6a0f6?style=for-the-badge&logo=xorg&logoColor=363a4f&labelColor=363a4f" alt="Termux X11" />
  </a>
</p>

---

## 1. Environment Preparation & Process Limit Bypass

Initialize Termux repositories, install essential networking and X11 packages, and execute the Android 12+ Phantom Process Killer bypass to prevent background session termination during high-load compilation.

```bash
pkg update -y && pkg upgrade -y
pkg install wget curl root-repo x11-repo termux-x11-nightly -y

# Disable Android Phantom Process Killer (Requires superuser access)
su -c "device_config put activity_manager max_phantom_processes 2147483647 && settings put global settings_enable_monitor_phantom_procs false"

```

---

## 2. Automated NetHunter Deployment

Fetch and execute the official Offensive Security NetHunter installer. During the interactive setup phase, input **Option `2**` to deploy the complete rootfs package.

```bash
wget -O install-nethunter-termux [https://offs.ec/2MceZWr](https://offs.ec/2MceZWr)
chmod +x install-nethunter-termux
./install-nethunter-termux

```

---

## 3. Internal Chroot Configuration & Security Patching

Inject automated configurations directly into the Kali Linux chroot environment. This stage handles DNS resolution, bypasses `systemd` package installation blocks, installs the XFCE4 desktop environment, and deploys a custom `bwrap` execution handler to enable Chromium and VS Code execution without standard kernel sandboxing failures.

```bash
nh -r -c "bash -s" << 'EOF'
# Configure reliable DNS resolution
echo "nameserver 8.8.8.8" > /etc/resolv.conf
apt update && apt upgrade -y

# Bypass systemd post-installation dependency errors
echo '#!/bin/sh' > /var/lib/dpkg/info/systemd.postinst
echo 'exit 0' >> /var/lib/dpkg/info/systemd.postinst
chmod +x /var/lib/dpkg/info/systemd.postinst
dpkg --configure systemd
dpkg --configure -a
apt --fix-broken install -y
apt upgrade -y

# Deploy XFCE4 Desktop, DBus, Audio server, and Terminal
apt install xfce4 xfce4-goodies dbus-x11 -y
apt install pulseaudio xfce4-terminal -y

# Deploy Intelligent Bubblewrap (bwrap) Interceptor
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

# Install Official Kali Themes, Menu Systems, and Security Meta-Packages
apt install kali-themes kali-wallpapers -y
apt update
apt install kali-menu -y
apt install kali-tools-top10 -y
apt install kali-tools-vulnerability-analysis -y
apt install kali-tools-information-gathering -y
EOF

```

---

## 4. Execution Shortcut Generation

Generate a global execution script within the Termux binary directory (`start-kali`) to automate the cleanup of stale processes, initialize the X11 TCP socket, and launch the XFCE4 desktop session with LLVMpipe software rendering.

```bash
cat << 'EOF' > $PREFIX/bin/start-kali
#!/data/data/com.termux/files/usr/bin/bash
pkill -f termux-x11 ; pkill -f dbus-launch ; pkill -f xfce4
termux-x11 :1 -listen tcp &
sleep 2
nh -r -c "dbus-launch --exit-with-session env DISPLAY=127.0.0.1:1 GALLIUM_DRIVER=llvmpipe xfce4-session"
EOF
chmod +x $PREFIX/bin/start-kali

```

---

## 5. System Execution Protocol

To launch the GUI workspace, adhere strictly to the following execution sequence:

1. Launch the **Termux-X11** application and keep it running in the background.
2. Return to the **Termux** terminal interface and execute:

```bash
start-kali

```

---

## 6. Process Termination & Clean Exit

To safely detach from the desktop session, kill all active X-Server daemons, terminate audio services, and unmount the filesystem:

```bash
pkill -f termux-x11 ; pkill -f dbus-launch ; pkill -f xfce4

```

---

## 7. Complete System Uninstallation

This protocol removes the entire Kali NetHunter rootfs filesystem, security toolkits, and custom execution binaries from the storage partition, restoring the Termux environment to its original state.

```bash
# Terminate all active graphics and chroot processes
pkill -f termux-x11 ; pkill -f dbus-launch ; pkill -f xfce4

# Revoke write protections and remove rootfs directories
chmod -R 777 kali-* 2>/dev/null
rm -rf kali-* install-nethunter-termux

# Remove generated launcher scripts and NetHunter symlinks
rm -f $PREFIX/bin/start-kali
rm -f $PREFIX/bin/nh$PREFIX/bin/nethunter

echo -e "\033[0;32m[+] Kali Linux filesystem and custom binaries successfully removed.\033[0m"

```

```

```
