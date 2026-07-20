<h1 align="center">
  Kali Linux XFCE4 Desktop Environment for Android
</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Kali_Linux-c6a0f6?style=for-the-badge&logo=kalilinux&logoColor=white&labelColor=24273a" alt="Kali Linux" />
  <img src="https://img.shields.io/badge/Android-a6da95?style=for-the-badge&logo=android&logoColor=white&labelColor=24273a" alt="Android Platform" />
  <img src="https://img.shields.io/badge/XFCE4_Desktop-f5a97f?style=for-the-badge&logo=xfce&logoColor=white&labelColor=24273a" alt="XFCE4 GUI" />
  <img src="https://img.shields.io/badge/Linux_Env-8aadf4?style=for-the-badge&logo=linux&logoColor=white&labelColor=24273a" alt="Linux Environment" />
  <img src="https://img.shields.io/badge/Bash_Script-ed8796?style=for-the-badge&logo=gnu-bash&logoColor=white&labelColor=24273a" alt="Bash" />
</p>

<p align="center">
  An advanced, automated deployment framework for executing a hardware-accelerated <strong>Kali Linux XFCE4 Graphical Desktop</strong> natively on Android via <strong>Termux-X11</strong>. Engineered with kernel-level phantom process limit bypasses, systemd constraints patching, and an intelligent Bubblewrap (<code>bwrap</code>) sandbox wrapper.
</p>

---

## 🟣 0. Core Dependencies & Architecture

Before initiating the deployment protocol, ensure the environment meets the required architecture standards. Do not utilize Google Play Store builds, as they contain deprecated API configurations.

<p align="left">
  <a href="https://github.com/termux/termux-app/releases/latest">
    <img src="https://img.shields.io/badge/1._TERMUX_APP-(F--Droid_Release)-8aadf4?style=for-the-badge&logo=termux&logoColor=white&labelColor=363a4f" alt="Termux App" />
  </a>
  <a href="https://github.com/termux/termux-x11/releases/latest">
    <img src="https://img.shields.io/badge/2._TERMUX--X11-(Nightly_Build)-c6a0f6?style=for-the-badge&logo=xorg&logoColor=white&labelColor=363a4f" alt="Termux X11" />
  </a>
</p>

---

## 🟢 1. Environment Preparation & Process Limit Bypass

> Update core package lists and install essential dependencies for networking, repository management, and X11 rendering.
```bash
pkg update -y && pkg upgrade -y
pkg install wget curl root-repo x11-repo termux-x11-nightly -y

```

> Execute the Android 12+ Phantom Process Killer bypass to prevent background session termination during high-load operations (Requires superuser privileges).

```bash
su -c "device_config put activity_manager max_phantom_processes 2147483647 && settings put global settings_enable_monitor_phantom_procs false"

```

---

## 🟠 2. Automated NetHunter Deployment

> Fetch, assign execution permissions, and initialize the official Offensive Security NetHunter installer script.

```bash
wget -O install-nethunter-termux [https://offs.ec/2MceZWr](https://offs.ec/2MceZWr)
chmod +x install-nethunter-termux
./install-nethunter-termux

```

> During the interactive installation prompt, select the option to download and extract the complete Rootfs.

```bash
2

```

---

## 🔵 3. Internal Chroot Configuration & Security Patching

> Mount and enter the newly deployed Kali Linux rootfs environment.

```bash
nh -r

```

> Configure reliable DNS resolution to prevent network fetching errors.

```bash
echo "nameserver 8.8.8.8" > /etc/resolv.conf

```

> Synchronize package repositories and upgrade the base system.

```bash
apt update && apt upgrade -y

```

> Bypass standard `systemd` post-installation dependency errors native to chroot environments.

```bash
echo '#!/bin/sh' > /var/lib/dpkg/info/systemd.postinst
echo 'exit 0' >> /var/lib/dpkg/info/systemd.postinst
chmod +x /var/lib/dpkg/info/systemd.postinst

```

> Force systemd package configuration.

```bash
dpkg --configure systemd

```

> Reconfigure all unpacked but unconfigured Debian packages.

```bash
dpkg --configure -a

```

> Resolve broken dependencies and finalize system upgrades.

```bash
apt --fix-broken install -y
apt upgrade -y

```

> Deploy the core XFCE4 graphical environment, essential utilities, and the DBus messaging bus.

```bash
apt install xfce4 xfce4-goodies dbus-x11 -y

```

> Inject the initial Bubblewrap (`bwrap`) wrapper to allow specific package installations without sandbox failures.

```bash
cat << 'EOF' > /usr/bin/bwrap
#!/bin/bash
exec "$@"
EOF
chmod +x /usr/bin/bwrap

```

> Install the audio server daemon and native terminal emulator.

```bash
apt install pulseaudio xfce4-terminal -y

```

---

## 🌸 4. Server Initialization & Sandbox Optimization

> Initialize the Termux X11 server instance listening on a local TCP socket in the background.

```bash
termux-x11 :1 -listen tcp &

```

> Re-enter the Kali Linux chroot environment for final patching.

```bash
nh -r

```

> Remove the basic bwrap script and deploy a temporary structural bypass to silence application execution errors during setup.

```bash
rm /usr/bin/bwrap

cat << 'EOF' > /usr/bin/bwrap
#!/bin/bash
exit 0
EOF
chmod +x /usr/bin/bwrap

```

> Deploy the definitive, intelligent `bwrap` interceptor script to seamlessly filter kernel capability arguments, ensuring flawless execution of complex GUI applications like Chromium.

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

> Assign execution rights to the advanced bwrap interceptor.

```bash
chmod +x /usr/bin/bwrap

```

> Safely exit the current rootfs session.

```bash
exit

```

---

## 🍑 5. System Execution Protocol

> Purge any hanging X11, DBus, or desktop processes from memory before launching a new session.

```bash
pkill -f termux-x11 ; pkill -f dbus-launch ; pkill -f xfce4

```

> Enter the internal Kali root workspace.

```bash
nh -r

```

> Launch the XFCE4 graphical session, bind it to the local display socket, and force LLVMpipe software rendering.

```bash
dbus-launch --exit-with-session env DISPLAY=127.0.0.1:1 GALLIUM_DRIVER=llvmpipe xfce4-session

```

---

## 🌿 6. Theming & Toolkit Meta-Packages

*(Note: These can be executed inside the running Kali terminal to finalize the environment)*

> Deploy official Kali Linux aesthetics, icon sets, and wallpapers.

```bash
apt install kali-themes kali-wallpapers -y

```

> Update repositories and install the dynamic Kali application menu structure.

```bash
apt update
apt install kali-menu -y

```

> Install the Top 10 most critical security auditing tools.

```bash
apt install kali-tools-top10 -y

```

> Deploy the vulnerability analysis software suite.

```bash
apt install kali-tools-vulnerability-analysis -y

```

> Deploy the comprehensive information-gathering toolkit.

```bash
apt install kali-tools-information-gathering -y

```

```

```
