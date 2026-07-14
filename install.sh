#!/usr/bin/env bash
# ArchPS5 — PlayStation 5-style Plymouth boot theme installer for Arch Linux.
# Supports both mkinitcpio and dracut initramfs builders.
set -euo pipefail

THEME_NAME="ArchPS5"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_SRC="${SCRIPT_DIR}/ArchPS5"
THEME_DST="/usr/share/plymouth/themes/ArchPS5"

if [ "$(id -u)" -ne 0 ]; then
  echo "Must run as root. Try:  sudo $0 $*" >&2
  exit 1
fi

if [ ! -d "${THEME_SRC}" ]; then
  echo "Theme source not found: ${THEME_SRC}" >&2
  exit 1
fi

if ! command -v plymouth-set-default-theme >/dev/null 2>&1; then
  echo "Plymouth is not installed. Install it first:" >&2
  echo "  sudo pacman -S plymouth" >&2
  exit 1
fi

# Detect which initramfs builder is in use.
if command -v mkinitcpio >/dev/null 2>&1; then
  INITRD_BUILDER="mkinitcpio"
elif command -v dracut >/dev/null 2>&1; then
  INITRD_BUILDER="dracut"
else
  INITRD_BUILDER="none"
fi

echo "==> Copying theme to ${THEME_DST}"
mkdir -p /usr/share/plymouth/themes
rm -rf "${THEME_DST}"
cp -r "${THEME_SRC}" "${THEME_DST}"
chmod -R u+rwX,go+rX,go-w "${THEME_DST}"

echo "==> Setting '${THEME_NAME}' as the default plymouth theme"
plymouth-set-default-theme "${THEME_NAME}"

# Rebuild the initramfs with whichever builder is present.
case "${INITRD_BUILDER}" in
  mkinitcpio)
    echo "==> Rebuilding initramfs (mkinitcpio -P)"
    mkinitcpio -P
    if [ -f /etc/mkinitcpio.conf ] \
       && ! grep -Eq '(^|[[:space:](])plymouth([,[:space:])]|$)' /etc/mkinitcpio.conf; then
      cat >&2 <<'EOF'

WARNING: 'plymouth' was not found in the HOOKS array of /etc/mkinitcpio.conf,
so the splash will NOT appear. Add 'plymouth' to HOOKS in /etc/mkinitcpio.conf
(keep 'encrypt' AFTER 'plymouth' if you use full-disk encryption), then re-run:
  sudo mkinitcpio -P
EOF
    fi
    ;;
  dracut)
    echo "==> Rebuilding initramfs (dracut --force --regenerate-all)"
    dracut --force --regenerate-all
    ;;
  *)
    cat >&2 <<'EOF'

WARNING: No initramfs builder found (neither mkinitcpio nor dracut).
Rebuild your initramfs manually so the theme takes effect.
EOF
    ;;
esac

cat <<'EOF'

==> Theme installed and initramfs rebuilt.

Add 'quiet splash' to your kernel parameters and re-run the bootloader config:
  GRUB          edit GRUB_CMDLINE_LINUX_DEFAULT in /etc/default/grub, then
                sudo grub-mkconfig -o /boot/grub/grub.cfg
  systemd-boot  append 'quiet splash' to the 'options' line in
                /boot/loader/entries/*.conf

Reboot to see the ArchPS5 boot animation.
EOF
