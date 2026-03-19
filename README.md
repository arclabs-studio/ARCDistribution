# 📦 ARCDistribution

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2017%2B%20%7C%20macOS%2014%2B-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
![Version](https://img.shields.io/badge/Version-1.0.0-blue.svg)

**App Store distribution automation for ARC Labs Studio apps.**

ASC API Client • Metadata Management • JWT Authentication • CLI Tool • Xcode Cloud Ready

---

## 🎯 Overview

ARCDistribution provides everything needed to automate App Store Connect workflows from Xcode Cloud `ci_scripts/` or the terminal. Built on ARCNetworking's interceptor chain with full Swift 6 strict concurrency compliance.

The package covers the entire distribution pipeline: reading localized metadata from iCloud, validating character limits, authenticating with App Store Connect via JWT, and submitting builds for review — all from a single CLI command or directly from Swift.

### Key Features

- ✅ **ASC API Client** — Typed endpoint structs + JWT authentication via BearerTokenInterceptor
- ✅ **Metadata Management** — Read/write localized metadata from the iCloud Distribution folder with character validation
- ✅ **Interceptor Chain** — ASCErrorInterceptor maps HTTP errors to structured `ASCError` / `ASCClientError` values
- ✅ **CLI Tool** — `arc-distribution` executable designed for Xcode Cloud `ci_scripts/`
- ✅ **Test Doubles** — `ARCDistributionMocks` with `MockAppStoreConnectClient` and `MockMetadataRepository`
- ✅ **Swift 6 Compliant** — Full strict concurrency support with `Sendable` types throughout

**Apps using this package:** FavRes · FavBook · PizzeriaLaFamiglia · TicketMind · BackHaul

---

## 📋 Requirements

| Requirement | Minimum |
|-------------|---------|
| iOS         | 17.0    |
| macOS       | 14.0    |
| Swift       | 6.0+    |
| Xcode       | 16.0+   |

**Tools:** SwiftLint, SwiftFormat (via ARCDevTools)

---

## 🚀 Installation

### Swift Package Manager

#### For Swift Packages

```swift
// Package.swift
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

#### For Xcode Projects

1. **File → Add Package Dependencies**
2. Enter: `https://github.com/arclabs-studio/ARCDistribution`
3. Select version: `1.0.0` or later
4. Add `ARCDistribution` to your target

### App Store Connect API Setup

1. Go to **App Store Connect → Users and Access → Integrations → App Store Connect API**
2. Generate a new API key with **App Manager** role
3. Download the `.p8` file (only downloadable once)
4. Set environment variables:

```bash
export ASC_KEY_ID=<your-key-id>
export ASC_ISSUER_ID=<your-issuer-id>
export ASC_PRIVATE_KEY=$(base64 -i AuthKey_<KEY_ID>.p8)
```

For Xcode Cloud, add these as environment variables in App Store Connect CI configuration.

---

## 📖 Usage

### Quick Start

```swift
import ARCASCClient
import ARCASCModels

let credentials = try ASCCredentials.fromEnvironment()
let client = AppStoreConnectClient(credentials: credentials)

// Fetch builds
let builds = try await client.fetchBuilds(appId: "your-app-id", limit: 10)

// Upload metadata
let version = try await client.fetchCurrentVersion(appId: "your-app-id", platform: .iOS)
try await client.uploadMetadata(metadata, versionId: version.id)
```

### CLI — Metadata Workflow

#### 1. Set up the distribution folder

```bash
./ARCDevTools/scripts/setup-distribution.sh --all
```

#### 2. Fill in metadata

```
~/Documents/ARCLabsStudio/Distribution/FavRes/metadata/en-US/
  name.txt           ← 30 chars max
  subtitle.txt       ← 30 chars max
  keywords.txt       ← 100 chars max
  description.txt    ← 4000 chars max
  release_notes.txt
```

#### 3. Validate

```bash
arc-distribution validate-metadata --app-id FavRes --locale en-US
```

#### 4. Sync to App Store Connect

```bash
arc-distribution metadata sync --app-id FavRes
```

#### 5. Submit for review

```bash
arc-distribution submit --app-id FavRes
```

### Xcode Cloud Integration

The template in `ARCDevTools/templates/ci_scripts/ci_post_xcodebuild.sh` automatically syncs metadata after a successful archive when `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_PRIVATE_KEY`, and `APP_ID` are set.

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

## 🏗️ Project Structure

```
ARCDistribution/
├── Sources/
│   ├── ARCASCModels/          — Codable models (App, Build, AppStoreVersion, …)
│   ├── ARCASCClient/          — ASC API client + JWT interceptor chain
│   │   ├── Endpoints/         — Typed Endpoint structs (one per API operation)
│   │   └── Interceptors/      — ASCErrorInterceptor (ASC-specific error mapping)
│   ├── ARCMetadataManager/    — FileMetadataRepository + MetadataValidator
│   ├── ARCDistributionMocks/  — MockAppStoreConnectClient, MockMetadataRepository
│   └── ARCDistributionCLI/    — arc-distribution executable
├── Tests/
│   └── ARCDistributionTests/
└── Documentation.docc/
```

Dependencies: `ARCNetworking` · `ARCLogger` · `ARCStorage`

---

## 🧪 Testing

All protocols have corresponding mocks in `ARCDistributionMocks`:

```swift
import ARCDistributionMocks
import Testing

@Test("Uploads metadata on sync", .tags(.unit))
func uploadsMetadata() async throws {
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

### Coverage

- **Packages:** Target 100%, minimum 80%

---

## 📐 Architecture

ARCDistribution follows **Clean Architecture** with protocol-based dependency injection:

- **`ARCASCClient`** — Domain layer: typed endpoints + JWT auth via interceptor chain
- **`ARCMetadataManager`** — Data layer: filesystem repository + validation
- **`ARCDistributionCLI`** — Presentation layer: CLI entry point with `ARCLogger`
- **`ARCDistributionMocks`** — Test infrastructure: protocol-conforming doubles

For complete architecture guidelines, see [ARCKnowledge](https://github.com/arclabs-studio/ARCKnowledge).

---

## 🛠️ Development

### Prerequisites

```bash
brew install swiftlint swiftformat
```

### Setup

```bash
# Clone the repository
git clone https://github.com/arclabs-studio/ARCDistribution.git
cd ARCDistribution

# Initialize submodules
git submodule update --init --recursive

# Build the project
swift build
```

### Available Commands

```bash
make help      # Show all available commands
make lint      # Run SwiftLint
make format    # Preview formatting changes
make fix       # Apply SwiftFormat
make test      # Run tests
make clean     # Remove build artifacts
```

---

## 🤝 Contributing

This is an internal ARC Labs Studio package. Team members:

1. Create a feature branch: `feature/ARC-123-description`
2. Follow [ARCKnowledge](https://github.com/arclabs-studio/ARCKnowledge) standards
3. Ensure tests pass: `swift test`
4. Run quality checks: `make lint && make format`
5. Create a pull request to `develop`

### Commit Messages

Follow [Conventional Commits](https://github.com/arclabs-studio/ARCKnowledge):

```
feat(scope): add new feature
fix(scope): resolve bug
test(scope): add missing tests
docs(scope): update documentation
```

---

## 📦 Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** — Breaking changes
- **MINOR** — New features (backwards compatible)
- **PATCH** — Bug fixes (backwards compatible)

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## 📄 License

MIT License © 2025 ARC Labs Studio

See [LICENSE](LICENSE) for details.

---

## 🔗 Related Resources

- **[ARCKnowledge](https://github.com/arclabs-studio/ARCKnowledge)** — Development standards and guidelines
- **[ARCDevTools](https://github.com/arclabs-studio/ARCDevTools)** — Quality tooling and automation
- **[ARCNetworking](https://github.com/arclabs-studio/ARCNetworking)** — HTTP client used by ARCASCClient
- **[ARCLogger](https://github.com/arclabs-studio/ARCLogger)** — Structured logging

---

<div align="center">

Made with 💛 by ARC Labs Studio

[**Website**](https://arclabs.studio) • [**GitHub**](https://github.com/ARCLabsStudio) • [**Issues**](https://github.com/arclabs-studio/ARCDistribution/issues)

</div>
