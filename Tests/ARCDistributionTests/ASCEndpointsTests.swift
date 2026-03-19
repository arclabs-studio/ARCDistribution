import ARCASCModels
import Foundation
import Testing
@testable import ARCASCClient

@Suite("ASC Endpoints")
struct ASCEndpointsTests {
    // MARK: - FetchAppsEndpoint

    @Test("FetchAppsEndpoint has correct path and method", .tags(.unit)) func fetchAppsEndpointPath() {
        // Given
        let sut = FetchAppsEndpoint()

        // Then
        #expect(sut.path == "apps")
        #expect(sut.method == .GET)
        #expect(sut.queryItems == nil)
        #expect(sut.body == nil)
    }

    // MARK: - FetchBuildsEndpoint

    @Test("FetchBuildsEndpoint embeds appId in path and adds query items", .tags(.unit))
    func fetchBuildsEndpointPathAndQueryItems() throws {
        // Given
        let sut = FetchBuildsEndpoint(appId: "app-42", limit: 5)

        // Then
        #expect(sut.path == "apps/app-42/builds")
        #expect(sut.method == .GET)

        let items = try #require(sut.queryItems)
        let limitItem = try #require(items.first { $0.name == "limit" })
        let sortItem = try #require(items.first { $0.name == "sort" })
        #expect(limitItem.value == "5")
        #expect(sortItem.value == "-uploadedDate")
    }

    // MARK: - FetchAppStoreVersionsEndpoint

    @Test("FetchAppStoreVersionsEndpoint embeds appId and filters by platform", .tags(.unit))
    func fetchAppStoreVersionsEndpointFilters() throws {
        // Given
        let sut = FetchAppStoreVersionsEndpoint(appId: "app-99", platform: .iOS)

        // Then
        #expect(sut.path == "apps/app-99/appStoreVersions")
        #expect(sut.method == .GET)

        let items = try #require(sut.queryItems)
        let platformItem = try #require(items.first { $0.name == "filter[platform]" })
        let stateItem = try #require(items.first { $0.name == "filter[appStoreState]" })
        #expect(platformItem.value == "IOS")
        #expect(stateItem.value == "PREPARE_FOR_SUBMISSION")
    }

    // MARK: - SubmitForReviewEndpoint

    @Test("SubmitForReviewEndpoint uses POST with version relationship in body", .tags(.unit))
    func submitForReviewEndpoint() throws {
        // Given
        let sut = SubmitForReviewEndpoint(versionId: "ver-7")

        // Then
        #expect(sut.path == "appStoreVersionSubmissions")
        #expect(sut.method == .POST)

        let bodyData = try #require(sut.body)
        let json = try #require(try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any])
        let data = try #require(json["data"] as? [String: Any])
        #expect(data["type"] as? String == "appStoreVersionSubmissions")

        let relationships = try #require(data["relationships"] as? [String: Any])
        let versionRel = try #require(relationships["appStoreVersion"] as? [String: Any])
        let relData = try #require(versionRel["data"] as? [String: Any])
        #expect(relData["id"] as? String == "ver-7")
    }

    // MARK: - FetchLocalizationsEndpoint

    @Test("FetchLocalizationsEndpoint embeds versionId in path", .tags(.unit)) func fetchLocalizationsEndpointPath() {
        // Given
        let sut = FetchLocalizationsEndpoint(versionId: "ver-3")

        // Then
        #expect(sut.path == "appStoreVersions/ver-3/appStoreVersionLocalizations")
        #expect(sut.method == .GET)
        #expect(sut.body == nil)
    }

    // MARK: - CreateLocalizationEndpoint

    @Test("CreateLocalizationEndpoint uses POST with locale and metadata attributes", .tags(.unit))
    func createLocalizationEndpoint() throws {
        // Given
        let metadata = makeStubMetadata(locale: "es-MX", keywords: "restaurante,comida")
        let sut = CreateLocalizationEndpoint(versionId: "ver-5", metadata: metadata)

        // Then
        #expect(sut.path == "appStoreVersions/ver-5/appStoreVersionLocalizations")
        #expect(sut.method == .POST)

        let bodyData = try #require(sut.body)
        let json = try #require(try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any])
        let data = try #require(json["data"] as? [String: Any])
        let attributes = try #require(data["attributes"] as? [String: Any])
        #expect(attributes["locale"] as? String == "es-MX")
        #expect(attributes["keywords"] as? String == "restaurante,comida")
    }

    // MARK: - PatchLocalizationEndpoint

    @Test("PatchLocalizationEndpoint uses PATCH with localizationId in path and updated attributes", .tags(.unit))
    func patchLocalizationEndpoint() throws {
        // Given
        let metadata = makeStubMetadata(locale: "en-US", keywords: "food,favorites")
        let sut = PatchLocalizationEndpoint(localizationId: "loc-11", metadata: metadata)

        // Then
        #expect(sut.path == "appStoreVersionLocalizations/loc-11")
        #expect(sut.method == .PATCH)

        let bodyData = try #require(sut.body)
        let json = try #require(try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any])
        let data = try #require(json["data"] as? [String: Any])
        #expect(data["id"] as? String == "loc-11")
        let attributes = try #require(data["attributes"] as? [String: Any])
        #expect(attributes["keywords"] as? String == "food,favorites")
    }

    // MARK: - BaseURL

    @Test("All endpoints share the ASC v1 base URL", .tags(.unit)) func allEndpointsShareBaseURL() {
        let baseURLString = "https://api.appstoreconnect.apple.com/v1"
        #expect(FetchAppsEndpoint().baseURL.absoluteString == baseURLString)
        #expect(FetchBuildsEndpoint(appId: "x", limit: 1).baseURL.absoluteString == baseURLString)
        #expect(SubmitForReviewEndpoint(versionId: "v").baseURL.absoluteString == baseURLString)
    }
}

// MARK: - Helpers

private func makeStubMetadata(locale: String = "en-US", keywords: String = "food") -> AppMetadata {
    AppMetadata(appId: "app-1",
                locale: locale,
                name: "App Name",
                subtitle: "Subtitle",
                keywords: keywords,
                description: "Description",
                releaseNotes: "What's new")
}
