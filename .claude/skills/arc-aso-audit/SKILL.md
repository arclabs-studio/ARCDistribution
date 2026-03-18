---
name: arc-aso-audit
description: |
  Full App Store Optimization audit for ARC Labs apps. Scores title, subtitle,
  keywords, screenshots, ratings, localization, and competitive positioning.
  Generates a prioritized compliance report with specific fixes. Use when
  "audit ASO", "check app store listing", "improve App Store ranking",
  "ASO health check", or "pre-launch App Store review".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# arc-aso-audit — App Store Optimization Audit

## Instructions

Perform a full ASO audit for the specified app. If no app is specified, ask which ARC Labs app to audit (FavRes, FavBook, PizzeriaLaFamiglia, TicketMind, BackHaul).

### Step 1: Gather existing metadata

Read from the iCloud Distribution folder:
```
~/Documents/ARCLabsStudio/Distribution/<AppName>/metadata/en-US/
  name.txt, subtitle.txt, keywords.txt, description.txt, release_notes.txt
```

If metadata files don't exist, ask the user to provide the current live metadata.

### Step 2: Score each dimension (0–100)

| Dimension | Weight | Criteria |
|-----------|--------|----------|
| **Title** | 20% | Exact keyword in name, 30-char usage, brand clarity |
| **Subtitle** | 15% | Unique keywords (no duplicates from title), 30-char usage |
| **Keywords** | 25% | Unique terms (no duplicates), 100-char usage, relevance |
| **Description** | 15% | Hook in first 3 lines, feature bullets, CTA, natural keyword density |
| **Release Notes** | 5% | Informative, not generic "bug fixes" |
| **Localization** | 10% | es-ES present and adapted (not just translated) |
| **Screenshots** | 10% | 10-slot strategy assessment (ask user to describe or share) |

### Step 3: Check character limits

```
name.txt        → max 30 chars (flag if over or under 25)
subtitle.txt    → max 30 chars (flag if over or under 22)
keywords.txt    → max 100 chars (flag duplicates with title/subtitle)
description.txt → max 4000 chars
```

Use `ARCDistribution` CLI if available:
```bash
arc-distribution validate-metadata --app-id <AppName> --locale en-US
```

### Step 4: Keyword analysis

- List all keywords in `keywords.txt`
- Flag any that duplicate words already in `name.txt` or `subtitle.txt` (wasted space)
- Flag any single-character separators or trailing commas
- Suggest 3 replacement keywords (high relevance, low competition)

### Step 5: Competitive gap check

Use iTunes Search API to find top 3 competitors:
```
GET https://itunes.apple.com/search?term=<main_keyword>&entity=software&country=us&limit=3
```
Compare their titles and subtitles for keyword gaps.

### Step 6: Generate report

Output format:

```
## ASO Audit Report — [AppName]
**Date:** [today]
**Overall Score:** [X/100]

### Critical Issues (fix before next update)
- [ ] [Issue with specific fix]

### Improvements (fix within 2 updates)
- [ ] [Improvement with specific fix]

### Quick Wins (low effort, high impact)
- [ ] [Quick win]

### Dimension Scores
| Dimension | Score | Status |
|-----------|-------|--------|
| Title     | X/100 | 🔴/🟡/🟢 |
...

### Keyword Audit
- Wasted duplicates: [list]
- Unused chars: [X] of 100
- Suggested replacements: [list]
```

Color coding: 🔴 < 60, 🟡 60–79, 🟢 80+
