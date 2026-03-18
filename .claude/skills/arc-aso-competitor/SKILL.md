---
name: arc-aso-competitor
description: |
  Competitor gap analysis via iTunes Search API. Finds top competitors for an
  ARC Labs app, extracts their keyword strategy, and surfaces gaps where our
  app can rank. Use when "competitor analysis", "keyword gaps", "competitor ASO",
  "what keywords are competitors using", or "competitive positioning".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# arc-aso-competitor — Competitor Gap Analysis

## Instructions

### Step 1: Identify competitors

Ask for or infer the primary keyword category. Search iTunes:
```bash
curl "https://itunes.apple.com/search?term=<primary_keyword>&entity=software&country=us&limit=10" \
  | python3 -c "import sys,json; data=json.load(sys.stdin); [print(r['trackName'], '|', r.get('artistName','')) for r in data['results']]"
```

Pick top 3–5 that directly compete with our app.

### Step 2: Extract competitor metadata

For each competitor, retrieve their App Store page:
```bash
curl "https://itunes.apple.com/lookup?id=<APP_ID>&country=us" \
  | python3 -m json.tool | grep -E '"trackName"|"description"|"primaryGenreName"'
```

Collect:
- App name (note keywords in name)
- Description first paragraph (first 250 chars visible in search)
- Category
- Rating count and rating

### Step 3: Build competitor keyword matrix

| Keyword | Our App | Comp 1 | Comp 2 | Comp 3 | Opportunity |
|---------|---------|--------|--------|--------|-------------|
| [term]  | ✓/✗    | ✓/✗   | ✓/✗   | ✓/✗   | High/Med/Low |

Mark keywords competitors use heavily but we don't → **gaps**.
Mark keywords we use but competitors miss → **differentiators** (keep!).

### Step 4: Opportunity scoring

Rate each gap keyword:
- **High opportunity**: Competitors use it, we don't, it's high-relevance
- **Medium opportunity**: Mixed coverage, partial relevance
- **Low opportunity**: All competitors use it (too competitive)

### Step 5: Generate recommendations

```
## Competitor Analysis — [AppName]

### Top Competitors Found
1. [Name] — [rating] stars, [count] ratings
2. [Name] — ...
3. [Name] — ...

### Keyword Gaps (competitors have, we don't)
- [keyword] — used by [N]/3 competitors, relevance: High/Med
- ...

### Our Differentiators (we have, they don't)
- [keyword] — keep this!

### Recommended Additions to keywords.txt
Replace [current_keyword] with [gap_keyword] (saves X chars, gains Y opportunity)

### Competitor Title Analysis
- [Comp 1]: uses "[keyword]" in name → indicates high search volume
- [Comp 2]: subtitle formula is "[pattern]" → we should test similar
```
