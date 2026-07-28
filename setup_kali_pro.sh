#!/bin/bash
# =================================================
# GitHub Username: Wippix
# Repository: setup_kali_pro
# =================================================

echo "================================================="
echo "  KALI LINUX XFCE4 + TERMUX-X11 PRO SETUP        "
echo "  (With Surgical Fixes for PRoot / GTK Crashes)  "
echo "================================================="

if ! command -v nh &> /dev/null; then
    echo "[-] Error: NetHunter (nh) is not installed."
    echo "[-] Please install NetHunter CLI first."
    exit 1
fi

echo "[+] Entering Kali to install GUI and apply patches..."
nh -r bash << 'KALI_SETUP'
export DEBIAN_FRONTEND=noninteractive

apt update --fix-missing
apt install -y kali-desktop-xfce xfce4 xfce4-terminal dbus-x11 \
               librsvg2-common libgdk-pixbuf2.0-bin gtk-update-icon-cache \
               mesa-utils

echo "-------------------------------------------------"
echo "[+] Applying surgical fix for GTK/glycin crash..."
echo "-------------------------------------------------"

rm -f /usr/lib/aarch64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders/libpixbufloader-glycin.so
rm -rf /usr/libexec/glycin-loaders/ 2>/dev/null

if command -v gdk-pixbuf-query-loaders >/dev/null 2>&1; then
    gdk-pixbuf-query-loaders > /usr/lib/aarch64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache
    echo "[✔] Icon loaders cache updated."
fi

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t /usr/share/icons/Adwaita || true
    echo "[✔] GTK icon cache updated."
fi

mkdir -p /run/dbus
KALI_SETUP

echo "[+] Creating start-gui.sh launcher..."
cat << 'LAUNCHER' > start-gui.sh
#!/bin/bash

killall -9 termux-x11 Xwayland pulseaudio 2>/dev/null

pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

am start -n com.termux.x11/com.termux.x11.MainActivity
XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :1 -xstartup "nh -r bash -c 'export DISPLAY=:1; export PULSE_SERVER=127.0.0.1; dbus-launch --exit-with-session startxfce4'" &

echo "[✔] GUI Initialization completed! Check the Termux-X11 App."
LAUNCHER

chmod +x start-gui.sh

echo "================================================="
echo "  [✔] SETUP COMPLETE!                            "
echo "  Run ./start-gui.sh to launch your desktop.     "
echo "================================================="
