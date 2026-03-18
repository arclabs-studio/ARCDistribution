# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-03-19

### Added

- `ARCDistributionCLI` — `--platform` flag for `metadata sync` and `submit` commands;
  supports `ios`, `macos`, `tvos`, `visionos` (default: `ios`)
- `ARCDistributionCLI` — `CLIError` with `missingArgument` and `unknownPlatform` cases;
  `Platform.init(cliValue:)` for CLI string → enum mapping
- `ARCDistributionMocks` — `fetchCurrentVersionCallCount` and
  `lastFetchCurrentVersionAppId` call tracking on `MockAppStoreConnectClient`
- `ARCDistributionTests` — `FileMetadataRepository` integration suite (6 tests):
  round-trip save/load, overwrite, missing folder, missing file, `availableLocales`
  sorting, stray-file filtering

### Changed

- `ARCASCClient` — `ASCEndpoint` refinement protocol provides default `baseURL`,
  `headers`, `queryItems`, and `body`; endpoint structs now only declare what they
  customise (~110 lines of boilerplate removed)
- `ARCASCClient` — Endpoint request bodies (`SubmitForReviewEndpoint`,
  `CreateLocalizationEndpoint`, `PatchLocalizationEndpoint`) migrated from
  `[String: Any] + JSONSerialization` to typed `Encodable` structs + `JSONEncoder`;
  eliminates silent `try?` failure path on malformed body
- `ARCASCModels` — `AppMetadata` now conforms to `Codable` in addition to `Sendable`

### Fixed

- `ARCDistributionCLI` — `requireArg` now throws `CLIError.missingArgument` instead of
  calling `exit(1)` directly, making argument parsing testable
- `ARCASCClient` — `ASCErrorInterceptor` signature simplified via `NextHandler`
  typealias; resolves SwiftLint ↔ SwiftFormat alignment conflict on the closure type
- `JWTGenerator` — removed dead `JWTError.signingFailed` case that was never thrown

### Removed

- `Package.swift` — `ARCStorage` dependency removed; it was declared for
  `ARCMetadataManager` but never imported in any source file

## [1.0.0] - 2026-03-18

### Added

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
