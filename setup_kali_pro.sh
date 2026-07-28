#!/bin/bash
# ==============================================================================
#  KALI LINUX XFCE4 DEPLOYER FOR TERMUX — v2 (STABILITY FIX)
#  Idempotent: safe to re-run on a fresh device OR on top of an existing
#  NetHunter install to apply the fixes below without reinstalling anything.
# ==============================================================================
#
#  WHAT WAS BROKEN IN v1 AND WHY:
#
#  1) The v1 script replaced /usr/bin/bwrap with a hand-written shim to
#     dodge bubblewrap sandboxing. That's the wrong layer to fix this at.
#     Since gdk-pixbuf started routing image loading (SVG in particular)
#     through "glycin", which sandboxes every loader call with bubblewrap
#     (bwrap), and bwrap needs Linux namespaces that proot does not
#     support, every icon load attempt failed. glycin >= 2.0.1 actually
#     *detects* "bwrap doesn't work here" and falls back to running
#     unsandboxed instead of crashing — but only if it can cleanly see
#     that bwrap is unusable. A fake/partial bwrap shim hides that signal
#     and produces a worse failure (Gtk:ERROR, SIGABRT, session-wide
#     crash) instead of glycin's own graceful fallback.
#     Fix: don't shim bwrap at all. Remove it, force glycin/gdk-pixbuf to
#     the latest version, and let upstream's own fallback do its job.
#
#  2) thunar and xfdesktop4 were never installed, so every session logged
#     "Unable to launch Thunar" / "Unable to launch xfdesktop" — no file
#     manager, no wallpaper, no desktop icons. Added.
#
#  3) PulseAudio was installed on the Termux side but never actually
#     started, and the Kali side never pointed at it — hence
#     "Connection refused" on every launch. Fixed in the launcher.
#
#  4) libGL.so.1 was missing, so GALLIUM_DRIVER=llvmpipe had nothing to
#     load — added libgl1 + mesa-utils.
#
#  5) xfwm4's own compositor was fighting termux-x11's compositor
#     ("Another compositing manager is running on screen 0"). Pre-seeded
#     xfwm4 config with compositing off.
#
# ==============================================================================
set -e

clear
echo -e "\033[1;35m==================================================================\033[0m"
echo -e "  \033[1;32mKALI XFCE4 DEPLOYER (v2 — STABILITY FIX)\033[0m"
echo -e "\033[1;35m==================================================================\033[0m"

# ------------------------------------------------------------------------
# 1. Termux Host Packages (idempotent — safe to re-run)
# ------------------------------------------------------------------------
echo -e "\n\033[1;36m[1/5] Preparing Termux Host...\033[0m"
pkg update -y && pkg upgrade -y
pkg install -y wget curl root-repo x11-repo termux-x11-nightly pulseaudio

# ------------------------------------------------------------------------
# 2. NetHunter Installer — SKIPPED if an install already exists, so this
#    script can be re-run safely on top of a working Kali to apply fixes.
# ------------------------------------------------------------------------
if command -v nh >/dev/null 2>&1; then
    echo -e "\n\033[1;33m[2/5] Existing NetHunter install detected — skipping installer, applying fixes only.\033[0m"
else
    echo -e "\n\033[1;36m[2/5] Fetching NetHunter Script...\033[0m"
    wget -O install-nethunter-termux https://offs.ec/2MceZWr
    chmod +x install-nethunter-termux

    echo -e "\n\033[1;33m--------------------------------------------------\033[0m"
    echo -e "\033[1;31m IMPORTANT:\033[1;33m SELECT OPTION 2 WHEN PROMPTED (Minimal)\033[0m"
    echo -e "\033[1;33m--------------------------------------------------\033[0m"
    read -p "Press [ENTER] to launch Installer..."

    ./install-nethunter-termux
fi

# ------------------------------------------------------------------------
# 3. Inside Kali: patches + GUI + the real sandbox fix
# ------------------------------------------------------------------------
echo -e "\n\033[1;36m[3/5] Applying Patches & Installing GUI...\033[0m"
nh -r bash << 'INSIDE_KALI'
set -e
export DEBIAN_FRONTEND=noninteractive

# A. Fix DNS & proot/systemd hangs (unrelated to the GUI crash, still needed)
echo "nameserver 8.8.8.8" > /etc/resolv.conf 2>/dev/null || true
mkdir -p /var/lib/dpkg/info
echo -e "#!/bin/sh\nexit 0" > /var/lib/dpkg/info/systemd.postinst
echo -e "#!/bin/sh\nexit 0" > /usr/sbin/update-initramfs
chmod +x /var/lib/dpkg/info/systemd.postinst /usr/sbin/update-initramfs
rm -f /var/lib/dpkg/info/initramfs-tools.triggers

