# Agent guide — server-setup-scripts

Bash automation for headless Ubuntu (20.04+) Linux: cloud VMs, servers, and WSL2.
Modular install scripts, shared helpers, and a `src/dotfiles` git submodule.
Changes should stay **idempotent**, **safe to re-run**, and compatible with **headless CI**
(no GNOME session required).

This is the CLI-only sibling of [ubuntu-setup-scripts](https://github.com/garretpatten/ubuntu-setup-scripts).
Do **not** add desktop GUI applications here—keep those in ubuntu-setup-scripts.

## Repository layout

| Path                   | Purpose                                                                                                               |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------- |
| `src/scripts/`         | `utils.sh`, `master.sh`, `run-install.sh`, `run-config.sh`                                                            |
| `src/scripts/install/` | APT, third-party installers, repo clones (no `gsettings`/dotfiles)                                                    |
| `src/scripts/config/`  | system defaults, home layout, UFW policy after packages, targeted dotfile copies into `~`, `~/.dotfiles_path`, `chsh` |
| `src/scripts/utils.sh` | Helpers, `SCRIPTS_DIR`, paths, logging, safe copy/download                                                            |
| `src/dotfiles/`        | Submodule — [garretpatten/dotfiles](https://github.com/garretpatten/dotfiles)                                         |
| `src/assets/`          | Completion banner ASCII (`server.txt`)                                                                                |
| `.github/workflows/`   | CI: `master.sh` + quality workflows                                                                                   |

### Orchestration

- **`master.sh`**: `install/pre-install.sh` → `config/system-config.sh` → `config/organizeHome.sh`
  → `install/cli.sh` → `install/dev.sh` → `config/dev.sh`
  → `install/security.sh` → `config/security.sh` → `install/shell.sh` → `install/post-install.sh`
  → `config/shell.sh`.
- **`run-install.sh`**: `install/` only (`$SCRIPTS_DIR/install`).
- **`run-config.sh`**: `config/` only (`$SCRIPTS_DIR/config`).
- **`npm run all`** / **`npm run installs`** / **`npm run config`** delegate to those scripts (**`npm install`** at repo root first).

### Scope vs ubuntu-setup-scripts

| Included here (CLI)                         | Excluded (desktop — ubuntu-setup-scripts)             |
| ------------------------------------------- | ----------------------------------------------------- |
| APT CLI tools, dev runtimes, Docker, Neovim | Flatpak, Brave/VLC/Spotify, office suites             |
| UFW, openvpn, nmap, ZAP, SecLists clones    | Proton VPN desktop, Signal desktop, Proton Pass GUI   |
| Zsh, tmux, Oh My Posh, fonts                | Ghostty installer, Redshift, Flameshot, KeePassXC GUI |
| Dotfile configs (nvim, tmux, alacritty, …)  | GNOME-heavy `system-config` (gdm, lid switch)         |

## Script conventions

Scripts in **`install/`** and **`config/`**:

1. `#!/bin/bash`, then `# shellcheck source=../utils.sh` and `source "$(dirname "$0")/../utils.sh"`.
2. Scripts next to **`utils.sh`** use `# shellcheck source=utils.sh` and `source "$(dirname "$0")/utils.sh"`.

3. Prefer helpers from **`utils.sh`** (`install_apt_packages`, `copy_directory_safe`,
   `download_file_safe`, `gsettings_ok`, …).

4. Non-fatal style where the rest of the repo does: `|| true`, `2>>"$ERROR_LOG_FILE"`, **`log_error`**
   from orchestrators only for stage failures.

5. **Headless-safe**: **`gsettings`** only behind **`gsettings_ok`**;
   **`config/security.sh`** exits quietly if **`ufw`** is not installed (**`npm run config`**
   alone on a minimal box).

Paths:

- **`PROJECT_ROOT`** is the repo root (two levels above **`src/scripts/`**).
- Dotfiles checkout: **`$PROJECT_ROOT/src/dotfiles`**. **`config/dev.sh`** and **`config/shell.sh`**
  copy selective **`config/<app>/`** trees (parity with **`ubuntu-setup-scripts`** / **`macOS-setup-scripts`**).
  **`home/.tmux.conf`** in the submodule expects **`config/tmux/`** under **`~/.config`**; see **`src/dotfiles/README.md`**.
  For every app: **`(cd src/dotfiles && ./setup.sh --link-xdg-config)`**.

**Submodule workflow**: **`git submodule update --init --recursive src/dotfiles/`**. Content edits
belong upstream in **dotfiles**; bump copies here when a new subtree is mandatory for provisioning.

## Product and safety constraints

- **Security**: Verified downloads/keyrings, **`download_file_safe`**, least-privilege dirs, **`config/security.sh`** **`ufw`** defaults.
- **User impact**: Logout/login for **`docker`** group / default shell; WSL may need a full terminal restart for **`chsh`**.
- **WSL**: UFW and **`systemctl`** behavior may differ from bare-metal Ubuntu; keep failures non-fatal where ubuntu-setup-scripts does.
- No secrets or machine-local paths committed.

## Testing and CI

- **Test Runner**: `chmod +x` **`src/scripts/*.sh`**, **`install/*.sh`**, **`config/*.sh`**, then **`bash src/scripts/master.sh`**
  on **`ubuntu-latest`** with tolerated failures; **`setup_errors.log`** must pass the workflow filter.

## Making changes

| Task                           | Edit                                                                                              |
| ------------------------------ | ------------------------------------------------------------------------------------------------- |
| Packages/installers/clones     | Matching **`install/*.sh`**                                                                       |
| System/apt/session/user layout | **`config/system-config.sh`**, **`organizeHome.sh`**, **`install/pre-install.sh`** as appropriate |
| Firewall                       | `config/security.sh` (policy) plus `install/security.sh` (install `ufw` first)                    |
| Dotfile deploy                 | **`config/dev.sh`** / **`config/shell.sh`**                                                       |
| Shared logic                   | **`utils.sh`**                                                                                    |

## Commits and PRs

Do not commit unless asked. PRs that touch **`gsettings`**: note manual Ubuntu Desktop QA if applicable.

## Verify before you finish

Run the checks that match what you changed—**all of the following** still need to pass before work is done:

```bash
npm install

npx prettier --check .
shellcheck src/scripts/utils.sh \
  src/scripts/master.sh \
  src/scripts/run-install.sh \
  src/scripts/run-config.sh \
  src/scripts/install/*.sh \
  src/scripts/config/*.sh
npx markdownlint-cli2 "**/*.md" "#node_modules" "#src/dotfiles/node_modules"
yamllint .github .yamllint .markdownlint.yaml
```

| If you edited                                                                                     | Run (in addition to **`prettier`** / **`shellcheck`** when applicable)               |
| ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| Any **`*.md`** at repo root (not submodule)                                                       | **`markdownlint-cli2`** on those paths or the glob above                             |
| Workflows, **`ISSUE_TEMPLATE`**, **`dependabot.yaml`**, **`.yamllint`**, **`.markdownlint.yaml`** | **`yamllint`** on the same paths, or `yamllint .github .yamllint .markdownlint.yaml` |

Install **`yamllint`** locally if missing (for example `pip install yamllint`). CI’s **Quality Checks** workflow already runs **`yamllint`** on YAML and **`markdownlint`** on Markdown in PRs—local runs should pass before you finalize.

If you change **`src/dotfiles/`**, run the submodule’s tooling as well.

## License

MIT — see [LICENSE](./LICENSE).
