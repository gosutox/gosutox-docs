#!/usr/bin/env bash
# ========================================================================================
# Gosuto X Environment Forwarder (SSOT Delegation)
# File: gosutox-docs/scripts/setup-local-env.sh
# ========================================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MASTER_SCRIPT="/Users/cbcgceo/nexus-ecosystem/02-gosuto-x-enterprise/gosutox-accounts/scripts/setup-gosutox-environment.sh"

if [ -f "$MASTER_SCRIPT" ]; then
    exec "$MASTER_SCRIPT" "$@"
else
    echo "[ERROR] Gosuto X Master Environment script not found at $MASTER_SCRIPT" >&2
    exit 1
fi
