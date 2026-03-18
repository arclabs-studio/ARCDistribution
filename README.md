# ARCDistribution

App Store distribution automation for ARC Labs Studio apps.

## What This Package Does

- **ASC API Client** — JWT authentication + HTTP client for App Store Connect API v1
- **Metadata Manager** — Read/write localized metadata from the iCloud Distribution folder
- **CLI Tool** — `arc-distribution` for use in Xcode Cloud `ci_scripts/` and terminal
- **Claude Code Skills** — 10 ASO + distribution skills in `.claude/skills/`

## Apps

FavRes · FavBook · PizzeriaLaFamiglia · TicketMind · BackHaul

## Quick Start

### 1. Set up the distribution folder

```bash
./ARCDevTools/scripts/setup-distribution.sh --all
```

### 2. Fill in metadata

```
~/Documents/ARCLabsStudio/Distribution/FavRes/metadata/en-US/
  name.txt           ← 30 chars max
  subtitle.txt       ← 30 chars max
  keywords.txt       ← 100 chars max
  description.txt    ← 4000 chars max
  release_notes.txt
```

### 3. Validate metadata

```bash
arc-distribution validate-metadata --app-id FavRes --locale en-US
```

### 4. Sync to App Store Connect

```bash
export ASC_KEY_ID=...
export ASC_ISSUER_ID=...
export ASC_PRIVATE_KEY=$(base64 -i AuthKey_XXXXXX.p8)

arc-distribution metadata sync --app-id FavRes
```

### 5. Submit for review

```bash
arc-distribution submit --app-id FavRes
```

## Claude Code Skills

| Skill | Purpose |
|-------|---------|
| `/arc-aso-audit` | Full ASO audit — scored report |
| `/arc-aso-keywords` | Keyword research via iTunes API |
| `/arc-metadata-write` | Generate character-validated metadata |
| `/arc-metadata-localize` | Localized metadata from base language |
| `/arc-release-notes` | Draft release notes from `git log` |
| `/arc-screenshot-brief` | 10-slot screenshot strategy brief |
| `/arc-appstore-submit` | Submission checklist + CLI sequence |
| `/arc-aso-competitor` | Competitor gap analysis |
| `/arc-ua-campaign` | Apple Search Ads campaign setup |
| `/arc-review-management` | HEAR framework for review responses |

Skills are installed into iOS app projects via:
```bash
./ARCDevTools/scripts/setup-skills.sh
```

## App Store Connect API Setup

1. Go to App Store Connect → Users and Access → Integrations → App Store Connect API
2. Generate a new API key with App Manager role
3. Download the `.p8` file (only downloadable once)
4. Set environment variables:
   ```bash
   ASC_KEY_ID=<your-key-id>
   ASC_ISSUER_ID=<your-issuer-id>
   ASC_PRIVATE_KEY=$(base64 -i AuthKey_<KEY_ID>.p8)
   ```

For Xcode Cloud, add these as environment variables in App Store Connect CI configuration.

## Xcode Cloud Integration

The template in `ARCDevTools/templates/ci_scripts/ci_post_xcodebuild.sh` automatically syncs metadata after a successful archive if `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_PRIVATE_KEY`, and `APP_ID` are set.

## Install App-Store-Connect-CLI Companion

```bash
brew install rudrankriyam/tap/app-store-connect-cli
asc --version
```

## RespectASO (Keyword Research)

Self-hosted keyword research tool. See [Docs/respectaso.md](Docs/respectaso.md).

## Requirements

- iOS 17+ / macOS 14+
- Swift 6.0
- Dependencies: ARCNetworking, ARCLogger, ARCStorage
