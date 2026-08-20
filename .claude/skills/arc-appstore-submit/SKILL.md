---
name: arc-appstore-submit
description: |
  App Store submission checklist + App-Store-Connect-CLI command sequence.
  Walks through all pre-submission gates and automates the final upload via CLI.
  Use when "submit to App Store", "submit for review", "App Store submission",
  "pre-submission checklist", or "ready to release".
user-invocable: true
metadata:
  author: ARC Labs Studio
  version: "1.0.0"
---

# arc-appstore-submit — App Store Submission Workflow

## Instructions

### Prerequisites

Verify App-Store-Connect-CLI is installed:
```bash
which asc || brew install rudrankriyam/tap/app-store-connect-cli
asc --version
```

Set environment variables (or export from CI):
```bash
export ASC_KEY_ID="YOUR_KEY_ID"
export ASC_ISSUER_ID="YOUR_ISSUER_ID"
export ASC_PRIVATE_KEY="$(base64 -i AuthKey_XXXXXX.p8)"
```

### Step 1: Pre-submission checklist

Work through each gate. Do NOT proceed if any critical item fails.

**Metadata (Critical)**
- [ ] `name.txt` ≤ 30 chars and contains primary keyword
- [ ] `subtitle.txt` ≤ 30 chars, no duplicates with name
- [ ] `keywords.txt` ≤ 100 chars, no duplicates, no spaces after commas
- [ ] `description.txt` ≤ 4000 chars, hook in first 250 chars
- [ ] `release_notes.txt` present and user-facing (not "bug fixes")
- [ ] All required localizations present

Validate via CLI:
```bash
arc-distribution validate-metadata --app-id <AppName> --locale en-US
arc-distribution validate-metadata --app-id <AppName> --locale es-ES
```

**Build (Critical)**
- [ ] Xcode Cloud archive succeeded
- [ ] Build status is VALID in TestFlight
- [ ] Build tested on physical device (not just simulator)
- [ ] TestFlight external group approved build
- [ ] No crashes in TestFlight feedback

**App Store Connect (Critical)**
- [ ] Version number matches build
- [ ] Age rating complete
- [ ] Privacy policy URL set and live
- [ ] Support URL set
- [ ] Copyright year current
- [ ] Content rights declaration complete
- [ ] Export compliance answered

**Privacy & Entitlements (Critical)**
- [ ] `PrivacyInfo.xcprivacy` present in app target (required since Spring 2024)
- [ ] All declared privacy nutrition labels match actual data collection
- [ ] No unused entitlements in `.entitlements` file — cross-reference with actual API usage
- [ ] No competitor brand names in metadata files (Android, Google Play, Samsung, Pixel, etc.)
- [ ] Subscription apps: Terms of Service URL and Privacy Policy URL set in App Store Connect

Validate privacy manifest presence:
```bash
find . -name "PrivacyInfo.xcprivacy" -not -path "*/.*"
```

Check for competitor terms in metadata:
```bash
grep -ri -E "android|google play|samsung|pixel|huawei" ~/Documents/ARCLabsStudio/Distribution/*/metadata/
```

**Screenshots (High)**
- [ ] iPhone 6.9" screenshots uploaded (min 3, ideally 10)
- [ ] iPhone 6.5" screenshots uploaded
- [ ] iPad screenshots uploaded (if app supports iPad)
- [ ] No simulator frames unless intentional

**Review Notes (Medium)**
- [ ] Demo account provided if app requires login
- [ ] Notes for reviewer if non-obvious flows exist

### Step 2: Sync metadata to App Store Connect

```bash
arc-distribution metadata sync --app-id <AppName> --locale en-US
arc-distribution metadata sync --app-id <AppName> --locale es-ES
```

Or via asc CLI directly:
```bash
asc apps list
asc builds list --app-id <APP_ID>
```

### Step 3: Select build and submit

```bash
arc-distribution submit --app-id <AppName>
```

### Step 4: Post-submission

- [ ] Check ASC for "Waiting for Review" status
- [ ] Set review timer reminder (typical: 1–3 days)
- [ ] Prepare marketing materials in `marketing/` folder
- [ ] Draft announcement social post in `marketing/social/`

### Output

```
## Submission Report — [AppName] v[version]

Metadata:  ✓ Valid
Build:     ✓ [build_number] selected
Submitted: ✓ [timestamp]

Next: Check App Store Connect for review status
Typical review time: 24–48 hours
```
