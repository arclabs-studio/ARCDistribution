---
name: arc-ua-campaign
description: |
  Apple Search Ads campaign setup and keyword bidding strategy. Plans campaign
  structure, ad groups, keyword bids, and audience targeting. Use when
  "Apple Search Ads", "search ads campaign", "keyword bidding", "paid UA",
  "user acquisition", or "ASA campaign setup".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# arc-ua-campaign — Apple Search Ads Campaign Strategy

## Instructions

### Step 1: Campaign structure

Apple Search Ads Basic vs Advanced:
- **Basic**: Set daily budget, ASA handles everything. Good for starting.
- **Advanced**: Full control over ad groups, keywords, bids, audiences.

Recommend Advanced for all ARC Labs apps with > 100 downloads/month.

### Step 2: Campaign architecture

```
Campaign: [AppName] — Brand
└── Ad Group: Brand Terms
    └── Keywords: [app name], [brand variations]

Campaign: [AppName] — Category
└── Ad Group: Category Exact Match
    └── Keywords: [exact category terms]
└── Ad Group: Category Broad
    └── Keywords: [broad category terms]

Campaign: [AppName] — Competitor
└── Ad Group: Competitor Names
    └── Keywords: [competitor app names]
```

### Step 3: Seed keywords from ASO metadata

Pull from `keywords.txt` and arc-aso-keywords output:
- All Tier 1 keywords → Exact match, higher bids
- All Tier 2 keywords → Broad match, medium bids
- Competitor names → Exact match, competitive bids

### Step 4: Bid strategy

Starting bids (adjust after 1 week of data):

| Keyword Type | Starting CPT Bid | Daily Budget % |
|-------------|-----------------|----------------|
| Brand exact | $0.50 | 10% |
| Category exact | $1.00–$2.00 | 40% |
| Category broad | $0.75 | 30% |
| Competitor | $1.50–$2.50 | 20% |

CPT = Cost Per Tap. Adjust based on conversion rate.

### Step 5: Audience targeting

- **New Users Only** (exclude existing customers)
- **All Users** (default) — broadest reach
- **Returning Users** — win-back lapsed users (separate campaign)

For ARC Labs apps targeting iOS power users:
- Device type: iPhone
- Country: US primary, ES secondary

### Step 6: Measurement

Key metrics to track weekly:
- TTR (Tap-Through Rate): target > 5%
- Conversion Rate: target > 60% (for branded), > 40% (category)
- CPA (Cost Per Acquisition): calculate LTV/CPA ratio

### Output

```
## Campaign Plan — [AppName]

### Budget Recommendation
Monthly budget: $[X] based on [Y] target installs at $[Z] CPA

### Campaign Structure
[Table of campaigns, ad groups, keywords, bids]

### Week 1 Actions
1. Create campaigns with exact match only
2. Set search match ON for discovery
3. Review every 3 days, pause keywords with TTR < 2%

### Negative Keywords
[List of terms to exclude to prevent irrelevant taps]
```