# B. THE REAL FIX: no fake bwrap. Remove it entirely and update glycin
#    so its own "sandboxing unavailable, run unsandboxed" fallback can
#    trigger cleanly instead of crashing.
echo "[*] Removing bubblewrap so glycin can detect sandboxing is unavailable..."
rm -f /usr/bin/bwrap
apt-get update -y
apt-get remove --purge -y bubblewrap 2>/dev/null || true
apt-get install -y --only-upgrade \
    glycin-loaders libglycin-gtk4-1-0 libgdk-pixbuf-2.0-0 libwnck-3-0 2>/dev/null || true

# C. Temporarily bypass heavy GUI triggers to prevent PRoot freeze during install
mv /usr/bin/gtk-update-icon-cache /usr/bin/gtk-update-icon-cache.bak 2>/dev/null || true
mv /usr/bin/update-mime-database /usr/bin/update-mime-database.bak 2>/dev/null || true
ln -sf /bin/true /usr/bin/gtk-update-icon-cache
ln -sf /bin/true /usr/bin/update-mime-database
ln -sf /bin/true /usr/bin/mandb

# D. Clean broken dependencies and install a COMPLETE minimal package set
#    (thunar + xfdesktop4 + libgl1 added — v1 was missing these)
dpkg --configure -a || true
apt update -y
apt install -y --no-install-recommends \
    wget curl ca-certificates dbus-x11 pulseaudio \
    xfce4-session xfwm4 xfce4-panel xfce4-terminal xfce4-whiskermenu-plugin \
    xfdesktop4 thunar \
    kali-menu mousepad librsvg2-common shared-mime-info \
    libgl1 mesa-utils

# E. Restore triggers and rebuild caches safely (guarded — v1 crashed here
#    with "command not found" because the binaries weren't always present)
rm -f /usr/bin/gtk-update-icon-cache /usr/bin/update-mime-database
mv /usr/bin/gtk-update-icon-cache.bak /usr/bin/gtk-update-icon-cache 2>/dev/null || true
mv /usr/bin/update-mime-database.bak /usr/bin/update-mime-database 2>/dev/null || true

echo "[*] Rebuilding caches (best-effort)..."
command -v update-mime-database >/dev/null 2>&1 && update-mime-database /usr/share/mime 2>/dev/null || true
command -v gtk-update-icon-cache >/dev/null 2>&1 && gtk-update-icon-cache -f -t /usr/share/icons/Adwaita 2>/dev/null || true

# F. Wallpaper
mkdir -p /usr/share/images/desktop-base
wget -qO /usr/share/images/desktop-base/kali-wallpaper.png https://raw.githubusercontent.com/KaliLinux/kali-wallpapers/main/src/kali-dark-16x9.png || true
ln -sf /usr/share/images/desktop-base/kali-wallpaper.png /etc/alternatives/desktop-background || true

# G. Disable xfwm4's own compositor so it stops fighting termux-x11's
#    compositor for screen 0 ("Another compositing manager is running")
mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml
cat << 'XFWM4CFG' > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="use_compositing" type="bool" value="false"/>
    <property name="workspace_count" type="int" value="1"/>
  </property>
</channel>
XFWM4CFG

echo "[✔] Kali patched."
INSIDE_KALI

# ------------------------------------------------------------------------
# 4. Generate Launcher — now actually starts PulseAudio and bridges it,
#    silences AT-SPI noise, and kills stale processes cleanly first.
# ------------------------------------------------------------------------
echo -e "\n\033[1;36m[4/5] Creating Launcher Script...\033[0m"
cat << 'LAUNCHER' > start-gui.sh
#!/bin/bash
pkill -f termux-x11 2>/dev/null || true
pkill -f dbus-launch 2>/dev/null || true
pkill -f xfce4 2>/dev/null || true
pkill -f xfwm4 2>/dev/null || true
sleep 1

nh -r mkdir -p /run/dbus /var/run/dbus 2>/dev/null || true

# Host-side audio server. Without this, PulseAudio inside Kali has
# nothing to connect to (this is why you were seeing "Connection refused").
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 2>/dev/null || true

termux-x11 :1 -listen tcp &
sleep 2
echo -e "\033[1;32m[✔] Server Started! Switch to Termux-X11 App.\033[0m"

nh -r dbus-launch --exit-with-session env \
    DISPLAY=127.0.0.1:1 \
    GALLIUM_DRIVER=llvmpipe \
    PULSE_SERVER=127.0.0.1 \
    NO_AT_BRIDGE=1 \
    xfce4-session
LAUNCHER
chmod +x start-gui.sh

# ------------------------------------------------------------------------
# 5. Finished
# ------------------------------------------------------------------------
echo -e "\n\033[1;32m[✔] DONE! Fixes applied.\033[0m"
echo -e "Start the desktop anytime with: \033[1;33m./start-gui.sh\033[0m\n"
echo -e "\033[1;90mIf it still crashes with a Gtk/Wnck error after this, your device's\033[0m"
echo -e "\033[1;90mproot build likely can't signal glycin cleanly, and the only fully\033[0m"
echo -e "\033[1;90mreliable fix is running Kali via a real chroot on a rooted device\033[0m"
echo -e "\033[1;90mrather than through NetHunter's rootless proot layer.\033[0m\n"
