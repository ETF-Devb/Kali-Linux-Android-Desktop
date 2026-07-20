<h1 align="center">
  Kali Linux XFCE4 Desktop Environment for Android
</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Kali%20Linux-8aadf4?style=for-the-badge&logo=kalilinux&logoColor=24273a&labelColor=363a4f" alt="Kali Linux" />
  <img src="https://img.shields.io/badge/Android-a6da95?style=for-the-badge&logo=android&logoColor=24273a&labelColor=363a4f" alt="Android Platform" />
  <img src="https://img.shields.io/badge/XFCE4-f5a97f?style=for-the-badge&logo=xfce&logoColor=24273a&labelColor=363a4f" alt="XFCE4 GUI" />
  <img src="https://img.shields.io/badge/Linux-c6a0f6?style=for-the-badge&logo=linux&logoColor=24273a&labelColor=363a4f" alt="Linux Environment" />
  <img src="https://img.shields.io/badge/Bash-ed8796?style=for-the-badge&logo=gnubash&logoColor=24273a&labelColor=363a4f" alt="Bash" />
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

```

```bash
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

```bash
2

```

---

## 3. Internal Chroot Configuration & Security Patching

Inject automated configurations directly into the Kali Linux chroot environment. This stage handles DNS resolution, bypasses `systemd` package installation blocks, installs the XFCE4 desktop environment, and deploys a custom `bwrap` execution handler to enable Chromium and VS Code execution without standard kernel sandboxing failures.

```bash
nh -r

```

```bash
echo "nameserver 8.8.8.8" > /etc/resolv.conf

```

```bash
apt update && apt upgrade -y

```

```bash
echo '#!/bin/sh' > /var/lib/dpkg/info/systemd.postinst
echo 'exit 0' >> /var/lib/dpkg/info/systemd.postinst
chmod +x /var/lib/dpkg/info/systemd.postinst

```

```bash
dpkg --configure systemd

```

```bash
dpkg --configure -a

```

```bash
apt --fix-broken install -y
apt upgrade -y

```

```bash
apt install xfce4 xfce4-goodies dbus-x11 -y

```

```bash
cat << 'EOF' > /usr/bin/bwrap
#!/bin/bash
exec "$@"
EOF
chmod +x /usr/bin/bwrap

```

```bash
apt install pulseaudio xfce4-terminal -y

```

---

## 4. Execution Shortcut Generation

Generate a global execution script within the Termux binary directory (`start-kali`) to automate the cleanup of stale processes, initialize the X11 TCP socket, and launch the XFCE4 desktop session with LLVMpipe software rendering.

```bash
termux-x11 :1 -listen tcp &

```

```bash
nh -r

```

```bash
rm /usr/bin/bwrap

cat << 'EOF' > /usr/bin/bwrap
#!/bin/bash
exit 0
EOF
chmod +x /usr/bin/bwrap

```

```bash
cat << 'EOF' > /usr/bin/bwrap
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
EOF

```

```bash
chmod +x /usr/bin/bwrap

```

```bash
exit

```

---

## 5. System Execution Protocol

To launch the GUI workspace, adhere strictly to the following execution sequence:

```bash
pkill -f termux-x11 ; pkill -f dbus-launch ; pkill -f xfce4

```

```bash
nh -r

```

```bash
dbus-launch --exit-with-session env DISPLAY=127.0.0.1:1 GALLIUM_DRIVER=llvmpipe xfce4-session

```

```bash
apt install kali-themes kali-wallpapers -y

```

```bash
apt update
apt install kali-menu -y

```

```bash
apt install kali-tools-top10 -y

```

```bash
apt install kali-tools-vulnerability-analysis -y

```

```bash
apt install kali-tools-information-gathering -y

```

---

## 6. Process Termination & Clean Exit

To safely detach from the desktop session, kill all active X-Server daemons, terminate audio services, and unmount the filesystem:

```bash
pkill -9 -f termux-x11 && pkill -9 -f dbus-launch && pkill -9 -f xfce4

```

---

## 7. Complete System Uninstallation

This protocol removes the entire Kali NetHunter rootfs filesystem, security toolkits, and custom execution binaries from the storage partition, restoring the Termux environment to its original state.

```bash
# Terminate all active graphics and chroot processes
pkill -9 -f termux-x11 ; pkill -9 -f xfce4

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
