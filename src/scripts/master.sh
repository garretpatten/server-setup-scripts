#!/bin/bash

# Full provisioning: interleaved installs and configuration for headless/CLI Linux
# (servers, cloud VMs, WSL). No desktop applications or GUI package managers.

# shellcheck source=utils.sh
source "$(dirname "$0")/utils.sh"

ROOT="$(dirname "$0")"
IDIR="$ROOT/install"
CDIR="$ROOT/config"

run() {
    bash "$1" 2>>"$ERROR_LOG_FILE" || log_error "Failed to execute $1"
}

run "$IDIR/pre-install.sh"

run "$CDIR/system-config.sh"
run "$CDIR/organizeHome.sh"

run "$IDIR/cli.sh"

run "$IDIR/dev.sh"
run "$CDIR/dev.sh"

run "$IDIR/security.sh"
run "$CDIR/security.sh"

run "$IDIR/shell.sh"

run "$IDIR/post-install.sh"

run "$CDIR/shell.sh"
