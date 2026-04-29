# dotfiles — agent guide

This repo manages shell and window manager config across multiple machines.
Run `setup.sh` to install everything on a new machine.

## Target machines

| Type                  | OS     | Run as                   |
|-----------------------|--------|--------------------------|
| Personal laptop       | Ubuntu | `bash setup.sh`          |
| Personal laptop       | macOS  | `bash setup.sh`          |
| Personal server       | Ubuntu | `bash setup.sh --server` |
| Remote servers        | Ubuntu | `bash setup.sh --server` |

`--server` skips all GUI-only config: i3, GNOME Terminal settings, IBus.

## Repo layout

```
.
├── i3/
│   ├── config            # portable i3 config (includes ~/.config/i3/local.conf at runtime)
│   └── hosts/
│       └── <hostname>.conf  # machine-specific: display layout, workspace→output assignments
├── zsh/
│   └── zshrc             # plain zsh + starship, no oh-my-zsh
├── starship.toml         # starship prompt config (custom per-host color via cksum hash)
├── setup.sh              # install script (copies files, sets default shell)
├── archive/
│   └── zsh_aliases       # old bash/zsh aliases — kept for reference, not installed
└── AGENTS.md             # this file
```

## Installing on a new machine

### Prerequisites

```bash
# starship (setup.sh does not install this automatically)
curl -sS https://starship.rs/install.sh | sh

# i3 (if using X11)
sudo apt install i3
```

`setup.sh` installs zsh automatically via apt if it's missing.

### Run setup

```bash
cd ~/.dotfiles
bash setup.sh
```

This copies:
- `zsh/zshrc`      → `~/.zshrc`
- `starship.toml`  → `~/.config/starship.toml`
- `i3/config`      → `~/.config/i3/config`
- `i3/hosts/<hostname>.conf` → `~/.config/i3/local.conf`  (empty file if no host config exists)

And sets zsh as the default shell via `chsh`.

## Adding a new machine's display/workspace config

1. Note your output names: `xrandr | grep ' connected'`
2. Create `i3/hosts/<hostname>.conf` with `exec_always --no-startup-id xrandr ...` and `workspace $wsN output <output>` lines.
3. Run `bash setup.sh` again (safe to re-run).

### Example host config

```
# i3/hosts/mynewmachine.conf
exec_always --no-startup-id xrandr --output DP-1 --auto --right-of eDP-1

workspace $ws1 output eDP-1
workspace $ws2 output eDP-1
workspace $ws6 output DP-1
workspace $ws7 output DP-1
```

## Existing machines

| Hostname    | Displays                         | Notes                              |
|-------------|----------------------------------|------------------------------------|
| dziewana2   | eDP-1 (built-in) + HDMI-1 (4K)  | ws1-6→HDMI, ws7-10→eDP |

## Shell setup details

- Shell: zsh (no oh-my-zsh, no plugins)
- Prompt: starship — config in `starship.toml`
  - Shows `user@host` with a stable per-host color (derived from cksum hash)
  - Right prompt: current time
- Vi keybindings enabled
- History: 10k lines, shared across sessions, deduped

## Adding zsh plugins later

When ready, edit `zsh/zshrc` and add plugin init lines (e.g. zsh-autosuggestions,
zsh-syntax-highlighting, fzf). Document them here.
