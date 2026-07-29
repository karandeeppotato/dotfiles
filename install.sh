#!/usr/bin/env bash
# Applies the Alacritty + fastfetch + rofi configs from this repo to ~/.config,
# installing dependencies (fastfetch, rofi, Cascadia Mono NF) via dnf if missing.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing dependencies"
PACKAGES=()
command -v fastfetch >/dev/null 2>&1 || PACKAGES+=(fastfetch)
command -v rofi >/dev/null 2>&1 || PACKAGES+=(rofi)
fc-list | grep -qi "cascadia mono nf" || PACKAGES+=(cascadia-mono-nf-fonts)

if [ "${#PACKAGES[@]}" -gt 0 ]; then
    sudo dnf install -y "${PACKAGES[@]}"
else
    echo "    Already installed, skipping."
fi

echo "==> Linking configs"
mkdir -p "$HOME/.config/alacritty" "$HOME/.config/fastfetch" "$HOME/.config/rofi"
ln -sf "$REPO_DIR/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
ln -sf "$REPO_DIR/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
ln -sf "$REPO_DIR/fastfetch/samurai.txt" "$HOME/.config/fastfetch/samurai.txt"
ln -sf "$REPO_DIR/rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
ln -sf "$REPO_DIR/rofi/catppuccin-mocha-alacritty.rasi" "$HOME/.config/rofi/catppuccin-mocha-alacritty.rasi"

echo "==> Enabling fastfetch on new shells"
MARKER="# Show system info on new interactive shells"
if ! grep -qF "$MARKER" "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" <<'EOF'

# Show system info on new interactive shells
if [[ $- == *i* ]] && command -v fastfetch &> /dev/null; then
    fastfetch
fi
EOF
    echo "    Added fastfetch hook to ~/.zshrc"
else
    echo "    ~/.zshrc already has the fastfetch hook, skipping."
fi

if [ -f "$HOME/.config/kglobalshortcutsrc" ] && command -v kwriteconfig6 >/dev/null 2>&1; then
    echo "==> Freeing Meta+D from KDE's \"Show Desktop\" shortcut"
    if grep -q "^Show Desktop=Meta+D,Meta+D," "$HOME/.config/kglobalshortcutsrc"; then
        kwriteconfig6 --file kglobalshortcutsrc --group kwin --key "Show Desktop" "none,Meta+D,Peek at Desktop"
        echo "    Done. Open System Settings > Shortcuts once (or re-login) to apply."
    else
        echo "    Already freed, skipping."
    fi
    echo ""
    echo "    NOTE: Meta+D itself must still be bound to rofi manually:"
    echo "    System Settings > Shortcuts > Custom Shortcuts > New > Global Shortcut > Command/URL"
    echo "      Trigger: Meta+D"
    echo "      Action:  rofi -show drun -config $HOME/.config/rofi/config.rasi"
fi

echo "==> Done. Open a new Alacritty window to see it in action."
