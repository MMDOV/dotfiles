# Repository Guidelines

## Project Structure & Module Organization

This repository is a personal Arch Linux dotfiles and automation setup. `dotfiles/` mirrors target install locations: `dotfiles/config/` maps to `~/.config`, `dotfiles/local/` maps to `~/.local`, and `dotfiles/system/` contains system-level files such as `pacman.conf` and `makepkg.conf`. `install/core/` contains focused setup scripts for major components such as Hyprland, Neovim, gaming, and `paru`. `scripts/utils/` holds daily maintenance commands, while `scripts/helpers/` contains standalone launchers and workflow helpers. `themes/`, `assets/`, and `tmux/` store visual assets, screenshots, themes, and tmux session tooling.

## Build, Test, and Development Commands

There is no compiled build step; most changes are shell scripts or config files. Useful commands:

- `bash -n scripts/utils/update-config.sh` checks shell syntax for one script.
- `find scripts install -name '*.sh' -print0 | xargs -0 bash -n` checks all shell scripts.
- `./scripts/utils/update-config.sh` copies edited configs into their local target paths.
- `./install/core/hyprland.sh` runs a focused installer; review before executing because it may install packages or modify system state.

Run commands from the repository root unless a script documents another working directory.

## Coding Style & Naming Conventions

Use Bash for automation scripts with `#!/usr/bin/env bash`, quoted variables, descriptive function names, and lowercase kebab-case filenames such as `vpn-bypass.sh`. Keep scripts idempotent where possible and prefer explicit paths derived from a detected repository root. For Lua configs, use clear module boundaries under `dotfiles/config/hypr/hyprland/` and keep routing, rules, keybinds, and exec logic separated. Preserve existing config syntax and indentation for Hyprland, Neovim, Waybar, tmux, and theme files.

## Testing Guidelines

No formal test framework is configured. Validate shell edits with `bash -n` before running them. For desktop config changes, copy or symlink the config, reload the affected tool, and test the behavior directly: `hyprctl reload` for Hyprland, open Neovim for Lua plugin changes, or restart Waybar for bar changes. Include manual verification notes for changes that affect monitors, startup services, keybinds, or package installation.

## Commit & Pull Request Guidelines

Recent history contains automated commits like `Automated Commit - 2026-05-23 22:42:32`. For manual commits, prefer concise imperative messages such as `Update Hyprland workspace rules` or `Add tmux session helper`. Pull requests should explain the workflow impact, list validation commands, call out Arch/hardware assumptions, and include screenshots for visual changes.

## Agent-Specific Instructions

Check for nested `AGENTS.md` files before editing subdirectories. In particular, `dotfiles/config/hypr/AGENTS.md` contains Hyprland-specific guidance that overrides this root guide for files under that path.
