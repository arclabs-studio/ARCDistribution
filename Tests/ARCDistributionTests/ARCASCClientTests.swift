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
