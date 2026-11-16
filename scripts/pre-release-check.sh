#!/usr/bin/env bash
# ========================================================================================
# GOSUTOX DOCS CENTER: PRE-RELEASE QUALITY, LINK & ZERO-TRACE AUDIT GATE (V1.1)
# File Path: scripts/pre-release-check.sh
# Role: Pre-Commit & Pre-Release Documentation Quality, Navigation & Zero-Leak Audit Gate
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
echo -e "${CLR_BOLD}  GOSUTOX DOCS CENTER: PRE-RELEASE QUALITY & ZERO-TRACE AUDIT GATE (V1.1)${CLR_RESET}"
echo -e "${CLR_BOLD}${CLR_CYAN}========================================================================================${CLR_RESET}"

# 1. Check VERSION file SSOT
echo -e "\n${CLR_BOLD}[1/5] Auditing VERSION SSOT Authority...${CLR_RESET}"
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
echo -e "\n${CLR_BOLD}[2/5] Auditing docs.json & mint.json Schema Integrity...${CLR_RESET}"
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
echo -e "\n${CLR_BOLD}[3/5] Auditing Navigation Pages Existence across Filesystem...${CLR_RESET}"
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
echo -e "\n${CLR_BOLD}[4/5] Auditing Branding Assets & Theme CSS...${CLR_RESET}"
if [ ! -f "favicon.ico" ]; then
    echo -e "${CLR_YELLOW}[WARN] favicon.ico not found in root.${CLR_RESET}"
fi
if [ ! -f "style.css" ]; then
    echo -e "${CLR_RED}[ERROR] style.css missing in repository root.${CLR_RESET}"
    exit 1
fi
echo -e "${CLR_GREEN}   [OK] Branding assets and style.css verified.${CLR_RESET}"

# 5. Zero-Trace Sovereignty & Cross-Contamination Scan
echo -e "\n${CLR_BOLD}[5/5] Running Zero-Trace Sovereignty & Cross-Contamination Scan...${CLR_RESET}"
if git ls-files .agents .mkt_strategy | grep -q .; then
    echo -e "${CLR_RED}[ERROR] .agents/ or .mkt_strategy/ must NEVER be tracked in public gosutox-docs!${CLR_RESET}"
    exit 1
fi
FORBIDDEN_RE='([s]ukjoon|[j]ohn[[:space:]_.-]*chung|[정]석준|[c]onnex[[:space:]]*brothers|[c]onnexbrothers|[c]bcgceo|\b[c]bcg\b|[c]bcg[_-]|[_-][c]bcg|[h]ybridsphere|[하]이브리드스피어|[코]넥스|[j]ohn@|[j]ohn-office|[j]ohn-home|[h]s-gke-env|\b[c]onnex\b|[c]onnex[_-]|[_-][c]onnex|gosutox-[a]ccounts)'
LEAKS=$(git ls-files -co --exclude-standard -z | xargs -0 grep -nEIi "$FORBIDDEN_RE" 2>/dev/null || true)
if [ -n "$LEAKS" ]; then
    echo -e "${CLR_RED}[ERROR] Legacy/PII cross-contamination tokens detected:${CLR_RESET}"
    echo "$LEAKS"
    exit 1
fi
echo -e "${CLR_GREEN}   [OK] Zero cross-contamination & zero private-directory leaks verified.${CLR_RESET}"

echo -e "\n${CLR_GREEN}${CLR_BOLD}========================================================================================${CLR_RESET}"
echo -e "${CLR_GREEN}${CLR_BOLD}  PRE-RELEASE AUDIT PASSED: GOSUTOX DOCS CENTER IS 100% READY FOR RELEASE${CLR_RESET}"
echo -e "${CLR_GREEN}${CLR_BOLD}========================================================================================${CLR_RESET}\n"