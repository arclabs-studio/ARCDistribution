# ``ARCDistribution``

App Store distribution automation for ARC Labs Studio apps.

## Overview

ARCDistribution provides everything needed to automate App Store Connect
workflows from Xcode Cloud `ci_scripts/` or the terminal:

- **ASC API Client** — JWT-authenticated HTTP client for App Store Connect API v1,
  built on ARCNetworking's interceptor chain
- **Metadata Manager** — Read and write localized metadata from the iCloud
  Distribution folder using a file-per-field layout
- **CLI Tool** — `arc-distribution` executable for build listing, metadata sync,
  submission, and validation
- **Test Doubles** — `MockAppStoreConnectClient` and `MockMetadataRepository`
  for deterministic unit tests

## Topics

### App Store Connect Client

- ``AppStoreConnectClientProtocol``
- ``AppStoreConnectClient``
- ``ASCCredentials``
- ``ASCClientError``

### Models

- ``App``
- ``Build``
- ``AppStoreVersion``
- ``AppStoreVersionLocalization``
- ``AppMetadata``
- ``EmptyResponse``
- ``ASCError``

### Metadata Management

- ``MetadataRepositoryProtocol``
- ``FileMetadataRepository``
- ``MetadataValidator``

### Test Doubles

- ``MockAppStoreConnectClient``
- ``MockMetadataRepository``
