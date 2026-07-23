#!/usr/bin/env bash
set -euo pipefail

REPO="sindus/localmsg"

case "$(uname -s)" in
  Darwin)
    echo "macOS détecté — installation via Homebrew..."
    brew tap sindus/localmsg "https://github.com/${REPO}"
    brew install --cask localmsg
    ;;
  Linux)
    if [ -f /etc/debian_version ] && command -v apt-get >/dev/null 2>&1; then
      echo "Debian/Ubuntu détecté — installation du paquet .deb..."
      tmp="$(mktemp -d)"
      curl -fsSL -o "$tmp/localmsg.deb" "https://github.com/${REPO}/releases/latest/download/localmsg.deb"
      sudo apt-get install -y "$tmp/localmsg.deb"
      rm -rf "$tmp"
    else
      echo "Distribution Linux détectée — installation de l'AppImage..."
      mkdir -p "$HOME/.local/bin"
      curl -fsSL -o "$HOME/.local/bin/localmsg.AppImage" "https://github.com/${REPO}/releases/latest/download/localmsg.AppImage"
      chmod +x "$HOME/.local/bin/localmsg.AppImage"
      echo "Installé dans ~/.local/bin/localmsg.AppImage"
      echo "Assurez-vous que ~/.local/bin est dans votre PATH."
    fi
    ;;
  *)
    echo "Plateforme non supportée par ce script."
    echo "Windows : téléchargez l'installeur sur https://github.com/${REPO}/releases/latest"
    exit 1
    ;;
esac

echo "LocalMsg installé."
