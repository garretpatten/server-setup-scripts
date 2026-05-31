<!-- markdownlint-disable MD033 MD041 -->

<p align="center">
    <img
        src="https://img.shields.io/badge/Server%20setup%20scripts-headless%20CLI%20automation-E95420?style=for-the-badge&logo=ubuntu&logoColor=white"
        alt="Ubuntu-branded badge: headless CLI automation"
    />
</p>

<h1 align="center">Server Setup Scripts</h1>

<p align="center"><strong>Production-style Bash provisioning for headless Linux: servers, cloud VMs, and WSL.</strong></p>

<p align="center">
    Split <strong>install</strong> and <strong>configuration</strong> flows, audited helper patterns, submodule-backed dotfiles, and CI you can anchor release gates on—without desktop applications or GUI package managers.
</p>

<p align="center">
    <a href="./LICENSE"><img src="https://img.shields.io/github/license/garretpatten/server-setup-scripts?style=flat-square" alt="License: MIT" /></a>
    <a href="https://ubuntu.com/"
        ><img src="https://img.shields.io/badge/platform-Ubuntu%2020.04%2B-E95420?style=flat-square&logo=ubuntu&logoColor=white" alt="Ubuntu 20.04 or newer"
    /></a>
    <img src="https://img.shields.io/badge/shell-bash-black?style=flat-square&logo=gnu-bash&logoColor=white" alt="Shell: Bash" />
    <img src="https://img.shields.io/badge/scope-CLI%20only-blue?style=flat-square&logo=gnubash&logoColor=white" alt="Scope: CLI only" />
</p>

<p align="center">
    <a href="https://github.com/garretpatten/server-setup-scripts/actions/workflows/test-runner.yaml"
        ><img src="https://img.shields.io/github/actions/workflow/status/garretpatten/server-setup-scripts/test-runner.yaml?branch=master&label=Ubuntu%20CI&logo=github&style=flat-square" alt="Test runner workflow status"
    /></a>
    <a href="https://github.com/garretpatten/server-setup-scripts/actions/workflows/quality-checks.yaml"
        ><img src="https://img.shields.io/github/actions/workflow/status/garretpatten/server-setup-scripts/quality-checks.yaml?branch=master&label=quality&logo=github&style=flat-square" alt="Quality checks workflow status"
    /></a>
    <a href="https://github.com/garretpatten/server-setup-scripts/actions/workflows/security-checks.yaml"
        ><img src="https://img.shields.io/github/actions/workflow/status/garretpatten/server-setup-scripts/security-checks.yaml?branch=master&label=security&logo=github&style=flat-square" alt="Security checks workflow status"
    /></a>
</p>

<p align="center">
    ✓ Modular orchestration &nbsp;
    ✓ Split install/config bundles &nbsp;
    ✓ Linted Bash + docs in PR &nbsp;
    ✓ Idempotent, rerunnable phases
</p>

<!-- markdownlint-enable MD033 MD041 -->

---

## Overview

Server Setup Scripts automate a **baseline headless engineering stack**: security CLI tooling, shells and terminal configs, development runtimes (Node, Docker, Neovim, and peers), and a pinned **dotfiles** submodule for editor and tmux parity across machines. Scripts are tuned for clarity in reviews and predictable behavior in **`ubuntu-latest`** CI, **cloud VMs**, and **WSL2**.

