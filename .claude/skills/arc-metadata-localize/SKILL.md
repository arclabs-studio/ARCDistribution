---
name: arc-metadata-localize
description: |
  Generate localized App Store metadata variants from a base language. Adapts
  content culturally (not just translates). Use when "localize app store metadata",
  "translate to Spanish", "add es-ES locale", "localize for new market",
  or "create metadata for [locale]".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# arc-metadata-localize — Metadata Localization

## Instructions

### Step 1: Read base language metadata

Read from `~/Documents/ARCLabsStudio/Distribution/<AppName>/metadata/en-US/`

If not present, run arc-metadata-write first.

### Step 2: Identify target locale

Ask or infer from context. Supported locales:
- `es-ES` — Spanish (Spain)
- `es-MX` — Spanish (Mexico)
- `fr-FR` — French (France)
- `de-DE` — German
- `pt-BR` — Portuguese (Brazil)
- `it-IT` — Italian
- `ja-JP` — Japanese
- `zh-Hans` — Simplified Chinese

### Step 3: Cultural adaptation rules

**DO NOT just translate word-for-word.** Instead:

1. **Keywords**: Research locale-specific App Store terms. Italian users search differently than Spanish users. Use iTunes Search API with `country=<country_code>` to verify.

2. **Description tone**: Adjust formality. German descriptions are more formal. Brazilian descriptions are warmer and more personal.

3. **Features to highlight**: Reorder bullets if some features are more relevant to the locale (e.g., payment methods, local integrations).

4. **Length**: Some languages expand 20–30% from English. Count characters after translation.

5. **Don't localize**: App name (keep brand consistent unless a strategic rename exists), screenshots text (unless budget allows).

### Step 4: Character count re-validation

After localization, all limits still apply:
- name.txt: ≤ 30 chars
- subtitle.txt: ≤ 30 chars
- keywords.txt: ≤ 100 chars

German and French tend to expand — you may need to shorten.

### Step 5: Write to locale folder

```
~/Documents/ARCLabsStudio/Distribution/<AppName>/metadata/<locale>/
```

### Step 6: Output summary

```
## Localization Complete — [AppName] [locale]

name.txt:        [value] (XX/30 chars)
subtitle.txt:    [value] (XX/30 chars)
keywords.txt:    [value] (XX/100 chars)

Cultural notes:
- [Any adaptation made that differs from literal translation]
- [Any keyword that was changed for locale-specific search behavior]
```
