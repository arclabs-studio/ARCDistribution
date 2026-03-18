---
name: arc-release-notes
description: |
  Draft App Store release notes from git log since last tag or from Linear issues.
  Produces user-facing, concise "What's New" copy. Use when "write release notes",
  "what's new for this version", "draft changelog for App Store",
  or "release notes from git log".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# arc-release-notes — Release Notes Generator

## Instructions

### Step 1: Get changes

**Option A — From git log** (preferred):
```bash
# Since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline --no-merges

# Since specific version
git log v1.2.0..HEAD --oneline --no-merges
```

**Option B — From Linear issues**:
Ask user for Linear issues completed in this sprint. Use `mcp__claude_ai_Linear__list_issues` to fetch Done issues.

### Step 2: Categorize changes

Parse commits by Conventional Commits prefix:
- `feat:` → New Features
- `fix:` → Bug Fixes
- `perf:` → Performance
- `refactor:` → (internal, skip for users)
- `chore:`, `docs:`, `test:` → (skip for users)

### Step 3: Draft user-facing copy

Rules:
- Write for non-technical users
- Present tense, active voice ("You can now...", "Fixed...", "Improved...")
- No commit hashes, branch names, or internal jargon
- Max ~500 chars (App Store release notes field has no strict limit but users don't read long notes)
- Lead with the most impactful change

Template:
```
What's New in [version]:

• [Most impactful user-facing feature or fix]
• [Second change]
• [Third change]

[Optional: "Thank you for your feedback and reviews!"]
```

### Step 4: Write file

Write to: `~/Documents/ARCLabsStudio/Distribution/<AppName>/metadata/en-US/release_notes.txt`

### Step 5: Output

```
## Release Notes — [AppName] v[version]

[Generated release notes]

Character count: XX chars

Based on XX commits since [last_tag]
```

If running arc-metadata-localize, also generate localized release notes for existing locales.
