# Personal Linux Dotfiles

> [!IMPORTANT]
> This repository is mainly for my own personal use. It is tuned around my hardware, workflow, preferences, and Arch Linux setup, so it is not meant to be a polished one-command installer for everyone. Feel free to use it, copy parts of it, or take ideas from it, but please review everything before running it on your own machine.

A personal Arch Linux setup repository with configuration files and helper scripts for a Hyprland-based desktop environment.

This repo contains dotfiles for Hyprland, Waybar, Neovim, tmux, Yazi, Kitty/Foot, SDDM, GTK/Qt theming, and a collection of scripts to install packages and copy configs into the right places.

## Persian README

A Persian version is available at [`README.fa.md`](README.fa.md).

## What's inside

- `config/` - application configs, mostly intended for `~/.config/`
- `home/` - home-directory files such as `.tmux.conf`
- `local/` - local binaries and desktop entries for `~/.local/`
- `scripts/` - setup, install, update, and utility scripts
- `sddm/` - SDDM configuration and theme files
- `system/` - system-level Arch config files like `pacman.conf` and `makepkg.conf`
- `tmux/` - tmux plugins/themes
- `tokyonight-qt/` - Qt/Kvantum Tokyonight theme files

## Main scripts

- `scripts/setup.sh` - runs the main setup modules for a fresh system
- `scripts/update-config.sh` - copies repo configs into the matching local locations
- `scripts/install.sh` - installs a package with `paru` and copies its matching config
- Individual scripts like `hyprland.sh`, `nvim.sh`, `tmux.sh`, `browsers.sh`, `pipewire.sh`, and `bluetooth.sh` install/configure specific parts of the system

## Usage

Clone the repo into `~/personal`:

```bash
git clone <repo-url> ~/personal
cd ~/personal
```

Run a dry run first:

```bash
./scripts/setup.sh --dry-run
```

Run the full setup:

```bash
./scripts/setup.sh
```

You can also run only specific modules:

```bash
./scripts/setup.sh --only hyprland,nvim,tmux
```

Or skip modules:

```bash
./scripts/setup.sh --skip drivers,sddm
```

To copy configs after editing them in the repo:

```bash
./scripts/update-config.sh
```

To copy only one config folder, for example Neovim:

```bash
./scripts/update-config.sh config nvim
```

## Notes

- This setup is mainly for Arch Linux and uses `pacman` and `paru`.
- Some scripts require `sudo` and may enable system services.
- Some scripts overwrite existing config files in places like `~/.config`, `~/.local`, and `/etc`.
- Review scripts before running them on a new machine, especially `scripts/setup.sh`, `scripts/pacman.sh`, `scripts/drivers.sh`, and `scripts/sddm.sh`.
