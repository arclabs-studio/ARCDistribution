import ARCASCClient
import ARCASCModels
import Foundation

/// Test double for `AppStoreConnectClientProtocol`.
///
/// ```swift
/// let mock = MockAppStoreConnectClient()
/// mock.stubbedBuilds = [Build(id: "123", ...)]
/// let sut = MyFeature(client: mock)
/// ```
public final class MockAppStoreConnectClient: AppStoreConnectClientProtocol, @unchecked Sendable {

    // MARK: - Stubs

    public var stubbedApps: [App] = []
    public var stubbedBuilds: [Build] = []
    public var stubbedVersion: AppStoreVersion?
    public var stubbedLocalizations: [AppStoreVersionLocalization] = []

    // MARK: - Errors (throw these to simulate failures)

    public var fetchAppsError: Error?
    public var fetchBuildsError: Error?
    public var fetchVersionError: Error?
    public var submitForReviewError: Error?
    public var uploadMetadataError: Error?

    // MARK: - Call Tracking

    public private(set) var fetchAppsCallCount = 0
    public private(set) var fetchBuildsCallCount = 0
    public private(set) var lastFetchBuildsAppId: String?
    public private(set) var submitForReviewCallCount = 0
    public private(set) var lastSubmittedVersionId: String?
    public private(set) var uploadMetadataCallCount = 0
    public private(set) var lastUploadedMetadata: AppMetadata?

    public init() {}

    // MARK: - AppStoreConnectClientProtocol

    public func fetchApps() async throws -> [App] {
        fetchAppsCallCount += 1
        if let error = fetchAppsError { throw error }
        return stubbedApps
    }

    public func fetchBuilds(appId: String, limit: Int) async throws -> [Build] {
        fetchBuildsCallCount += 1
        lastFetchBuildsAppId = appId
        if let error = fetchBuildsError { throw error }
        return stubbedBuilds
    }

    public func fetchCurrentVersion(appId: String, platform: Platform) async throws -> AppStoreVersion {
        if let error = fetchVersionError { throw error }
        guard let version = stubbedVersion else {
            throw ASCClientError.noVersionFound(appId: appId, platform: platform.rawValue)
        }
        return version
    }

    public func submitForReview(versionId: String) async throws {
        submitForReviewCallCount += 1
        lastSubmittedVersionId = versionId
        if let error = submitForReviewError { throw error }
    }

    public func uploadMetadata(_ metadata: AppMetadata, versionId: String) async throws {
        uploadMetadataCallCount += 1
        lastUploadedMetadata = metadata
        if let error = uploadMetadataError { throw error }
    }

    public func fetchLocalizations(versionId: String) async throws -> [AppStoreVersionLocalization] {
        return stubbedLocalizations
    }
}
