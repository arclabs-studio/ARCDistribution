---
name: arc-aso-keywords
description: |
  Keyword research for App Store Optimization. Discovers high-value keywords
  using iTunes Search API and tiered strategy (exact/broad/long-tail). Outputs
  a ranked keyword list that fits in 100 chars. Use when "find keywords",
  "keyword research", "improve App Store search ranking", "what keywords to use",
  or "optimize keywords.txt".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# arc-aso-keywords — ASO Keyword Research

## Instructions

### Step 1: Understand the app

Ask (or read from metadata):
- App name and category
- Core user problem the app solves
- Target audience
- 3 features that differentiate it

### Step 2: Seed keyword generation

Generate 30 candidate keywords organized by tier:

**Tier 1 — Exact Intent (highest conversion)**
- 2–3 word phrases matching direct user need
- Examples: "restaurant finder", "food favorites"

**Tier 2 — Broad Category**
- Single words covering the app category
- Examples: "restaurant", "food", "dining"

**Tier 3 — Long-tail (lower volume, less competition)**
- 3–4 word phrases for niche intent
- Examples: "save favorite restaurants", "restaurant bucket list"

### Step 3: Validate with iTunes Search API

For each top-10 seed keyword, check competitive density:
```bash
curl "https://itunes.apple.com/search?term=<keyword>&entity=software&country=us&limit=5" \
  | python3 -m json.tool | grep trackName
```

High competition (5 big-name results) → deprioritize
Low competition (niche results) → prioritize

### Step 4: Check RespectASO (if running locally)

If the user has RespectASO running:
```
http://localhost:3000
```
Enter keywords for volume/difficulty estimates. See `ARCDistribution/Docs/respectaso.md`.

### Step 5: Build final keywords.txt (100 chars max)

Rules:
- Comma-separated, no spaces after commas
- No words already in `name.txt` or `subtitle.txt`
- No plural + singular of same word
- Sort by: Tier 1 first, then Tier 2, then Tier 3

Output:
```
## Keyword Research — [AppName]

### Recommended keywords.txt (XX/100 chars):
restaurant,dining,food,favorites,save,discovery,local,eatery,cuisine,spots

### Tier breakdown:
- Tier 1 (exact): restaurant,dining,food
- Tier 2 (broad): favorites,save,discovery
- Tier 3 (long-tail): [use in description instead]

### Excluded (duplicates with title/subtitle):
[list]

### Alternative keywords if over 100 chars:
[ranked alternatives]
```
