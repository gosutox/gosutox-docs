# GōsutoX Docs Governance & Engineering Discipline Standards

```
========================================================================================
   GOSUTOX DOCS CENTER CONSTITUTION: WORLD-CLASS ENTERPRISE DOCS-AS-CODE (V30.0)
========================================================================================
```

---

## SECTION I. AXON CONSTITUTION & HITL SYMBIOTIC PHILOSOPHY

### Article 1. Human-AI Symbiotic Complementarity & Non-Omniscient AI Reality
1. **Docs as Platform Face & Knowledge SSOT**: The official documentation center (`docs.gosutox.com`) is the primary public and enterprise gateway to the GosutoX and AXON platform ecosystem.
2. **Clear Boundary Recognition**: Documentation must reflect deterministic, verified facts of live platform APIs, SDKs, architecture, and billing tiers. Speculative documentation or guessing unreleased features is strictly forbidden.

### Article 2. Semantic Kernel Division of Labor (Semantic vs. Native Triad Architecture)
1. **Semantic Domain (AI)**: Synthesizing architecture guides, polishing multilingual explanations, verifying cross-module documentation consistency, and diagnosing broken links.
2. **Native Domain (HI)**: Product roadmaps, pricing models, legal terms, security disclosures, and production release approvals.
3. **Ambiguity Resolution via Agile HITL**: If an API contract, token limit, or pricing tier is ambiguous, the agent MUST NEVER invent details. It halts, verifies against backend source code (`gosutox-accounts`, `gosutox-axon-backend`), and confirms with human leadership.

### Article 3. The Five Habits of Frontier Development (AWS 10x Paradigm)
1. **Habit 1: Invest in Context & Continuous Pruning**: Maintain explicit page groupings, tab definitions, and changelog records. Prune obsolete documentation immediately upon API refactoring.
2. **Habit 2: Slow Down to Speed Up (Docs Hygiene)**: Enforce clean MDX formatting, valid frontmatter, correct tab nesting in `docs.json`, and zero broken anchor links.
3. **Habit 3: Feed Agents, Don't Babysit**: Provide deterministic audit scripts (`./scripts/pre-release-check.sh`) and local previews (`mintlify dev`).
4. **Habit 4: Spec-First / Intent Explicit**: Fix page outline, component props, and user journeys *before* writing multi-page guides.
5. **Habit 5: Shift Testing Left & Local Link Verification**: Verify all internal page references, code snippets, and callouts locally prior to release PR generation.

---

## SECTION II. CORE ENGINEERING DISCIPLINE & ZERO-SPECULATIVE PROTOCOL

### Article 4. Git Command Safety Rules
1. **Zero Destructive Commands**: Agents MUST NOT execute destructive commands such as `git reset --hard`, branch renaming (`git branch -m`), or destructive `git checkout` without explicit prior user authorization.
2. **Mandatory State Audit**: When state changes or branch checkouts are required, clearly explain the current state (`git diff`), risks, and obtain explicit individual approval.

### Article 5. Mandatory 4-Step Zero-Shortcut Engineering Discipline
- **Step 1: Exhaustive Investigation & Fact Analysis**: Inspect source backend/frontend code to guarantee documentation accuracy.
- **Step 2: Proposal & Consent (Spec-First)**: Present proposed doc structure and navigation diffs to the user.
- **Step 3: Verification & Validation (Shift-Left)**: Execute `./scripts/pre-release-check.sh` to confirm 100% link integrity and schema compliance.
- **Step 4: Approved Commit & PR Generation**: Execute `./scripts/git-release.sh` to create automated GitHub Pull Requests for human review.

---

## SECTION III. MINTLIFY DOCS ARCHITECTURE & NAVIGATION SSOT

### Article 6. Navigation Authority (`docs.json` / `mint.json`)
1. **Navigation SSOT**: `docs.json` (Mintlify v2) and `mint.json` (Mintlify v1) define the canonical navigation taxonomy across all tabs:
   - `Get Started` (`get-started/`)
   - `AXON Core` (`talk/`, `symposium/`, `studio/`, `coworx/`, `data/`)
   - `Agents & Brains` (`agent/`, `brains/`)
   - `Trust & Security` (`trust/`)
   - `Changelog & Notes` (`changelog/`)
2. **Zero Orphaned Pages & Zero Broken Links**: Every `.mdx` or `.md` file in the repository MUST be referenced in the navigation schema, and every path in `docs.json` MUST exist in the filesystem.

### Article 7. Style System & Visual Parity (`style.css`)
1. **Navy Mirage Theme Parity**: Custom CSS tokens in `style.css` MUST adhere to the GosutoX Design System:
   - Primary Accent: Steel Blue `#496796` (Light) / Icy Sky Blue `#8fb3f5` (Dark)
   - Backgrounds, callout cards, code fences, and navigation pills must maintain crisp, premium dual-theme ergonomics with zero visual clipping.

---

## SECTION IV. DEPLOYMENT & RELEASE GITOPS GOVERNANCE

### Article 8. SSOT Version Authority & PR-Driven Delivery
1. **SSOT Version Authority**: Root `VERSION` file is the Single Source of Truth for documentation releases.
2. **Automated Pre-Release Audit**: Every release MUST execute `./scripts/pre-release-check.sh` prior to PR generation.
3. **Automated Release Script**: Deployments MUST use `./scripts/git-release.sh "<commit_message>"`.
4. **Branch Lifecycle & Main Merge Discipline**:
   - Work on dedicated release branch (`gosutox-docs-v{VERSION}`).
   - The release script stages, commits, tags, and pushes to `origin gosutox-docs-v{VERSION}`.
   - The release script automatically creates a GitHub Pull Request against `main`.
   - **Zero Direct Push to `main`**: Production deployment is triggered ONLY when the Pull Request is reviewed and merged into `main` by an authorized human.
5. **Clickable PR Link Obligation**:
   - Immediately upon PR creation, the AI Agent MUST output the interactive, clickable PR Approval Link (`https://github.com/gosutox/gosutox-docs/pull/{PR_NUMBER}`) directly in chat for deterministic human review.
