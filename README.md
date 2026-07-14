# ArchPS5 — PS5 boot animation for Arch Linux (Plymouth theme)

A PlayStation 5-style boot splash with an Arch Linux logo, built for the
[Plymouth](https://gitlab.freedesktop.org/plymouth/plymouth) boot splash.

![theme files](ArchPS5/progress-0.png)

## One-line install

```sh
sudo ./install.sh
```

The installer copies the theme to `/usr/share/plymouth/themes/ArchPS5`, sets it
as the default Plymouth theme, and rebuilds the initramfs.

## Manual install

```sh
sudo pacman -S plymouth                       # if not already installed
sudo cp -r ArchPS5 /usr/share/plymouth/themes/
sudo plymouth-set-default-theme -R ArchPS5    # -R rebuilds the initramfs
```

## Enable the boot splash (required, or nothing shows)

**Step 1 — wire Plymouth into the initramfs.** Pick whichever builder you use:

- **mkinitcpio** (Arch default) — add `plymouth` to the `HOOKS` array in
  `/etc/mkinitcpio.conf`:

  ```conf
  HOOKS=(base udev plymouth autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck)
  ```

  Then rebuild every preset: `sudo mkinitcpio -P`
  (keep `encrypt` **after** `plymouth` if you use full-disk encryption).

- **dracut** — Plymouth is pulled in automatically once the `plymouth` package
  is installed, so just rebuild: `sudo dracut --force --regenerate-all`

**Step 2 — add `quiet splash` to your kernel parameters.**
   - **GRUB** — append to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`,
     then `sudo grub-mkconfig -o /boot/grub/grub.cfg`.
   - **systemd-boot** — append to the `options` line of your loader entry in
     `/boot/loader/entries/`.

Reboot. You should see the PS5-style animation.

## Files

| file | purpose |
|------|---------|
| `ArchPS5/ArchPS5.plymouth` | theme manifest |
| `ArchPS5/ArchPS5.script`   | animation logic (plays the `progress-*.png` sequence) |
| `ArchPS5/progress-0..745.png` | 746 animation frames |
| `ArchPS5/{box,bullet,entry,lock}.png` | password-prompt assets |
| `install.sh` | installer (root) |

## Uninstall

```sh
sudo plymouth-set-default-theme -R spinner      # revert to a stock theme
sudo rm -rf /usr/share/plymouth/themes/ArchPS5
```

## License

GPL-3.0-only — see [`ArchPS5/LICENSE`](ArchPS5/LICENSE).
