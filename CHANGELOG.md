# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-08-20

First public release of **ARCDistribution**.

ARC Labs Studio re-baselined every package at `1.0.0` for its first product launch. The pre-launch version history (0.1.0 → 1.1.0) never corresponded to a release the studio stood behind; those tags and GitHub Releases have been removed and the notes are preserved below under [Pre-1.0 history](#pre-10-history-untagged).

### Added

- **`INTERNAL-USE.md`** — documents ARC Labs Studio's self-grant for commercial use of its own products under the new licence.

### Changed

- **ARCNetworking dependency** — converted from a `branch: "develop"` pin to `from: "1.0.0"`. SPM refuses branch requirements in a versioned package, so this package could not be released until the pin was converted.

- **License** — relicensed from MIT to [PolyForm Noncommercial 1.0.0](https://polyformproject.org/licenses/noncommercial/1.0.0). Source-available and free for non-commercial use; commercial use requires a separate licence from ARC Labs Studio. ARC Labs Studio's own products are covered by an internal grant — see `INTERNAL-USE.md`.

### Fixed

- **`.gitmodules`** — the ARCDevTools submodule URL now carries the `.git` suffix used by the other twelve packages.

### Notes

- The 1.0.0 and 1.1.0 sections in the pre-1.0 history below were written but never tagged, and the orphan `0.1.0` tag was an ancestor of neither `main` nor `develop`. All are superseded by this release.

---

## Pre-1.0 history (untagged)

Everything below predates the 1.0.0 baseline. The version numbers are retained for traceability only — no tag or release exists for any of them.

### [1.1.0] - 2026-03-19

#### Added

- `ARCDistributionCLI` — `--platform` flag for `metadata sync` and `submit` commands;
  supports `ios`, `macos`, `tvos`, `visionos` (default: `ios`)
- `ARCDistributionCLI` — `CLIError` with `missingArgument` and `unknownPlatform` cases;
  `Platform.init(cliValue:)` for CLI string → enum mapping
- `ARCDistributionMocks` — `fetchCurrentVersionCallCount` and
  `lastFetchCurrentVersionAppId` call tracking on `MockAppStoreConnectClient`
- `ARCDistributionTests` — `FileMetadataRepository` integration suite (6 tests):
  round-trip save/load, overwrite, missing folder, missing file, `availableLocales`
  sorting, stray-file filtering

#### Changed

- `ARCASCClient` — `ASCEndpoint` refinement protocol provides default `baseURL`,
  `headers`, `queryItems`, and `body`; endpoint structs now only declare what they
  customise (~110 lines of boilerplate removed)
- `ARCASCClient` — Endpoint request bodies (`SubmitForReviewEndpoint`,
  `CreateLocalizationEndpoint`, `PatchLocalizationEndpoint`) migrated from
  `[String: Any] + JSONSerialization` to typed `Encodable` structs + `JSONEncoder`;
  eliminates silent `try?` failure path on malformed body
- `ARCASCModels` — `AppMetadata` now conforms to `Codable` in addition to `Sendable`

#### Fixed

- `ARCDistributionCLI` — `requireArg` now throws `CLIError.missingArgument` instead of
  calling `exit(1)` directly, making argument parsing testable
- `ARCASCClient` — `ASCErrorInterceptor` signature simplified via `NextHandler`
  typealias; resolves SwiftLint ↔ SwiftFormat alignment conflict on the closure type
- `JWTGenerator` — removed dead `JWTError.signingFailed` case that was never thrown

#### Removed

- `Package.swift` — `ARCStorage` dependency removed; it was declared for
  `ARCMetadataManager` but never imported in any source file

---

### [1.0.0] - 2026-03-18

#### Added

- `ARCASCModels` — Codable models for App Store Connect API v1 (App, Build,
  AppStoreVersion, AppStoreVersionLocalization, ASCError, EmptyResponse)
- `ARCASCClient` — JWT-authenticated HTTP client for App Store Connect API;
  typed `Endpoint` structs; interceptor chain via ARCNetworking
  (`BearerTokenInterceptor`, `ASCErrorInterceptor`, `LoggingInterceptor`)
- `ARCMetadataManager` — Read/write localized metadata from iCloud Distribution folder;
  `FileMetadataRepository`, `MetadataValidator`
- `ARCDistributionMocks` — `MockAppStoreConnectClient`, `MockMetadataRepository`
  test doubles for all public protocols
- `arc-distribution` CLI — `builds list`, `metadata sync`, `submit`,
  `validate-metadata` commands; all output via `ARCLogger`
- Claude Code skills — 10 ASO + distribution skills in `.claude/skills/`
- ARCDevTools integration — SwiftLint, SwiftFormat, Makefile

---

[1.0.0]: https://github.com/arclabs-studio/ARCDistribution/releases/tag/v1.0.0
