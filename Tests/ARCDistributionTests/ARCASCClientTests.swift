import ARCASCClient
import ARCASCModels
import ARCDistributionMocks
import Foundation
import Testing

@Suite("AppStoreConnectClient")
struct ARCASCClientTests {
    // MARK: - fetchBuilds

    @Test("Returns stubbed builds for given app ID", .tags(.unit)) func fetchBuildsReturnsStubbedBuilds() async throws {
        // Given
        let (sut, mock) = makeSUT()
        mock.stubbedBuilds = try [makeStubBuild(id: "build-1", version: "42"),
                                  makeStubBuild(id: "build-2", version: "43")]

        // When
        let builds = try await sut.fetchBuilds(appId: "app-123", limit: 10)

        // Then
        #expect(builds.count == 2)
        #expect(mock.fetchBuildsCallCount == 1)
        #expect(mock.lastFetchBuildsAppId == "app-123")
    }

    @Test("Propagates error from fetchBuilds", .tags(.unit)) func fetchBuildsThrowsWhenErrorStubbed() async throws {
        // Given
        let (sut, mock) = makeSUT()
        mock.fetchBuildsError = ASCClientError.httpError(statusCode: 401)

        // When/Then
        await #expect(throws: ASCClientError.self) {
            try await sut.fetchBuilds(appId: "app-123", limit: 10)
        }
    }

    // MARK: - submitForReview

    @Test("Tracks submit call count and version ID", .tags(.unit)) func submitForReviewTracksCall() async throws {
        // Given
        let (sut, mock) = makeSUT()

        // When
        try await sut.submitForReview(versionId: "version-abc")

        // Then
        #expect(mock.submitForReviewCallCount == 1)
        #expect(mock.lastSubmittedVersionId == "version-abc")
    }

    // MARK: - uploadMetadata

    @Test("Uploads metadata and tracks last upload", .tags(.unit)) func uploadMetadataTracksCall() async throws {
        // Given
        let (sut, mock) = makeSUT()
        let metadata = makeStubMetadata()

        // When
        try await sut.uploadMetadata(metadata, versionId: "v-1")

        // Then
        #expect(mock.uploadMetadataCallCount == 1)
        #expect(mock.lastUploadedMetadata?.appId == "FavRes")
        #expect(mock.lastUploadedMetadata?.locale == "en-US")
    }

    // MARK: - fetchApps

    @Test("fetchApps returns stubbed apps", .tags(.unit)) func fetchAppsReturnsStubbedApps() async throws {
        // Given
        let (_, mock) = makeSUT()
        mock.stubbedApps = try [makeStubApp(id: "app-1", bundleId: "com.example")]

        // When
        let apps = try await mock.fetchApps()

        // Then
        #expect(apps.count == 1)
        #expect(mock.fetchAppsCallCount == 1)
    }

    @Test("fetchApps throws when fetchAppsError is set", .tags(.unit))
    func fetchAppsThrowsWhenErrorStubbed() async throws {
        // Given
        let (_, mock) = makeSUT()
        mock.fetchAppsError = ASCClientError.httpError(statusCode: 403)

        // When / Then
        await #expect(throws: ASCClientError.self) {
            try await mock.fetchApps()
        }
    }

    // MARK: - fetchCurrentVersion

    @Test("fetchCurrentVersion returns stubbed version", .tags(.unit))
    func fetchCurrentVersionReturnsStubbedVersion() async throws {
        // Given
        let (_, mock) = makeSUT()
        mock.stubbedVersion = try makeStubVersion(id: "v-1", platform: "IOS")

        // When
        let version = try await mock.fetchCurrentVersion(appId: "app-1", platform: .iOS)

        // Then
        #expect(version.id == "v-1")
        #expect(mock.fetchCurrentVersionCallCount == 1)
        #expect(mock.lastFetchCurrentVersionAppId == "app-1")
    }

    @Test("fetchCurrentVersion throws noVersionFound when stubbedVersion is nil", .tags(.unit))
    func fetchCurrentVersionThrowsNoVersionFound() async throws {
        // Given
        let (_, mock) = makeSUT()
        // stubbedVersion is nil by default

        // When / Then
        await #expect(throws: ASCClientError.self) {
            try await mock.fetchCurrentVersion(appId: "app-1", platform: .iOS)
        }
        #expect(mock.fetchCurrentVersionCallCount == 1)
    }

    @Test("fetchCurrentVersion throws fetchVersionError when error is set", .tags(.unit))
    func fetchCurrentVersionThrowsFetchVersionError() async throws {
        // Given
        let (_, mock) = makeSUT()
        mock.fetchVersionError = ASCClientError.httpError(statusCode: 500)

        // When / Then
        await #expect(throws: ASCClientError.self) {
            try await mock.fetchCurrentVersion(appId: "app-1", platform: .iOS)
        }
    }

    // MARK: - submitForReview — error

    @Test("submitForReview throws submitForReviewError when set", .tags(.unit))
    func submitForReviewThrowsWhenErrorStubbed() async throws {
        // Given
        let (_, mock) = makeSUT()
        mock.submitForReviewError = ASCClientError.httpError(statusCode: 409)

        // When / Then
        await #expect(throws: ASCClientError.self) {
            try await mock.submitForReview(versionId: "v-1")
        }
    }

    // MARK: - uploadMetadata — error

    @Test("uploadMetadata throws uploadMetadataError when set", .tags(.unit))
    func uploadMetadataThrowsWhenErrorStubbed() async throws {
        // Given
        let (_, mock) = makeSUT()
        mock.uploadMetadataError = ASCClientError.httpError(statusCode: 422)

        // When / Then
        await #expect(throws: ASCClientError.self) {
            try await mock.uploadMetadata(makeStubMetadata(), versionId: "v-1")
        }
    }

    // MARK: - fetchLocalizations

    @Test("fetchLocalizations returns stubbed localizations", .tags(.unit))
    func fetchLocalizationsReturnsStubbedLocalizations() async throws {
        // Given
        let (_, mock) = makeSUT()
        mock.stubbedLocalizations = try [makeStubLocalization(id: "loc-1", locale: "en-US")]

        // When
        let localizations = try await mock.fetchLocalizations(versionId: "v-1")

        // Then
        #expect(localizations.count == 1)
        #expect(localizations[0].id == "loc-1")
        #expect(localizations[0].attributes.locale == "en-US")
    }

    // MARK: - SUT Factory

    private func makeSUT() -> (AppStoreConnectClientProtocol, MockAppStoreConnectClient) {
        let mock = MockAppStoreConnectClient()
        return (mock, mock)
    }
}

