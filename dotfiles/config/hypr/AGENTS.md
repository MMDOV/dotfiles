# Repository Guidelines

## Project Structure & Module Organization

This repository stores Hyprland desktop configuration files. Top-level `hyprland.conf`, `hyprlock.conf`, `hypridle.conf`, and `hyprpaper.conf` are entry points loaded by the corresponding Hypr tools. The `hyprland/` directory contains sourced modules: `env.conf`, `execs.conf`, `general.conf`, `input.conf`, `rules.conf`, `colors.conf`, and keybinding groups under `hyprland/keybinds/`. Application-specific window rules live in `hyprland/apps/`. Helper scripts are in `hyprland/scripts/` and `hyprlock/`. Shader files live in `shaders/`. Lua experiments and editor settings are in `hyprland.lua`, `hyprland/general.lua`, and `.luarc.json`.

## Build, Test, and Development Commands

There is no build step; changes are plain configuration. Useful checks:

- `hyprctl reload` reloads Hyprland after config edits.
- `hyprctl monitors`, `hyprctl clients`, and `hyprctl devices -j` verify monitor, window, and input assumptions.
- `bash -n hyprland/scripts/screenshot_area.sh hyprlock/status.sh` checks shell script syntax.
- `find . -name '*.conf' -o -name '*.sh' -o -name '*.frag'` reviews tracked config-style files before committing.

Run commands from this repository or from `~/.config/hypr` after symlinking/copying the config into place.

## Coding Style & Naming Conventions

Use Hyprland's native `.conf` syntax: `key = value` assignments and named blocks with braces. Keep related settings grouped in focused files and source new modules from the nearest existing aggregate file, such as `hyprland/keybinds.conf` for keybindings. Prefer lowercase, descriptive file names (`browser.conf`, `screenshot_fullscreen.sh`). Shell scripts should start with `#!/usr/bin/env bash`, quote command substitutions, and avoid machine-specific paths unless this config already depends on them.

## Testing Guidelines

Validate edits in a live Hyprland session with `hyprctl reload`, then test the affected behavior directly: launch the app, trigger the keybind, lock the screen, or apply the shader. For scripts, run `bash -n` before manual execution. When editing monitor, input, or power-related settings, verify both laptop and external-display scenarios where possible.

## Commit & Pull Request Guidelines

Recent history uses automated messages such as `Automated Commit - 2026-05-11 00:15:43`. For manual work, use concise imperative commits, for example `Update screenshot keybinds` or `Tune Hyprlock status script`. Pull requests should describe the changed behavior, list tested commands, mention hardware assumptions such as monitor names, and include screenshots or short screen recordings for visual changes.

## Security & Configuration Tips

Do not commit secrets, tokens, or private hostnames. Keep personal overrides in a separate `custom/` file or local-only include when possible. Be careful with `exec` entries: prefer explicit commands and avoid background services that restart repeatedly on reload.
