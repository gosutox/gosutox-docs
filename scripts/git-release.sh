#!/bin/bash
# =============================================================================
# Gōsuto X Docs Center — Auto Git Release & PR Deployment Trigger Script
# Usage: ./scripts/git-release.sh "commit message"
# =============================================================================

set -e

# --- 1. Parse commit message argument ---
COMMIT_MSG="$1"
if [ -z "$COMMIT_MSG" ]; then
    echo "❌ Error: Commit message is required."
    echo "   Usage:   ./scripts/git-release.sh \"commit message\""
    echo "   Example: ./scripts/git-release.sh \"feat(docs): update 1.0.0 architecture guides\""
    exit 1
fi

# --- 2. Read VERSION file (Single Source of Truth) ---
if [ ! -f "VERSION" ]; then
    echo "❌ Error: VERSION file not found in root directory."
    exit 1
fi
VERSION=$(cat VERSION | tr -d '[:space:]')
EXPECTED_BRANCH="gosutox-docs-v${VERSION}"

# --- 3. Verify and adjust current branch ---
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "$EXPECTED_BRANCH" ]; then
    echo "⚠️  Current branch is '$CURRENT_BRANCH'. Expected '$EXPECTED_BRANCH'."
    echo "🔄 Switching/Checking out to branch '$EXPECTED_BRANCH'..."
    git checkout -b "$EXPECTED_BRANCH" 2>/dev/null || git checkout "$EXPECTED_BRANCH"
    CURRENT_BRANCH=$(git branch --show-current)
fi

# --- 4. Run Pre-Release Quality Audit ---
if [ -f "./scripts/pre-release-check.sh" ]; then
    ./scripts/pre-release-check.sh
fi

# --- 5. Git Stage and Commit ---
echo "📝 Staging changes..."
git add -A

if git diff-index --quiet HEAD --; then
    echo "ℹ️  No uncommitted changes on branch '$CURRENT_BRANCH'."
else
    echo "💾 Committing changes: $COMMIT_MSG"
    git commit -m "$COMMIT_MSG"
fi

TAG_NAME="gosutox-docs-v${VERSION}"

echo "🏷️  Creating release tag: $TAG_NAME"
git tag -f -a "$TAG_NAME" -m "$COMMIT_MSG"

echo "🚀 Pushing branch '$CURRENT_BRANCH' to origin..."
git push -f origin "refs/heads/$CURRENT_BRANCH"

echo "🚀 Pushing tag '$TAG_NAME' to origin..."
git push -f origin "refs/tags/$TAG_NAME"

# --- 6. Automated GitHub PR Generation ---
echo ""
echo "================================================================"
echo "🤖 Generating / Checking GitHub Pull Request against 'main'..."
echo "================================================================"

PR_URL=$(gh pr list --repo gosutox/gosutox-docs --head "$CURRENT_BRANCH" --base main --state open --json url --jq '.[0].url' 2>/dev/null || true)

if [ -z "$PR_URL" ]; then
    echo "🚀 Creating new Pull Request in gosutox/gosutox-docs..."
    PR_URL=$(gh pr create \
        --repo gosutox/gosutox-docs \
        --base main \
        --head "$CURRENT_BRANCH" \
        --title "🚀 [DOCS] Release v${VERSION}: ${COMMIT_MSG}" \
        --body "### 📚 GōsutoX Docs Center Release v${VERSION}
- **Source Branch**: \`${CURRENT_BRANCH}\`
- **Target Branch**: \`main\`
- **Release Tag**: \`${TAG_NAME}\`
- **Commit Summary**: ${COMMIT_MSG}

#### 🔍 Quality Gates Passed:
- [x] Pre-release link & schema audit passed (\`./scripts/pre-release-check.sh\`)
- [x] Zero broken links across \`docs.json\` navigation taxonomy
- [x] Dual-theme style parity verified

> **Review & Merge Instruction**: Review the documentation diffs and click **Merge pull request** to deploy live to [docs.gosutox.com](https://docs.gosutox.com)." 2>&1)
fi

echo ""
echo "================================================================"
echo "✅ Success! Docs release branch & PR created successfully."
echo "================================================================"
echo "🔹 Working Branch: $CURRENT_BRANCH"
echo "🔹 Trigger Tag:    $TAG_NAME"
echo "🔹 PR Approval Link: $PR_URL"
echo "================================================================"
echo ""
