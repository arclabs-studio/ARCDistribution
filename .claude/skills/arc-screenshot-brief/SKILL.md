---
name: arc-screenshot-brief
description: |
  10-slot App Store screenshot strategy with copy/caption brief for designer handoff.
  Defines which screens to show, caption text, and visual hierarchy for each slot.
  Use when "plan screenshots", "screenshot strategy", "what screenshots to make",
  "screenshot brief for designer", or "App Store visual assets".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# arc-screenshot-brief — Screenshot Strategy

## Instructions

### Step 1: Understand the app

Ask for or infer:
- App name and primary value proposition
- Key user flows (onboarding, main feature, secondary features)
- Target device (iPhone primary? iPad?)
- Tone (premium, friendly, minimal)

### Step 2: Screenshot slot strategy

App Store allows up to 10 screenshots. Allocate strategically:

| Slot | Purpose | Priority |
|------|---------|----------|
| 1 | **Hero** — strongest value prop, highest conversion impact | Critical |
| 2 | **Core feature** — primary action users take | Critical |
| 3 | **Feature 2** — second most valuable feature | High |
| 4 | **Feature 3** or social proof | High |
| 5 | **Feature 4** or personalization | Medium |
| 6–8 | Secondary features, edge cases, or seasonal | Low |
| 9–10 | Localization variants or iPad if primary | Optional |

### Step 3: Devise the narrative arc

Screenshots should tell a story in sequence:
```
Hook → Discovery → Action → Result → Delight
```

### Step 4: Write caption briefs for each slot

For each slot, output:
```
## Screenshot [N] — [Slot Purpose]

Screen to show: [specific app screen/state]
Caption headline: [max 6 words, all caps or title case]
Caption body: [1 line, max 8 words]
Visual emphasis: [what element to highlight or blur out]
Background: [suggested color or gradient]
```

### Step 5: Device size requirements

| Device | Dimensions | Folder |
|--------|-----------|--------|
| iPhone 6.9" (primary) | 1320×2868 | iPhone-6.9/ |
| iPhone 6.5" | 1242×2688 | iPhone-6.5/ |
| iPad 13" (if iPad) | 2048×2732 | iPad-13/ |

Files live in: `~/Documents/ARCLabsStudio/Distribution/<AppName>/screenshots/`

### Step 6: Handoff checklist

```
## Screenshot Brief — [AppName]

[ ] Brief reviewed and approved
[ ] 10 slots allocated with rationale
[ ] Caption copy finalized
[ ] Device sizes confirmed with designer
[ ] Brand colors/fonts provided from Branding/
[ ] Reference screenshots from competitor saved to marketing/promo/
```
