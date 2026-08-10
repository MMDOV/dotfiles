# Repository Guidelines

## Project Structure & Module Organization

This directory is the Hyprland desktop configuration. Since Hyprland 0.55 the
compositor is configured in **Lua**, not hyprlang, so the entry point is
`hyprland.lua` and the modules under `hyprland/` are `.lua` files loaded with
`require`. Only the companion tools still use their own formats.

`hyprland.lua` requires four modules in order:

- `hyprland/general.lua` — pulls in `monitors.lua`, then sets input, layout,
  decoration, animation, `misc`, `xwayland` and `ecosystem` options via
  `hl.config`, and defines animation curves.
- `hyprland/rules.lua` — pulls in `roles.lua` for workspace placement, defines
  global window rules, then loads `hyprland/apps.lua`.
- `hyprland/execs.lua` — startup orchestration inside an `hl.on("hyprland.start", …)`
  hook.
- `hyprland/keybinds.lua` — composes the keybinding modules.

Two modules carry the machine-independence logic and are worth understanding
before editing anything display-related:

- `hyprland/monitors.lua` — monitor declarations. Displays are matched on their
  **EDID description** (`output = "desc:…"`), never on connector names like
  `eDP-1` or `DP-2`, which differ per machine and per port. A catch-all rule
  with an empty `output` is declared first so unknown displays still come up.
  `vrr` is set per-monitor here, not globally.
- `hyprland/roles.lua` — resolves `PRIMARY` / secondary roles from
  `hl.get_monitors()` and generates the workspace rules from them, then
  re-applies on `monitor.added` / `monitor.removed`. **Do not reintroduce
  hardcoded connector names in workspace rules.**

`hyprland/facts.lua` is **generated** by `scripts/utils/facts.sh --write-lua`
and is not tracked. It reports machine capabilities (backlight, GPU, chassis)
so config can branch on hardware; `keybinds.lua` uses it to decide whether to
load `keybinds/backlight.lua`. Hardware probing belongs in bash, not here —
EDID under `/sys/class/drm/*/edid` is unreadable unprivileged.

Application-specific window rules live in `hyprland/apps/`. Keybinding groups
live in `hyprland/keybinds/`, split by capability rather than form factor:
`media.lua` always loads, `backlight.lua` only where a backlight device exists.

Still in their own formats, because these are separate tools: `hyprlock.conf`,
`hypridle.conf`, `hyprpaper.conf`, `hyprshade.toml`, and `xdph.conf`
(xdg-desktop-portal-hyprland). Shaders are in `shaders/`, helper scripts in
`hyprland/scripts/` and `hyprlock/`.

## Build, Test, and Development Commands

There is no build step. Useful checks:

- `luac -p hyprland/<file>.lua` — parse-check a module before reloading.
- `hyprctl reload` — apply config changes.
- `hyprctl monitors` — read connector names **and the `description:` strings**
  needed for `desc:` matching in `monitors.lua`.
- `hyprctl clients`, `hyprctl devices -j` — verify window and input assumptions.
- `scripts/utils/facts.sh --report` — see what the machine is detected as.
- `bash -n hyprland/scripts/<script>.sh` — syntax-check shell helpers.

Role resolution can be exercised without a compositor by stubbing `hl` and
calling `roles.resolve()` — useful for checking multi-monitor behaviour you
cannot easily reproduce.

## Coding Style & Naming Conventions

Lua, tab-indented, formatted the way `stylua` leaves it. Configuration is
expressed through `hl.*` calls — `hl.config`, `hl.monitor`, `hl.workspace_rule`,
`hl.window_rule`, `hl.bind`, `hl.exec_cmd`, `hl.on` — with table arguments.
Group related settings in focused modules and `require` them from the nearest
aggregate (`keybinds.lua` for binds, `apps.lua` for per-app rules). Prefer
lowercase descriptive filenames (`browser.lua`, `screenshot_fullscreen.sh`).
Shell scripts start with `#!/usr/bin/env bash` and quote substitutions.

## Testing Guidelines

Validate in a live session with `hyprctl reload`, then exercise the affected
behaviour directly: launch the app, press the keybind, lock the screen.

For anything touching monitors, test **both** the docked and undocked cases,
and unplug/replug to confirm the `monitor.added` / `monitor.removed` hooks
re-resolve roles. A change that only works with the external display attached
is not finished.

## Commit & Pull Request Guidelines

Use concise imperative commits (`Fix thd exec path`, `Tune hyprlock status`).
Describe changed behaviour, list the commands tested, and state hardware
assumptions. Include a screen recording for visual changes.

## Security & Configuration Tips

Do not commit secrets, tokens, or private hostnames. Keep machine-specific
values out of tracked files — they belong in generated output (`facts.lua`,
`~/.config/uwsm/env-hyprland`) or keyed on monitor description. Be careful with
`exec` entries: prefer explicit commands and avoid services that restart on
every reload.
