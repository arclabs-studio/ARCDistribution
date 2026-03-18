# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
