#!/usr/bin/env bash
# setup.sh — install dotfiles on a new machine

set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"
HOST="$(hostname)"
OS="$(uname -s)"

# ---- helpers ----
info()  { printf '\033[1;34m==> %s\033[0m\n' "$*"; }
warn()  { printf '\033[1;33mWARN: %s\033[0m\n' "$*"; }

# ---- zsh ----
info "Installing zshrc"
ln -sf "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"

# ---- starship ----
info "Installing starship.toml"
mkdir -p "$HOME/.config"
ln -sf "$DOTFILES/starship.toml" "$HOME/.config/starship.toml"

if [[ "$OS" == "Darwin" ]]; then
    # ---- alacritty (macOS) ----
    info "Installing alacritty config"
    mkdir -p "$HOME/.config/alacritty"
    ln -sf "$DOTFILES/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"

    # ---- aerospace (macOS, replaces i3) ----
    info "Installing aerospace config"
    mkdir -p "$HOME/.config/aerospace"
    ln -sf "$DOTFILES/aerospace/aerospace.toml" "$HOME/.config/aerospace/aerospace.toml"
else
    # ---- i3 (Linux) ----
    info "Installing i3 config"
    mkdir -p "$HOME/.config/i3"
    ln -sf "$DOTFILES/i3/config" "$HOME/.config/i3/config"

    HOST_I3="$DOTFILES/i3/hosts/$HOST.conf"
    if [[ -f "$HOST_I3" ]]; then
        info "Applying i3 host config for $HOST"
        ln -sf "$HOST_I3" "$HOME/.config/i3/local.conf"
    else
        warn "No i3 host config found for '$HOST' — creating empty local.conf"
        warn "Create i3/hosts/$HOST.conf for display layout and workspace assignments."
        touch "$HOME/.config/i3/local.conf"
    fi
fi

# ---- starship ----
if ! command -v starship &>/dev/null; then
    info "Installing starship"
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# ---- zsh ----
ZSH_BIN="$(command -v zsh || true)"
if [[ -z "$ZSH_BIN" ]]; then
    if [[ "$OS" == "Darwin" ]]; then
        warn "zsh not found — install it via Homebrew: brew install zsh"
    else
        info "Installing zsh"
        sudo apt-get install -y zsh
        ZSH_BIN="$(command -v zsh)"
    fi
fi

if [[ -n "${ZSH_BIN:-}" ]]; then
    CHSH_USER="${SUDO_USER:-$USER}"
    if [[ "$OS" == "Darwin" ]]; then
        CURRENT_SHELL="$(dscl . read "/Users/$CHSH_USER" UserShell 2>/dev/null | awk '{print $2}')"
    else
        CURRENT_SHELL="$(getent passwd "$CHSH_USER" | cut -d: -f7)"
    fi
    if [[ "$CURRENT_SHELL" != "$ZSH_BIN" ]]; then
        info "Setting zsh as default shell"
        if [[ "$(id -u)" -eq 0 ]]; then
            chsh -s "$ZSH_BIN" "$CHSH_USER"
        elif command -v sudo >/dev/null 2>&1 && (sudo -n true 2>/dev/null || sudo -v); then
            sudo chsh -s "$ZSH_BIN" "$CHSH_USER"
        else
            chsh -s "$ZSH_BIN"
        fi
    fi
fi

if [[ "$OS" != "Darwin" ]]; then
    # ---- GNOME Terminal: use login shell so it respects chsh ----
    if command -v gsettings &>/dev/null; then
        GT_PROFILE="$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")"
        if [[ -n "$GT_PROFILE" ]]; then
            GT_KEY="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${GT_PROFILE}/"
            if [[ "$(gsettings get "$GT_KEY" login-shell)" == "false" ]]; then
                info "Enabling login shell in GNOME Terminal"
                gsettings set "$GT_KEY" login-shell true
            fi
        fi
    fi

    # ---- IBus: switch input sources with Ctrl+Space (default is Shift+Space) ----
    if command -v gsettings &>/dev/null && gsettings writable org.freedesktop.ibus.general.hotkey triggers &>/dev/null; then
        info "Setting IBus input-source switcher to Ctrl+Space"
        gsettings set org.freedesktop.ibus.general.hotkey triggers "['<Control>space']"
    fi

    # ---- zshrc.local — machine-specific settings from ~/.bashrc ----
    BASHRC="$HOME/.bashrc"
    ZSHRC_LOCAL="$HOME/.zshrc.local"
    if [[ -f "$BASHRC" ]]; then
        info "Generating ~/.zshrc.local from machine-specific lines in ~/.bashrc"
        # Extract lines after the standard Ubuntu boilerplate ends (bash_completion block).
        # Capture everything from after the last 'fi' that closes the bash_completion block.
        awk '
            /^if ! shopt -oq posix/  { in_block=1 }
            in_block && /^fi$/       { in_block=0; found=1; next }
            found                    { print }
        ' "$BASHRC" > "$ZSHRC_LOCAL"
        if [[ ! -s "$ZSHRC_LOCAL" ]]; then
            warn "No machine-specific lines found after the boilerplate in ~/.bashrc — ~/.zshrc.local is empty"
        fi
    else
        warn "~/.bashrc not found — skipping ~/.zshrc.local generation"
    fi
fi

info "Done. Open a new terminal or run: exec zsh"
