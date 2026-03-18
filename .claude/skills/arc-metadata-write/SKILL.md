---
name: arc-metadata-write
description: |
  Generate complete, character-validated App Store metadata (name 30, subtitle 30,
  keywords 100, description 4000) from app context. Writes directly to the iCloud
  Distribution folder. Use when "write app store metadata", "generate metadata",
  "write description", "create keywords.txt", or "write subtitle for app".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# arc-metadata-write — App Store Metadata Generator

## Instructions

### Step 1: Gather app context

Ask for (or read from existing metadata files):
- App name, category, and primary purpose
- Top 3 features
- Target audience (age, lifestyle, context of use)
- Tone (professional, friendly, playful)
- Existing keywords to incorporate

### Step 2: Generate name.txt (30 chars max)

Formula: `[Brand] — [Core Value]` or just `[Brand]` if brand is self-explanatory.

Rules:
- Include the most valuable keyword that fits naturally
- Don't append "App", "Pro", or "Free"
- Count characters: must be ≤ 30

### Step 3: Generate subtitle.txt (30 chars max)

Formula: `[Verb] [Object] [Micro-benefit]`

Rules:
- Must not repeat words from name.txt
- Should include 1–2 additional keywords
- Conversational tone, present tense

### Step 4: Generate keywords.txt (100 chars max)

- Comma-separated, no spaces
- No duplicates from name or subtitle
- Use output from arc-aso-keywords if available

### Step 5: Generate description.txt (4000 chars max)

Structure:
```
[Hook — 1 sentence pain point or delight, no brand mention]

[Value proposition — what the app does + main benefit]

KEY FEATURES
• [Feature 1 with user benefit]
• [Feature 2 with user benefit]
• [Feature 3 with user benefit]
• [Feature 4 with user benefit]
• [Feature 5 with user benefit]

[Social proof or usage stat if available]

[Privacy / data reassurance if relevant]

[CTA — 1 sentence download prompt]
```

### Step 6: Validate and write files

Count characters for each field before writing. If any field exceeds the limit, revise before saving.

Write to:
```
~/Documents/ARCLabsStudio/Distribution/<AppName>/metadata/en-US/
```

Or use the CLI:
```bash
# Validate after writing
arc-distribution validate-metadata --app-id <AppName> --locale en-US
```

### Step 7: Output summary

```
## Metadata Written — [AppName] [en-US]

name.txt:        [value] (XX/30 chars)
subtitle.txt:    [value] (XX/30 chars)
keywords.txt:    [value] (XX/100 chars)
description.txt: (XXXX/4000 chars)

Status: All fields valid ✓
```
