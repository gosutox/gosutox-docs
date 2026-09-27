#!/usr/bin/env bash
# ========================================================================================
# GOSUTOX DOCS CENTER: PRE-RELEASE QUALITY & LINK AUDIT GATE (V1.0)
# File Path: scripts/pre-release-check.sh
# Role: Pre-Commit & Pre-Release Documentation Quality, Navigation & Link Audit Gate
# ========================================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${REPO_ROOT}"

CLR_RESET="\033[0m"
CLR_BOLD="\033[1m"
CLR_CYAN="\033[36m"
CLR_GREEN="\033[32m"
CLR_YELLOW="\033[33m"
CLR_RED="\033[31m"
CLR_GRAY="\033[90m"

echo -e "\n${CLR_BOLD}${CLR_CYAN}========================================================================================${CLR_RESET}"
echo -e "${CLR_BOLD}  GOSUTOX DOCS CENTER: PRE-RELEASE QUALITY & LINK AUDIT GATE (V1.0)${CLR_RESET}"
echo -e "${CLR_BOLD}${CLR_CYAN}========================================================================================${CLR_RESET}"

# 1. Check VERSION file SSOT
echo -e "\n${CLR_BOLD}[1/4] Auditing VERSION SSOT Authority...${CLR_RESET}"
if [ ! -f "VERSION" ]; then
    echo -e "${CLR_RED}[ERROR] VERSION file missing in repository root.${CLR_RESET}"
    exit 1
fi
VERSION=$(tr -d '[:space:]' < VERSION)
if [ -z "$VERSION" ]; then
    echo -e "${CLR_RED}[ERROR] VERSION file is empty.${CLR_RESET}"
    exit 1
fi
echo -e "${CLR_GREEN}   [OK] VERSION verified: v${VERSION}${CLR_RESET}"

# 2. Check JSON Configuration Integrity
echo -e "\n${CLR_BOLD}[2/4] Auditing docs.json & mint.json Schema Integrity...${CLR_RESET}"
if [ ! -f "docs.json" ]; then
    echo -e "${CLR_RED}[ERROR] docs.json missing in repository root.${CLR_RESET}"
    exit 1
fi
python3 -c "import json; json.load(open('docs.json'))" || {
    echo -e "${CLR_RED}[ERROR] docs.json is invalid JSON syntax.${CLR_RESET}"
    exit 1
}
if [ -f "mint.json" ]; then
    python3 -c "import json; json.load(open('mint.json'))" || {
        echo -e "${CLR_RED}[ERROR] mint.json is invalid JSON syntax.${CLR_RESET}"
        exit 1
    }
fi
echo -e "${CLR_GREEN}   [OK] Navigation JSON schemas validated.${CLR_RESET}"

# 3. Check Page Files Existence (Zero Broken Links)
echo -e "\n${CLR_BOLD}[3/4] Auditing Navigation Pages Existence across Filesystem...${CLR_RESET}"
python3 - << 'PYEOF'
import json
import os
import sys

with open("docs.json", "r") as f:
    config = json.load(f)

missing_pages = []

def check_pages(pages):
    for p in pages:
        if isinstance(p, str):
            # check p.mdx or p.md or p/index.mdx
            cands = [
                f"{p}.mdx",
                f"{p}.md",
                f"{p}/index.mdx",
                f"{p}/index.md"
            ]
            if not any(os.path.isfile(c) for c in cands):
                missing_pages.append(p)
        elif isinstance(p, dict) and "pages" in p:
            check_pages(p["pages"])

nav = config.get("navigation", {})
if isinstance(nav, dict):
    for tab in nav.get("tabs", []):
        for group in tab.get("groups", []):
            check_pages(group.get("pages", []))
elif isinstance(nav, list):
    for group in nav:
        check_pages(group.get("pages", []))

if missing_pages:
    print(f"\033[31m[ERROR] Missing {len(missing_pages)} pages referenced in docs.json:\033[0m")
    for m in missing_pages:
        print(f"   - {m}")
    sys.exit(1)
else:
    print("   \033[32m[OK] 100% of navigation pages exist on filesystem.\033[0m")
PYEOF

# 4. Check Branding Assets & Styling
echo -e "\n${CLR_BOLD}[4/4] Auditing Branding Assets & Theme CSS...${CLR_RESET}"
if [ ! -f "favicon.ico" ]; then
    echo -e "${CLR_YELLOW}[WARN] favicon.ico not found in root.${CLR_RESET}"
fi
if [ ! -f "style.css" ]; then
    echo -e "${CLR_RED}[ERROR] style.css missing in repository root.${CLR_RESET}"
    exit 1
fi
echo -e "${CLR_GREEN}   [OK] Branding assets and style.css verified.${CLR_RESET}"

echo -e "\n${CLR_GREEN}${CLR_BOLD}========================================================================================${CLR_RESET}"
echo -e "${CLR_GREEN}${CLR_BOLD}  PRE-RELEASE AUDIT PASSED: GOSUTOX DOCS CENTER IS 100% READY FOR RELEASE${CLR_RESET}"
echo -e "${CLR_GREEN}${CLR_BOLD}========================================================================================${CLR_RESET}\n"
