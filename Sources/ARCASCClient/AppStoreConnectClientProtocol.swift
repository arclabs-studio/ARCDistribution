import ARCASCModels
import Foundation

/// Abstraction over the App Store Connect API.
/// Inject this protocol in consumers — use `ARCDistributionMocks.MockAppStoreConnectClient` in tests.
public protocol AppStoreConnectClientProtocol: Sendable {

    // MARK: Apps

    /// Returns all apps accessible with the configured API key.
    func fetchApps() async throws -> [App]

    // MARK: Builds

    /// Returns builds for the given app, sorted newest first.
    func fetchBuilds(appId: String, limit: Int) async throws -> [Build]

    // MARK: App Store Versions

    /// Returns the current editable version for the given app and platform.
    func fetchCurrentVersion(appId: String, platform: Platform) async throws -> AppStoreVersion

    /// Submits the version to App Review.
    func submitForReview(versionId: String) async throws

    // MARK: Metadata

    /// Uploads all locale metadata fields to the given version.
    func uploadMetadata(_ metadata: AppMetadata, versionId: String) async throws

    /// Fetches all localizations for the given version.
    func fetchLocalizations(versionId: String) async throws -> [AppStoreVersionLocalization]
}
