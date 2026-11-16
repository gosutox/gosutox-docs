#!/usr/bin/env bash
# ========================================================================================
# Gosuto X Environment Forwarder (SSOT Delegation)
# File: gosutox-docs/scripts/setup-local-env.sh
# ========================================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENTERPRISE_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
MASTER_SCRIPT="${ENTERPRISE_ROOT}/gosutox-account/scripts/setup-gosutox-environment.sh"

if [ -f "$MASTER_SCRIPT" ]; then
    exec "$MASTER_SCRIPT" "$@"
else
    echo "[ERROR] Gosuto X Master Environment script not found at $MASTER_SCRIPT" >&2
    exit 1
fi
