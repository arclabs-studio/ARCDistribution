import ARCASCModels
import ARCNetworking
import Foundation
import Testing
@testable import ARCASCClient

// MARK: - Stub

private final class StubHTTPClient: HTTPClientProtocol, @unchecked Sendable {
    var responses: [Data] = []
    var stubbedError: Error?
    private var callIndex = 0

    func execute<T: Endpoint>(_: T) async throws -> T.Response {
        if let error = stubbedError { throw error }
        let data = responses[callIndex % responses.count]
        callIndex += 1
        return try JSONDecoder().decode(T.Response.self, from: data)
    }
}

// MARK: - Suite

@Suite("AppStoreConnectClient live")
struct AppStoreConnectClientLiveTests {
    // MARK: - public init

    @Test("init(credentials:) builds client without throwing", .tags(.unit)) func initWithCredentialsSucceeds() {
        // The public init only wires up interceptors — no network call, no key validation.
        let credentials = ASCCredentials(keyId: "test-key",
                                         issuerId: "test-issuer",
                                         privateKeyPEM: "dummy-pem")
        _ = AppStoreConnectClient(credentials: credentials)
    }

    // MARK: - fetchApps

    @Test("fetchApps returns decoded apps", .tags(.unit)) func fetchAppsReturnsDecodedApps() async throws {
        let stub = makeStub(responses: [appsListJSON()])
        let sut = AppStoreConnectClient(httpClient: stub)

        let apps = try await sut.fetchApps()

        #expect(apps.count == 1)
        #expect(apps[0].id == "app-1")
        #expect(apps[0].attributes.bundleId == "com.example.app")
    }

    @Test("fetchApps propagates HTTP error", .tags(.unit)) func fetchAppsPropagatessError() async throws {
        let stub = makeStub(error: HTTPError.requestFailed(statusCode: 401, data: Data()))
        let sut = AppStoreConnectClient(httpClient: stub)

        await #expect(throws: HTTPError.self) {
            try await sut.fetchApps()
        }
    }

    // MARK: - fetchBuilds

    @Test("fetchBuilds returns decoded builds", .tags(.unit)) func fetchBuildsReturnsDecodedBuilds() async throws {
        let stub = makeStub(responses: [buildsListJSON()])
        let sut = AppStoreConnectClient(httpClient: stub)

        let builds = try await sut.fetchBuilds(appId: "app-1", limit: 10)

        #expect(builds.count == 1)
        #expect(builds[0].id == "build-1")
        #expect(builds[0].attributes.version == "42")
    }

    // MARK: - fetchCurrentVersion

    @Test("fetchCurrentVersion returns first version from response", .tags(.unit))
    func fetchCurrentVersionReturnsFirstVersion() async throws {
        let stub = makeStub(responses: [versionsListJSON()])
        let sut = AppStoreConnectClient(httpClient: stub)

        let version = try await sut.fetchCurrentVersion(appId: "app-1", platform: .iOS)

        #expect(version.id == "version-1")
        #expect(version.attributes.platform == .iOS)
        #expect(version.attributes.versionString == "1.0.0")
    }

    @Test("fetchCurrentVersion throws noVersionFound when response list is empty", .tags(.unit))
    func fetchCurrentVersionThrowsNoVersionFoundWhenEmpty() async throws {
        let stub = makeStub(responses: [emptyListJSON()])
        let sut = AppStoreConnectClient(httpClient: stub)

        await #expect(throws: ASCClientError.self) {
            try await sut.fetchCurrentVersion(appId: "app-1", platform: .iOS)
        }
    }

    // MARK: - submitForReview

    @Test("submitForReview succeeds without throwing", .tags(.unit)) func submitForReviewSucceeds() async throws {
        let stub = makeStub(responses: [emptyResponseJSON()])
        let sut = AppStoreConnectClient(httpClient: stub)

        try await sut.submitForReview(versionId: "version-1")
    }

    // MARK: - uploadMetadata — patch path

    @Test("uploadMetadata patches existing localization when locale already exists", .tags(.unit))
    func uploadMetadataPatchesWhenLocaleExists() async throws {
        // First call fetchLocalizations → existing en-US; second call PatchLocalization → empty
        let stub = makeStub(responses: [localizationsListJSON(locale: "en-US"), emptyResponseJSON()])
        let sut = AppStoreConnectClient(httpClient: stub)

        try await sut.uploadMetadata(makeStubMetadata(locale: "en-US"), versionId: "version-1")
    }

    // MARK: - uploadMetadata — create path

    @Test("uploadMetadata creates new localization when locale does not exist", .tags(.unit))
    func uploadMetadataCreatesWhenLocaleAbsent() async throws {
        // First call fetchLocalizations → empty list; second call CreateLocalization → empty
        let stub = makeStub(responses: [emptyListJSON(), emptyResponseJSON()])
        let sut = AppStoreConnectClient(httpClient: stub)

        try await sut.uploadMetadata(makeStubMetadata(locale: "fr-FR"), versionId: "version-1")
    }

    // MARK: - fetchLocalizations

    @Test("fetchLocalizations returns decoded localizations", .tags(.unit))
    func fetchLocalizationsReturnsDecodedLocalizations() async throws {
        let stub = makeStub(responses: [localizationsListJSON(locale: "en-US")])
        let sut = AppStoreConnectClient(httpClient: stub)

        let localizations = try await sut.fetchLocalizations(versionId: "version-1")

        #expect(localizations.count == 1)
        #expect(localizations[0].id == "loc-1")
        #expect(localizations[0].attributes.locale == "en-US")
    }
}

// MARK: - Factories

private func makeStub(responses: [Data] = [], error: Error? = nil) -> StubHTTPClient {
    let stub = StubHTTPClient()
    stub.responses = responses
    stub.stubbedError = error
    return stub
}

private func makeStubMetadata(locale: String) -> AppMetadata {
    AppMetadata(appId: "com.example.app",
                locale: locale,
                name: "Example",
                subtitle: "Subtitle",
                keywords: "example",
                description: "A great app.",
                releaseNotes: "Bug fixes.")
}

// MARK: - JSON Fixtures

private func appsListJSON() -> Data {
    Data("""
    {
        "data": [{
            "id": "app-1",
            "type": "apps",
            "attributes": {
                "bundleId": "com.example.app",
                "name": "Example",
                "primaryLocale": "en-US",
                "sku": "SKU1"
            }
        }]
    }
    """.utf8)
}

private func buildsListJSON() -> Data {
    Data("""
    {
        "data": [{
            "id": "build-1",
            "type": "builds",
            "attributes": {
                "version": "42",
                "expired": false,
                "processingState": "VALID"
            }
        }]
    }
    """.utf8)
}

private func versionsListJSON() -> Data {
    Data("""
    {
        "data": [{
            "id": "version-1",
            "type": "appStoreVersions",
            "attributes": {
                "platform": "IOS",
                "versionString": "1.0.0",
                "appStoreState": "PREPARE_FOR_SUBMISSION"
            }
        }]
    }
    """.utf8)
}

private func localizationsListJSON(locale: String) -> Data {
    Data("""
    {
        "data": [{
            "id": "loc-1",
            "type": "appStoreVersionLocalizations",
            "attributes": {
                "locale": "\(locale)"
            }
        }]
    }
    """.utf8)
}

private func emptyListJSON() -> Data {
    Data(#"{"data":[]}"#.utf8)
}

private func emptyResponseJSON() -> Data {
    Data("{}".utf8)
}
