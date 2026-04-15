#!/usr/bin/env bash

set -euo pipefail

log() {
  printf '\n[%s] %s\n' "$(date '+%H:%M:%S')" "$*"
}

require_sudo() {
  if [[ "${EUID}" -ne 0 ]]; then
    sudo -v
  fi
}

have() {
  command -v "$1" >/dev/null 2>&1
}

detect_pkg_manager() {
  if have apt-get; then
    echo "apt"
    return
  fi
  if have dnf; then
    echo "dnf"
    return
  fi
  if have pacman; then
    echo "pacman"
    return
  fi

  echo "Unsupported package manager. This script supports apt, dnf, and pacman." >&2
  exit 1
}

install_base_packages_apt() {
  local packages=(
    build-essential
    cmake
    curl
    fd-find
    fzf
    git
    htop
    jq
    just
    make
    neovim
    nodejs
    npm
    pkg-config
    python3
    python3-pip
    ripgrep
    rustup
    shellcheck
    sqlite3
    tmux
    tree
    unzip
    wget
    zip
  )

  sudo apt-get update
  sudo apt-get install -y "${packages[@]}"
}

install_base_packages_dnf() {
  local packages=(
    @development-tools
    cmake
    curl
    fd-find
    fzf
    git
    htop
    jq
    just
    make
    neovim
    nodejs
    npm
    pkgconf-pkg-config
    python3
    python3-pip
    ripgrep
    rustup
    ShellCheck
    sqlite
    tmux
    tree
    unzip
    wget
    zip
  )

  sudo dnf install -y "${packages[@]}"
}

install_base_packages_pacman() {
  local packages=(
    base-devel
    cmake
    curl
    fd
    fzf
    git
    htop
    jq
    just
    make
    neovim
    nodejs
    npm
    pkgconf
    python
    python-pip
    ripgrep
    rustup
    shellcheck
    sqlite
    tmux
    tree
    unzip
    wget
    zip
  )

  sudo pacman -Sy --noconfirm --needed "${packages[@]}"
}

install_base_packages() {
  local manager="$1"

  log "Installing base development packages with ${manager}"
  case "${manager}" in
    apt) install_base_packages_apt ;;
    dnf) install_base_packages_dnf ;;
    pacman) install_base_packages_pacman ;;
    *)
      echo "Unsupported package manager: ${manager}" >&2
      exit 1
      ;;
  esac
}

ensure_rustup_default_toolchain() {
  if have rustup; then
    if ! rustup show active-toolchain >/dev/null 2>&1; then
      log "Initializing Rust stable toolchain"
      rustup default stable
    fi
  fi
}

install_uv() {
  if have uv; then
    log "uv already installed"
    return
  fi

  log "Installing uv"
  curl -LsSf https://astral.sh/uv/install.sh | sh
}

install_zed() {
  if have zed; then
    log "Zed already installed"
    return
  fi

  log "Installing Zed"
  curl -f https://zed.dev/install.sh | sh
}

install_tailscale() {
  if have tailscale; then
    log "Tailscale already installed"
    return
  fi

  log "Installing Tailscale"
  curl -fsSL https://tailscale.com/install.sh | sh
}

install_codex_cli() {
  if have codex; then
    log "Codex CLI already installed"
    return
  fi

  if ! have npm; then
    echo "npm is required to install Codex CLI." >&2
    exit 1
  fi

  log "Installing OpenAI Codex CLI"
  npm install -g @openai/codex
}

print_next_steps() {
  cat <<'EOF'

Next steps:
  - Restart your shell so ~/.local/bin is on PATH if needed.
  - Run `codex login` to authenticate Codex CLI.
  - Run `sudo tailscale up` to join your tailnet.
  - Run `zed` to finish Zed setup.
  - Run `uv python install` if you want managed Python versions from uv.
EOF
}

main() {
  local manager
  manager="$(detect_pkg_manager)"

  require_sudo
  install_base_packages "${manager}"
  ensure_rustup_default_toolchain
  install_uv
  install_codex_cli
  install_zed
  install_tailscale
  print_next_steps
}

main "$@"
