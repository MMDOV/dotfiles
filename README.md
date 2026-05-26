# Personal Linux Dotfiles

> [!IMPORTANT]
> This repository is tuned for my own Arch Linux workstation, hardware, and workflow. It is useful as a reference for Hyprland, Bash automation, and desktop orchestration, but it should be reviewed before running on another machine.

A technical Arch Linux dotfiles repository for a Hyprland-based Wayland desktop. It combines modular desktop configuration, Lua-driven Hyprland rules, package installation scripts, local helper utilities, tmux session tooling, and GTK/Qt/SDDM theming into one reproducible setup.

## Screenshots

### Hyprland desktop

![Hyprland desktop screenshot](assets/screenshots/Hyprland_Desktop.png)

### Hyprland desktop 2

![Hyprland desktop screenshot 2](assets/screenshots/Nvim_btop.png)

### Neovim editor

![Neovim Editor screenshot](assets/screenshots/Nvim_Editor.png)

### Dolphin

![Dolphin screenshot](assets/screenshots/Dolphin.png)

## Architecture Overview

This repo is organized around a source-controlled copy of the Linux user environment:

- `dotfiles/config/` mirrors `~/.config/` for Hyprland, Waybar, Neovim, Yazi, terminal emulators, input methods, notifications, and application configs.
- `dotfiles/local/` mirrors `~/.local/` for desktop entries and user-level launchers.
- `dotfiles/system/` stores Arch-specific system configuration such as `pacman.conf` and `makepkg.conf`.
- `install/core/` contains focused install modules for base packages, drivers, PipeWire, NetworkManager, Hyprland, Neovim, tmux, gaming tools, and extras.
- `install/desktop/` contains display-manager and theme setup.
- `scripts/utils/` contains orchestration utilities for syncing configs, package installation, repo updates, and Obsidian/brain workflows.
- `scripts/helpers/` contains standalone workflow helpers for VPN routing, file managers, Steam/Lutris, Yazi, browser launchers, mounting, and GUI dialogs.
- `themes/`, `assets/`, and `tmux/` provide visual assets, screenshots, SDDM/Qt themes, tmux config, and session bootstrap scripts.

## Hyprland Lua Migration

The Hyprland configuration is being migrated into a Lua module structure under `dotfiles/config/hypr/`. Instead of keeping all compositor behavior in one large static config, `hyprland.lua` acts as the entrypoint and imports focused modules:

- `hyprland/general.lua` defines monitors, input behavior, gestures, layout defaults, borders, blur, shadows, and group styling.
- `hyprland/rules.lua` defines global workspace placement and shared window behavior, then loads app-specific rule modules.
- `hyprland/execs.lua` registers startup orchestration through a `hyprland.start` hook for launcher services, input methods, clipboard history, authentication agents, network applets, terminals, browsers, file managers, and VPN-related workspaces.
- `hyprland/keybinds.lua` composes keybinding modules for window management, laptop media keys, playback controls, and application shortcuts.
- `hyprland/apps/*.lua` separates advanced window rules by application domain: browsers, Steam/games, Discord/Vesktop, TeamSpeak, Spotify, terminals, VPN clients, QEMU, MPV, picture-in-picture overlays, RTL popups, Dolphin/Thunar progress dialogs, and Zenity/Tkinter windows.

This Lua layout makes the desktop configuration more programmable than plain Hyprland config. It uses structured function calls such as `hl.window_rule`, `hl.workspace_rule`, `hl.bind`, and `hl.exec_cmd` to express routing logic, reusable matchers, dynamic sizes/positions, special workspaces, startup placement, tags, opacity, pinning, floating behavior, and monitor-specific workspace defaults.

Examples of the routing model:

- Workspaces `1-3` are pinned to the laptop panel `eDP-1`, while `4-7` are assigned to the external monitor `HDMI-A-1`.
- Browser windows are tiled on workspace `2`, while music web apps are routed to workspace `6`.
- Games and Steam app windows are routed to workspace `1` with full opacity and game-friendly behavior.
- Communication tools such as Discord, Vesktop, and TeamSpeak are routed to workspace `5`.
- VPN tools are tagged and routed to the named special workspace `special:vpn`.
- Picture-in-picture windows are tagged, floated, pinned, resized, and moved to a predictable screen position.

## Bash Orchestration

The setup flow is intentionally modular rather than a single monolithic installer:

- `install/setup.sh` detects `REPO_ROOT`, defines an ordered module list, supports `--dry-run`, `--only`, and `--skip`, and runs each install module from `install/core/` or `install/desktop/`.
- Install modules are grouped by responsibility so package installation, services, desktop components, and application setup can be tested independently.
- `scripts/utils/update-config.sh` copies tracked config trees into their runtime destinations and reloads Hyprland when available.
- `scripts/utils/install.sh` ensures `paru` exists, installs a requested package, then copies the matching config folder.

This structure lets the repository work both as a fresh-system bootstrap and as a daily config synchronization tool.

## Main Commands

Clone the repository:

```bash
git clone https://github.com/MMDOV/dotfiles.git ~/personal
cd ~/personal
```

Preview the setup without making changes:

```bash
./install/setup.sh --dry-run
```

Run the full setup:

```bash
./install/setup.sh
```

Run only selected modules:

```bash
./install/setup.sh --only hyprland,nvim,tmux
```

Skip selected modules:

```bash
./install/setup.sh --skip drivers,sddm
```

Sync all configs after editing:

```bash
./scripts/utils/update-config.sh
```

Sync one config folder, for example Neovim:

```bash
./scripts/utils/update-config.sh config nvim
```

## Validation

There is no formal test suite because this is primarily system configuration, but the repo supports practical validation:

```bash
find scripts install -name '*.sh' -print0 | xargs -0 bash -n
hyprctl reload
```

Recommended manual checks:

- Run `./install/setup.sh --dry-run` before a fresh install.
- Reload Hyprland after Lua or compositor changes.
- Open the affected application to verify workspace routing and window rules.
- Restart Waybar, tmux, or Neovim after editing their configs.
- Review scripts that use `sudo`, install packages, enable services, or overwrite files under `~/.config`, `~/.local`, or `/etc`.

## Notes

- This setup targets Arch Linux and assumes `pacman`, `paru`, systemd, Wayland, and Hyprland.
- Some scripts enable services such as SDDM and NetworkManager.
- Some paths and workspace choices are intentionally personal and hardware-specific.
- A Persian version is available at [`README.fa.md`](README.fa.md).
