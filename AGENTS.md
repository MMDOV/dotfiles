# Repository Guidelines

## Project Structure

- `dotfiles/config/` -> `~/.config/`
- `dotfiles/local/` -> `~/.local/` (bin, share/applications)
- `dotfiles/system/` -> `/etc/` (pacman.conf reference, hda-quirks) - requires sudo
- `install/core/` & `install/desktop/` - focused setup modules (hyprland, nvim, gaming, etc.)
- `dotfiles/config/look/` + `dotfiles/local/bin/look` - the color engine (looks, `targets.toml`, templates). Colors in app configs are generated from it, never hand-edited
- `dotfiles/config/quickshell/` - wallpaper picker (`wallpicker`) and notification daemon (`notifd`); `rofi/` is the launcher, power menu and screenshot picker
- `scripts/utils/` - daily maintenance (sync configs, install, update)
- `scripts/helpers/` - standalone launchers and workflow tools
- `tmux/` - tmux config and sessionizer script
- `themes/`, `assets/` - visual assets and SDDM/Qt themes

> Check `dotfiles/config/hypr/AGENTS.md` before editing Hyprland configs. It overrides this file for that subtree.

## Key Commands

- Validate all shell scripts: `find scripts install -name '*.sh' -print0 | xargs -0 bash -n`
- Validate single script: `bash -n <script>`
- Preview setup without changes: `./install/setup.sh --dry-run`
- Install on a machine that keeps its own desktop (no WM, display manager, session theming): `./install/setup.sh --no-wm` (add `--with-theme` for GTK/Qt theming). Scope lists: `install/setup.sh` (modules), `lib/scope.sh` (configs)
- Run only specific modules: `./install/setup.sh --only hyprland,nvim`
- Skip modules: `./install/setup.sh --skip drivers,sddm`
- Sync all tracked configs: `./scripts/utils/update-config.sh`
- Sync one config only: `./scripts/utils/update-config.sh config nvim`
- Reload Hyprland after config changes: `hyprctl reload`
- Re-render every app's colors: `look apply` (`look wallpaper PATH` to change wallpaper and colors)
- Add an app to the look: a template in `look/templates/` and an entry in `look/targets.toml` (`optional = true` skips it when its folder is missing or not writable)

## Conventions

- Bash scripts: `#!/usr/bin/env bash`, quoted variables, lowercase kebab-case filenames (e.g., `vpn-bypass.sh`), idempotent where possible.
- Use `REPO_ROOT` derived from script location, never hardcode `~/personal`.
- Preserve existing indentation and syntax for Hyprland, Neovim, Waybar, tmux, and theme files.
- Lua configs: clear module boundaries under `dotfiles/config/hypr/hyprland/`; separate routing, rules, keybinds, and exec logic.

## Testing

No formal test suite. Shell scripts must pass `bash -n` before running.
For desktop config changes: copy/symlink, reload the tool, and verify live behavior:

- `hyprctl reload` for Hyprland changes
- Restart Waybar for bar changes
- Open Neovim for Lua plugin changes
- Restart tmux server or source `.tmux.conf` for tmux changes

Verify scripts that use `sudo`, install packages, enable services, or overwrite `~/.config`, `~/.local`, or `/etc` before execution.

## Notes

- Target is Arch Linux with `pacman`, `paru`, systemd, Wayland, Hyprland.
- Zen, TeamSpeak and Telegram are deliberately not themed (tried and reverted); do not add them back without asking.
- Discord is themed only through Vesktop (`scripts/helpers/vesktop.sh`): `look` writes Vencord's Quick CSS in place so the open window recolors live. Never theme the official client's files.
- DarkenTS (TeamSpeak) is licensed no-sharing/no-derivatives: never copy or recolor it into the repo.
- The opencode.nvim plugin in Neovim config is commented out; do not re-enable it.
- Recent commit history may contain automated messages (`Automated Commit - YYYY-MM-DD ...`). For manual work, use concise imperative messages like `Update workspace rules` or `Add tmux helper`.
