# Linux bootstrap

Bootstrap a fresh Linux machine with the core tooling I use for development and research.

## Includes

- Base CLI utilities: `git`, `curl`, `wget`, `ripgrep`, `fzf`, `jq`, `tmux`, `htop`, `tree`, `shellcheck`, `just`
- Build tooling: compiler toolchain, `make`, `cmake`, `pkg-config`, `unzip`, `zip`
- Language tooling: Python 3, `pip`, Node.js, npm, Rust toolchain
- App installs: `uv`, OpenAI Codex CLI, Zed, Tailscale

## Usage

```bash
chmod +x setup.sh
./setup.sh
```

The script supports `apt`, `dnf`, and `pacman`, and skips tools that are already installed.
