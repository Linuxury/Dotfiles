# Dotfiles

How I set up my apps and desktop on NixOS: one folder per app. Nothing personal and no
secrets are in here, only configuration. The NixOS config that uses it is
[Linuxury/NixOS-Config](https://github.com/Linuxury/NixOS-Config).

## What is in here

| Folder | What it holds | How my NixOS config uses it |
| --- | --- | --- |
| `hypr/` | Hyprland (Lua) config, scripts, hypridle profiles, matugen templates | live link `~/.config/hypr` |
| `umbriel/` | Umbriel compositor config | live link `~/.config/umbriel` |
| `waybar/`, `wofi/`, `rofi/` | bar and launchers | live links into `~/.config/` |
| `swaync/` | notification centre style and colours | live links |
| `wayle/` | Wayle shell config | live link |
| `nvim/` | Neovim config | live link `~/.config/nvim` |
| `kitty/` | terminal config and Hyprland overrides | pinned input; copied once for linuxury so the colour tool can edit it |
| `vscodium/` | VSCodium base settings | merged into the real settings file at rebuild |
| `zed/` | Zed settings baseline | copied once if the app has none |
| `millennium/` | Steam Millennium theme and plugin config | copied once |
| `firefox/` | browser policies and `userChrome.css` | policies: pinned input; `userChrome.css`: live link |
| `chromium/` | browser policies | pinned input |
| `opencode/`, `MangoHud/`, `nano/`, `topgrade/` | small app configs | pinned input |

"Live link" means the app reads straight from a clone of this repo, so an edit takes effect
without a rebuild (for example `hyprctl reload`). "Pinned input" means the config is built
from the commit pinned in `flake.lock`, and a change arrives with the next `nix flake update`.

## Not in the repo: generated files

Colour palettes and similar files are generated on each machine (by matugen, Noctalia and
lazy.nvim) and stay local. They are listed in `.gitignore`:

```
hypr/colors.lua        hypr/colors.conf       hypr/colors-hyprlock.conf
hypr/noctalia.lua      hypr/hyprtoolkit.conf  hypr/hypridle.conf
nvim/lua/matugen.lua   nvim/lazy-lock.json
umbriel/noctalia.toml  umbriel/outputs.toml
```

A fresh clone works without them: the Hyprland config loads them with `pcall`, so a missing
file only means default colours until the theme tool writes its first palette.
`waybar/colors.css`, `wofi/colors.css` and `swaync/colors.css` are tracked seed values (a
default palette) that matugen overwrites on machines that use it.

## Use

My NixOS config clones this repo to `~/dotfiles` on the machines that use the live links.
To use a folder by hand:

```sh
git clone https://github.com/Linuxury/Dotfiles.git ~/dotfiles
ln -s ~/dotfiles/nvim ~/.config/nvim        # for example
```