// MARK: - Test Helpers

private func makeStubBuild(id: String, version: String) throws -> Build {
    let json = Data("""
    {
        "id": "\(id)",
        "type": "builds",
        "attributes": {
            "version": "\(version)",
            "expired": false,
            "processingState": "VALID",
            "buildAudienceType": "APP_STORE_ELIGIBLE",
            "usesNonExemptEncryption": false
        }
    }
    """.utf8)
    return try JSONDecoder().decode(Build.self, from: json)
}

private func makeStubMetadata() -> AppMetadata {
    AppMetadata(appId: "FavRes",
                locale: "en-US",
                name: "FavRes",
                subtitle: "Save & Revisit Restaurants",
                keywords: "restaurant,food,favorites,save",
                description: "Discover and save your favorite restaurants.",
                releaseNotes: "Bug fixes and performance improvements.")
}

private func makeStubApp(id: String, bundleId: String) throws -> App {
    let json = Data("""
    {
        "id": "\(id)",
        "type": "apps",
        "attributes": {
            "bundleId": "\(bundleId)",
            "name": "Example",
            "primaryLocale": "en-US",
            "sku": "SKU1"
        }
    }
    """.utf8)
    return try JSONDecoder().decode(App.self, from: json)
}

private func makeStubVersion(id: String, platform: String) throws -> AppStoreVersion {
    let json = Data("""
    {
        "id": "\(id)",
        "type": "appStoreVersions",
        "attributes": {
            "platform": "\(platform)",
            "versionString": "1.0",
            "appStoreState": "PREPARE_FOR_SUBMISSION"
        }
    }
    """.utf8)
    return try JSONDecoder().decode(AppStoreVersion.self, from: json)
}

private func makeStubLocalization(id: String, locale: String) throws -> AppStoreVersionLocalization {
    let json = Data("""
    {
        "id": "\(id)",
        "type": "appStoreVersionLocalizations",
        "attributes": {
            "locale": "\(locale)"
        }
    }
    """.utf8)
    return try JSONDecoder().decode(AppStoreVersionLocalization.self, from: json)
}
