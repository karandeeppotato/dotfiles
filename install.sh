#!/usr/bin/env bash
# Applies the Alacritty + fastfetch configs from this repo to ~/.config,
# installing dependencies (fastfetch, Cascadia Mono NF) via dnf if missing.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing dependencies"
PACKAGES=()
command -v fastfetch >/dev/null 2>&1 || PACKAGES+=(fastfetch)
fc-list | grep -qi "cascadia mono nf" || PACKAGES+=(cascadia-mono-nf-fonts)

if [ "${#PACKAGES[@]}" -gt 0 ]; then
    sudo dnf install -y "${PACKAGES[@]}"
else
    echo "    Already installed, skipping."
fi

echo "==> Linking configs"
mkdir -p "$HOME/.config/alacritty" "$HOME/.config/fastfetch"
ln -sf "$REPO_DIR/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
ln -sf "$REPO_DIR/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
ln -sf "$REPO_DIR/fastfetch/samurai.txt" "$HOME/.config/fastfetch/samurai.txt"

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

echo "==> Done. Open a new Alacritty window to see it in action."
