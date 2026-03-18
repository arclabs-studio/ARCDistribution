# ARCDistribution

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%2B%20%7C%20macOS%2014%2B-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)

App Store distribution automation for ARC Labs Studio apps.

---

## 🎯 Overview

ARCDistribution provides everything needed to automate App Store Connect workflows
from Xcode Cloud `ci_scripts/` or the terminal:

- **`ARCASCClient`** — JWT authentication + typed HTTP client for App Store Connect API v1,
  built on ARCNetworking's interceptor chain
- **`ARCMetadataManager`** — Read/write localized metadata from the iCloud Distribution folder
- **`arc-distribution` CLI** — Command-line tool for build listing, metadata sync, submission,
  and validation; designed for use in Xcode Cloud `ci_scripts/`
- **`ARCDistributionMocks`** — Test doubles for all public protocols

**Apps using this package:** FavRes · FavBook · PizzeriaLaFamiglia · TicketMind · BackHaul

---

## 🏗️ Architecture

```
ARCDistribution (package)
├── ARCASCModels          — Codable models (App, Build, AppStoreVersion, …)
├── ARCASCClient          — ASC API client + JWT interceptor chain
│   ├── Endpoints/        — Typed Endpoint structs (one per API operation)
│   └── Interceptors/     — ASCErrorInterceptor (ASC-specific error mapping)
├── ARCMetadataManager    — FileMetadataRepository + MetadataValidator
├── ARCDistributionMocks  — MockAppStoreConnectClient, MockMetadataRepository
└── ARCDistributionCLI    — arc-distribution executable
```

Dependencies: `ARCNetworking` · `ARCLogger` · `ARCStorage`

---

## 🚀 Installation

### Swift Package Manager

```swift
// In Package.swift
dependencies: [
    .package(url: "https://github.com/arclabs-studio/ARCDistribution.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "ARCDistribution", package: "ARCDistribution")
        ]
    )
]
```

### Requirements

- iOS 17+ / macOS 14+
- Swift 6.0
- Xcode 16+

---

## 📖 Usage

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

### Using the client in Swift

```swift
import ARCASCClient
import ARCASCModels

let credentials = try ASCCredentials.fromEnvironment()
let client = AppStoreConnectClient(credentials: credentials)

// Fetch builds
let builds = try await client.fetchBuilds(appId: "your-app-id", limit: 10)

// Fetch current version and upload metadata
let version = try await client.fetchCurrentVersion(appId: "your-app-id", platform: .iOS)
try await client.uploadMetadata(metadata, versionId: version.id)
```

### App Store Connect API Setup

1. Go to App Store Connect → Users and Access → Integrations → App Store Connect API
2. Generate a new API key with **App Manager** role
3. Download the `.p8` file (only downloadable once)
4. Set environment variables:

```bash
export ASC_KEY_ID=<your-key-id>
export ASC_ISSUER_ID=<your-issuer-id>
export ASC_PRIVATE_KEY=$(base64 -i AuthKey_<KEY_ID>.p8)
```

For Xcode Cloud, add these as environment variables in App Store Connect CI configuration.

### Xcode Cloud Integration

The template in `ARCDevTools/templates/ci_scripts/ci_post_xcodebuild.sh` automatically
syncs metadata after a successful archive when `ASC_KEY_ID`, `ASC_ISSUER_ID`,
`ASC_PRIVATE_KEY`, and `APP_ID` are set.

### Claude Code Skills

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

Install skills into iOS app projects:

```bash
./ARCDevTools/scripts/setup-skills.sh
```

---

## 🧪 Testing

All protocols have corresponding mocks in `ARCDistributionMocks`:

```swift
import ARCDistributionMocks
import Testing

@Test func uploadsMetadata() async throws {
    let mock = MockAppStoreConnectClient()
    mock.stubbedVersion = makeStubVersion()

    try await sut.syncMetadata(client: mock)

    #expect(mock.uploadMetadataCallCount == 1)
}
```

Run the test suite:

```bash
make test
# or
swift test
```

---

## 🤝 Contributing

This is an internal ARC Labs Studio package. Follow the global standards in
`ARCKnowledge/Quality/` and the Git workflow in `ARCKnowledge/Workflows/`.

```bash
make lint    # SwiftLint
make format  # SwiftFormat check
make fix     # Apply SwiftFormat
make test    # Run tests
```

---

## 📄 License

MIT © ARC Labs Studio. See [LICENSE](LICENSE) for details.
