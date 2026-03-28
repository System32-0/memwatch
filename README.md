# memwatch

A simple RAM usage monitor that sends a desktop notification when your memory gets too high. It watches your RAM and warns you before things start getting sluggish.

---

## What it does

Polls your physical RAM usage every 3 seconds. If usage hits **80% or above**, it fires a critical desktop notification. You can dismiss it normally, or hit **Ignore** to silence it for the rest of the session.

Once RAM drops back below the threshold, the notification automatically closes itself.

---

## Requirements

- `bash`
- `notify-send` (from `libnotify`)
- `gdbus` (part of `glib2`, almost certainly already on your system)
- A DBus-compatible notification daemon (GNOME, KDE, etc.)

On Fedora-based systems:
```bash
sudo dnf install libnotify
```

On Debian/Ubuntu-based systems:
```bash
sudo apt install libnotify-bin
```

---

## Usage

Make it executable and run it:

```bash
chmod +x memwatch.sh
./memwatch.sh
```

It'll run silently in the background until your RAM gets high enough to warrant a warning.

### Adjusting the threshold

Open the script and change this line near the top:

```bash
THRESHOLD=80
```

Set it to whatever percentage makes sense for your setup.

---

## Autostart

You probably want this running automatically on login. A few ways to do that:

### KDE (easiest)
Go to **System Settings → Autostart → Add → Add Script**, and point it to `memwatch.sh`.

### systemd user service
Create `~/.config/systemd/user/memwatch.service`:

```ini
[Unit]
Description=RAM usage monitor

[Service]
ExecStart=/path/to/memwatch.sh
Restart=on-failure

[Install]
WantedBy=default.target
```

Then enable it:
```bash
systemctl --user enable --now memwatch.service
```

### .desktop autostart
Create `~/.config/autostart/memwatch.desktop`:

```ini
[Desktop Entry]
Type=Application
Name=memwatch
Exec=/path/to/memwatch.sh
Hidden=false
X-GNOME-Autostart-enabled=true
```

---

## Notes

- Originally written for Fedora-based systems, but should work on any Linux distro with a DBus notification daemon.
- Uses `notify-send -r` to replace the existing notification instead of stacking new ones.
- The **Ignore** action closes the notification and stops re-alerting for the current session. It does not persist across reboots.

---

## License

GNU General Public License v3.0 — see [LICENSE](LICENSE) for details.