This repository is the CLI-only sibling of [ubuntu-setup-scripts](https://github.com/garretpatten/ubuntu-setup-scripts). Desktop applications (browsers, office suites, Flatpak GUI apps, GNOME VPN clients, and similar) live there—not here.

## ✨ Features

- **🔧 Automated Setup**: Complete system configuration with a single command
- **🛡️ Security First**: Built-in security tools, firewall configuration, and safe installation practices
- **⚡ Optimized Performance**: Batch installations and smart caching for faster execution
- **🔄 Idempotent**: Safe to run multiple times without issues
- **📝 Comprehensive Logging**: Detailed progress tracking and error reporting
- **🎯 Modular Design**: Run individual components or orchestrators (`master.sh`)
- **⚙️ Install vs configuration**: Category automation is split between
  `src/scripts/install/` (APT, third-party installers, clones) and
  `src/scripts/config/` (system defaults, home layout, UFW policy, submodule
  dotfiles, default shell). Use `npm run installs`, `npm run config`, or `npm run all`,
  or invoke `run-install.sh` / `run-config.sh` directly.

## 🚀 Quick Start

### Prerequisites

- Ubuntu 20.04+ or Ubuntu-based distribution (including WSL2)
- Internet connection
- Sudo privileges

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/garretpatten/server-setup-scripts
cd server-setup-scripts
```

1. **Install Node deps** (optional; enables `npm run` shortcuts below)

```bash
npm install
```

1. **Update submodules** (for dotfiles)

```bash
git submodule update --init --remote --recursive src/dotfiles/
```

1. **Make scripts executable**

```bash
chmod +x src/scripts/*.sh \
  src/scripts/install/*.sh \
  src/scripts/config/*.sh
```

1. **Run the complete setup**

```bash
npm run all
# or:
./src/scripts/master.sh
```

### npm scripts

| Command            | Runs                                                                                                       |
| ------------------ | ---------------------------------------------------------------------------------------------------------- |
| `npm run all`      | Full provisioning (`master.sh`): installs interleaved with configuration (see execution flow below).       |
| `npm run installs` | Install bundle only (`run-install.sh`): packages and installers—no dotfiles/config steps.                  |
| `npm run config`   | Configuration bundle only (`run-config.sh`): defaults, home layout, UFW defaults, submodule copies, shell. |

Bash equivalents:

```bash
bash src/scripts/run-install.sh
bash src/scripts/run-config.sh
bash src/scripts/master.sh
```

Use **`npm run config`** when packages are already present but dotfiles paths should be refreshed after updating the submodule.

### Granular scripts

Each category exists as **install** and/or **configuration** scripts (paths from repo root):

```bash
bash src/scripts/install/cli.sh
bash src/scripts/install/dev.sh

bash src/scripts/config/system-config.sh      # unattended APT + sysctl (no extra packages besides unattended-upgrades)
bash src/scripts/config/organizeHome.sh
bash src/scripts/config/dev.sh               # Editors / XDG subtree + Git identity
bash src/scripts/config/security.sh           # UFW defaults (requires `install/security.sh` first)
bash src/scripts/config/shell.sh              # Submodule shell + terminal dotfiles (`~/.config/tmux`, etc.)
```

Prefer the orchestrators so ordering stays consistent (for example **`config/security.sh`** after **`install/security.sh`**, **`config/shell.sh`** after **`install/shell.sh`**, and **`install/post-install.sh`** docker/UFW touchpoints ahead of **`config/shell.sh`** when running a full provisioning pass).

## Project structure

```text
server-setup-scripts/
├── src/
│   ├── scripts/
│   │   ├── utils.sh
│   │   ├── master.sh          # Full run — interleaved installs + configuration
│   │   ├── run-install.sh      # APT/installers/post-install hooks only
│   │   ├── run-config.sh       # system defaults, home layout, firewall policy, dotfiles, shell
│   │   ├── install/
│   │   │   ├── pre-install.sh
│   │   │   ├── cli.sh
│   │   │   ├── dev.sh         # Languages, Docker, NeoVim APT, tooling (no submodule copies)
│   │   │   ├── security.sh    # CLI security packages, clones (UFW separately)
│   │   │   ├── shell.sh       # Zsh/Tmux/fonts/Oh My Posh (no GUI terminals)
│   │   │   └── post-install.sh
│   │   └── config/
│   │       ├── system-config.sh
│   │       ├── organizeHome.sh
│   │       ├── dev.sh         # submodule `config/*` subsets + Git defaults + Vimrc + VS Code user settings path
│   │       ├── security.sh    # UFW deny/enable + SSH
│   │       └── shell.sh       # tmux/modular ~/.config paths, ~/.dotfiles_path, chsh if needed
│   ├── dotfiles/              # submodule
│   └── assets/
└── ...
```

### Execution flow (`master.sh`)

1. **`install/pre-install.sh`** — essential APT packages, timezone if still UTC
2. **`config/system-config.sh`** — unattended upgrades, apport/sysctl; GNOME defaults only when a desktop session exists
3. **`config/organizeHome.sh`** — home folders and permissions
4. **`install/cli.sh`** — **`btop`** (APT on 22.04+ or **`snap`** on older releases), **`fastfetch`** (PPA), other CLI APT packages
5. **`install/dev.sh`** — NodeSource Node, NVM, Docker CE, NeoVim PPA, `semgrep`, `src` CLI
6. **`config/dev.sh`** — copy editor/XDG subsets from **`src/dotfiles/config/`**, Git globals, Vimrc path, VS Code `settings.json` when missing
7. **`install/security.sh`** — UFW/OpenVPN APT, Proton Pass **CLI**, pen-test packages, clones under `~/Hacking`
8. **`config/security.sh`** — **`ufw` defaults** after the package exists
9. **`install/shell.sh`** — Zsh/Tmux/fonts/Oh My Posh installers
10. **`install/post-install.sh`** — `apt-get upgrade`/docker group/banner
11. **`config/shell.sh`** — **`home/`** dotfiles, **`~/.dotfiles_path`**, `chsh` when possible

---

## 📋 What gets installed vs configured

The lists below mirror the **`install/`** and **`config/`** split; open each file for exact commands.

### **`install/` bundle**

#### 🧰 **Bootstrap** (`install/pre-install.sh`)

- APT housekeeping; toolchain packages (`git`, `curl`, `wget`, `gnupg`, etc.).
- Sets timezone away from **`UTC`** toward **`America/New_York`** when still UTC.

#### 🛠️ **CLI Tools** (`install/cli.sh`)

- Essentials: **`bat`**, **`curl`**, **`eza`**, **`fastfetch`** (PPA),
  **`fd-find`**, **`git`**, **`htop`**, **`jq`**, **`ripgrep`**, **`vim`**, **`wget`**.
- **`btop`**: APT on **Ubuntu 22.04+**; on older releases (**e.g. 20.04**), **`snap install btop`**
  when **`snap`** exists.

#### 💻 **Development packages** (`install/dev.sh`)

- Node.js **`nodejs`** via NodeSource (**24.x** branch), NVM install script when missing,
  **`@vue/cli`** globally, **`python3`** toolchain, Docker CE repos + Compose plugin,
  **`neovim`**, **`gh`**, **`shellcheck`**, **`semgrep`** (pip), **`src`** (Sourcegraph).

#### 🔒 **Security packages & payloads** (`install/security.sh`)

- **`ufw`** and **`openvpn`** APT packages (rules live in **`config/security.sh`**).
- Proton Pass **CLI** (`protonpass`), **`nmap`**, **`exiftool`**, **OWASP ZAP** (**snap**).
- Optionally clones **`PayloadsAllTheThings`** / **`SecLists`** into **`~/Hacking`**.

#### 🐚 **Shell tooling** (`install/shell.sh`)

Zsh plugins, **`tmux`**, Meslo/Fira/powerline APT fonts plus optional Nerd Font drop,
user Oh My Posh binary + theme stash under **`/usr/share/oh-my-posh/themes`** when empty.

#### 🏁 **Post maintenance** (`install/post-install.sh`)

`apt-get upgrade`, Docker systemd + **`docker`** group enrollment, **`ufw`** best-effort enable, and a completion banner (`src/assets/server.txt`).

### **`config/` bundle**

#### 🏠 **Home layout** (`config/organizeHome.sh`)

- Drops empty **`Music`/`Public`/`Templates`** where applicable.
- Creates **`~/Projects`**, **`~/Hacking`**, **`~/AppImages`**, **`~/Projects/opensource`** / **`personal`**, adjusts **`Scripts`/`Hacking`** permissions.

#### ⚙️ **System defaults** (`config/system-config.sh`)

- **GNOME** (logged-in Desktop / D-Bus only): dark mode, animations, clocks, and related preferences when schemas exist.
- Installs **`unattended-upgrades`** and drops **`20auto-upgrades`** when missing.
- Disables Apport; sysctl TCP keepalive drop-in.

Headless runners and WSL without a desktop session skip **`gsettings`** safely.

#### 💻 **Editor & Git prefs** (`config/dev.sh`)

- Copies a **focused set** from **`src/dotfiles/config/`** into **`~/.config/`**: **`nvim`**, **`btop`**, **`fastfetch`**, **`alacritty`**, **`kitty`**, **`zellij`** (trees skipped when **`~/.config/<app>/`** already exists).
- Copies **`home/.vimrc`** and VS Code **`User/settings.json`** when missing (**`~/.config/Code/User`** on Linux).
- Seeds **`~/.gitconfig`** **only when absent** with global credential helper + identity defaults.

#### 🔒 **UFW posture** (`config/security.sh`)

`ufw reset`, deny incoming / allow outgoing, allow **`ssh`**, force enable (expects **`install/security.sh`** to have installed **`ufw`** first).

#### 🐚 **Shell dotfiles & terminal configs** (`config/shell.sh`)

- Copies **`Ghostty`**, **`oh-my-posh`**, and the **modular `config/tmux/`** subtree into **`~/.config`** (terminal configs for when you connect from a GUI client; Ghostty itself is not installed here).
- Copies **`home/.tmux.conf`**, **`home/.zshrc`**, optional **`home/.bashrc`** when missing.
- Maintains **`~/.dotfiles_path`** so **`home/.zshrc`** resolves **`DOTFILES`**; runs **`chsh`** when possible.

**Full symlink mirror**: from **`src/dotfiles`**, **`./setup.sh --link-xdg-config`** installs every **`config/<app>/`** tree under **`$XDG_CONFIG_HOME`** ([dotfiles README](https://github.com/garretpatten/dotfiles/blob/master/README.md)). Parent **`config/`** scripts still provision the subset above for first-touch machines.

## 🖥️ WSL notes

- Run from your WSL2 Ubuntu distro with **`sudo`** available.
- **Docker**: enable the Docker Desktop WSL integration or install Docker CE via this repo; log out/in or **`newgrp docker`** after the **`docker`** group is applied.
- **UFW**: may be limited under WSL depending on kernel/networking; failures are logged but non-fatal.
- **Default shell**: **`chsh`** may require logging out of Windows Terminal and reopening the WSL session.

## 📊 Monitoring & Logs

After installation, check:

- **Error Log**: `setup_errors.log` - Centralized error tracking
- **Console Output**: Real-time progress with color-coded messages

## ⚠️ Post-Installation Notes

1. **Restart Required**: Log out and back in for shell and group changes
1. **Docker**: User added to docker group (logout required for effect)
1. **Firewall**: UFW enabled with SSH access allowed (on bare-metal/cloud; WSL may vary)
1. **Desktop apps**: For browsers, office suites, media players, and GNOME tooling, use [ubuntu-setup-scripts](https://github.com/garretpatten/ubuntu-setup-scripts)

## 🔍 Troubleshooting

### Common Issues

**Script fails with permission errors:**

```bash
chmod +x src/scripts/*.sh \
  src/scripts/install/*.sh \
  src/scripts/config/*.sh
```

**Package installation fails:**

```bash
sudo apt update
# Then re-run the script
```

**Docker commands require sudo:**

```bash
newgrp docker
```

**Shell doesn't change to Zsh:**

```bash
chsh -s $(which zsh)
# Then log out and back in
```

### Getting Help

- Check `setup_errors.log` for detailed error information
- Ensure you're running on a supported Ubuntu version (20.04+)
- Verify internet connection for package downloads

## 🛡️ Security Features

- **Hash verification** for all downloaded packages
- **GPG key verification** for third-party repositories
- **Automatic firewall configuration** with secure defaults
- **Safe temporary file handling** with automatic cleanup
- **Principle of least privilege** for directory permissions

## Community

| Resource                                | Use                                         |
| --------------------------------------- | ------------------------------------------- |
| [Code of Conduct](./CODE_OF_CONDUCT.md) | Expected behavior in issues and PRs         |
| [Contributing](./CONTRIBUTING.md)       | Branching, checks, submodule notes          |
| [Security policy](./SECURITY.md)        | Vulnerability reporting (not public issues) |

## Maintainers

[@garretpatten](https://github.com/garretpatten/).

Use the [issue templates](./.github/ISSUE_TEMPLATE/) for bugs and enhancements.

## License

This project is licensed under the [MIT License](./LICENSE).
