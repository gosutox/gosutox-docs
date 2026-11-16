#!/usr/bin/env bash
# ========================================================================================
# GOSUTOX DOCS: AUTOMATED PRE-CHECK, PUSH & OPTION A PR GATE SCRIPT (V1.0.0)
# Usage: ./scripts/git-release.sh "<commit_message>" [push|pr]
# ========================================================================================

set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

export GH_CONFIG_DIR="${GH_CONFIG_DIR:-${HOME}/.config/gh-gosutox}"
export GIT_SSH_COMMAND="${GIT_SSH_COMMAND:-ssh -i ${HOME}/.ssh/id_ed25519_gosutox -o IdentitiesOnly=yes}"

COMMIT_MSG="${1:-}"
MODE="${2:-pr}"

if [ -z "$COMMIT_MSG" ]; then
    echo "Usage: ./scripts/git-release.sh \"<commit_message>\" [push|pr]"
    exit 1
fi

if [[ "$MODE" != "push" && "$MODE" != "pr" ]]; then
    echo "❌ Error: Invalid mode '$MODE'. Supported modes: push | pr"
    exit 1
fi

if [ ! -f "VERSION" ]; then
    echo "❌ Error: VERSION file not found in repository root."
    exit 1
fi
VERSION=$(tr -d '[:space:]' < VERSION)
EXPECTED_BRANCH="gosutox-docs-v${VERSION}"
DEV_FEATURE_BRANCH="${EXPECTED_BRANCH}-launching-readiness-and-optimization-dev"
PROD_FEATURE_BRANCH="${EXPECTED_BRANCH}-launching-readiness-and-optimization-prod"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "prod" ]]; then
    echo "❌ CRITICAL SECURITY VIOLATION: Direct push/release from '${CURRENT_BRANCH}' is FORBIDDEN."
    echo "   Work on '${EXPECTED_BRANCH}', '${DEV_FEATURE_BRANCH}', or '${PROD_FEATURE_BRANCH}' and open a PR."
    exit 1
fi

if [[ "$CURRENT_BRANCH" != "$EXPECTED_BRANCH" && "$CURRENT_BRANCH" != "$DEV_FEATURE_BRANCH" && "$CURRENT_BRANCH" != "$PROD_FEATURE_BRANCH" ]]; then
    echo "❌ Error: Branch '${CURRENT_BRANCH}' does not match v${VERSION} Option A branch governance."
    echo "   Allowed: ${EXPECTED_BRANCH} | ${DEV_FEATURE_BRANCH} | ${PROD_FEATURE_BRANCH}"
    exit 1
fi

if [[ "$MODE" == "pr" && "$CURRENT_BRANCH" == "$DEV_FEATURE_BRANCH" ]]; then
    TARGET_BASE="$EXPECTED_BRANCH"
else
    TARGET_BASE="main"
fi

echo "🔍 Running Pre-Release Hygiene & Public Sanitization Check..."
./scripts/pre-release-check.sh

echo "🛡️ Checking active GitHub identity..."
ACTIVE_LOGIN=$(gh api user -q .login 2>/dev/null || echo "")
if [ -n "$ACTIVE_LOGIN" ]; then
    echo "   ✅ GitHub CLI authenticated as: ${ACTIVE_LOGIN}"
else
    echo "❌ Error: GitHub CLI not authenticated under GH_CONFIG_DIR=${GH_CONFIG_DIR}"
    exit 1
fi

# Prevent .agents from ever being staged in public docs repo
if [ -d ".agents" ] && git ls-files --error-unmatch .agents >/dev/null 2>&1; then
    echo "🧹 Removing .agents/ from Git index (Public Repo Exclusion Rule)..."
    git rm -r --cached .agents >/dev/null
fi

FINAL_COMMIT_MSG="$COMMIT_MSG"
if [[ "$MODE" == "push" && "$FINAL_COMMIT_MSG" != *"[skip ci]"* ]]; then
    FINAL_COMMIT_MSG="${FINAL_COMMIT_MSG} [skip ci]"
fi

echo "📝 Staging changes..."
git add -A

if git diff --staged --quiet; then
    echo "ℹ️  No staged changes to commit. Proceeding to push/PR synchronization..."
else
    echo "💾 Committing changes: ${FINAL_COMMIT_MSG}"
    git commit -m "$FINAL_COMMIT_MSG"
fi

echo "🚀 Pushing '${CURRENT_BRANCH}' to origin (unambiguous refs/heads/)..."
git push -u origin "refs/heads/${CURRENT_BRANCH}:refs/heads/${CURRENT_BRANCH}"

if [ "$MODE" = "push" ]; then
    echo "================================================================"
    echo "✅ DOCS BRANCH PUSHED CLEANLY: ${CURRENT_BRANCH}"
    echo "================================================================"
    exit 0
fi

echo "🔍 Checking Pull Request status for '${CURRENT_BRANCH}' ➔ '${TARGET_BASE}'..."
EXISTING_PR_URL=$(gh pr list --head "${CURRENT_BRANCH}" --base "${TARGET_BASE}" --state open --json url --jq '.[0].url // empty')

if [ -n "$EXISTING_PR_URL" ]; then
    PR_URL="$EXISTING_PR_URL"
    echo "🔄 Existing Tracking PR updated cleanly!"
else
    PR_TITLE="docs(v${VERSION}): ${COMMIT_MSG}"
    PR_BODY=$(cat <<EOF
## Gosuto X Public Docs Release Gate (v${VERSION})

- **Source Branch**: \`${CURRENT_BRANCH}\`
- **Target Branch**: \`${TARGET_BASE}\`
- **SSOT Version**: \`v${VERSION}\`
- **Public Hygiene**: \`.agents/\` excluded from Git index; internal GCP/IP tokens verified clean via \`./scripts/pre-release-check.sh\`.

### Approval Checklist
- [x] \`./scripts/pre-release-check.sh\` passed
- [ ] Human review & PR merge approval into \`${TARGET_BASE}\`
EOF
)
    PR_URL=$(gh pr create --base "${TARGET_BASE}" --head "${CURRENT_BRANCH}" --title "${PR_TITLE}" --body "${PR_BODY}")
fi

echo "================================================================"
echo "🎉 DOCS PR READY!"
echo "================================================================"
echo "🔹 Source Branch:    ${CURRENT_BRANCH}"
echo "🔹 Target Branch:    ${TARGET_BASE}"
echo "🔹 SSOT Version:     v${VERSION}"
echo "🔗 PR Approval Link: ${PR_URL}"
echo "================================================================"
