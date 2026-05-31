#!/bin/bash

# CLI security tooling only — no desktop VPN clients, Signal, or Proton Pass GUI.

# shellcheck source=../utils.sh
source "$(dirname "$0")/../utils.sh"

update_apt_cache

defense_tools=(
    "ufw"
    "openvpn"
)
install_apt_packages "${defense_tools[@]}"

proton_pass_cli="$TEMP_DIR/proton-pass-cli"
proton_pass_cli_url=$(curl -s https://api.github.com/repos/protonpass/cli/releases/latest 2>>"$ERROR_LOG_FILE" | grep "browser_download_url.*linux-amd64" | cut -d '"' -f 4)
if [[ -n "$proton_pass_cli_url" ]]; then
    download_file_safe "$proton_pass_cli_url" "$proton_pass_cli"
    if [[ -f "$proton_pass_cli" ]] && [[ -s "$proton_pass_cli" ]]; then
        chmod +x "$proton_pass_cli" 2>>"$ERROR_LOG_FILE" || true
        sudo mv "$proton_pass_cli" /usr/local/bin/protonpass 2>>"$ERROR_LOG_FILE" || true
    fi
fi

apt_security_tools=(
    "nmap"
    "exiftool"
)
install_apt_packages "${apt_security_tools[@]}"

if command -v snap >/dev/null 2>&1; then
    sudo snap install zaproxy --classic 2>>"$ERROR_LOG_FILE" || true
fi

ensure_directory "$HOME/Hacking"

if [[ ! -d "$HOME/Hacking/PayloadsAllTheThings" ]]; then
    clone_repository_safe "https://github.com/swisskyrepo/PayloadsAllTheThings" "$HOME/Hacking/PayloadsAllTheThings"
fi

if [[ ! -d "$HOME/Hacking/SecLists" ]]; then
    clone_repository_safe "https://github.com/danielmiessler/SecLists" "$HOME/Hacking/SecLists"
fi
