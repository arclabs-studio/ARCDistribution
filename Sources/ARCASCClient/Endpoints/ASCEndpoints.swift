import ARCASCModels
import ARCNetworking
import Foundation

// MARK: - Base URL

let ascBaseURL: URL = {
    guard let url = URL(string: "https://api.appstoreconnect.apple.com/v1") else {
        fatalError("ascBaseURL: hardcoded URL string is invalid — this is a programming error")
    }
    return url
}()

// MARK: - ASC Endpoint Protocol

/// Refinement of `Endpoint` with App Store Connect defaults.
/// Conforming structs only declare properties they actually customise.
protocol ASCEndpoint: Endpoint {}

extension ASCEndpoint {
    var baseURL: URL { ascBaseURL }
    var headers: [String: String]? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }
}

// MARK: - Endpoint Structs

struct FetchAppsEndpoint: ASCEndpoint {
    typealias Response = ASCListResponse<App>
    var path: String { "apps" }
    var method: HTTPMethod { .GET }
}

struct FetchBuildsEndpoint: ASCEndpoint {
    typealias Response = ASCListResponse<Build>

    let appId: String
    let limit: Int

    var path: String { "apps/\(appId)/builds" }
    var method: HTTPMethod { .GET }
    var queryItems: [URLQueryItem]? {
        [URLQueryItem(name: "limit", value: "\(limit)"),
         URLQueryItem(name: "sort", value: "-uploadedDate")]
    }
}

struct FetchAppStoreVersionsEndpoint: ASCEndpoint {
    typealias Response = ASCListResponse<AppStoreVersion>

    let appId: String
    let platform: Platform

    var path: String { "apps/\(appId)/appStoreVersions" }
    var method: HTTPMethod { .GET }
    var queryItems: [URLQueryItem]? {
        [URLQueryItem(name: "filter[platform]", value: platform.rawValue),
         URLQueryItem(name: "filter[appStoreState]", value: "PREPARE_FOR_SUBMISSION")]
    }
}

struct SubmitForReviewEndpoint: ASCEndpoint {
    typealias Response = EmptyResponse

    let versionId: String

    var path: String { "appStoreVersionSubmissions" }
    var method: HTTPMethod { .POST }
    var body: Data? { try? JSONEncoder().encode(SubmitBody(versionId: versionId)) }
}

struct FetchLocalizationsEndpoint: ASCEndpoint {
    typealias Response = ASCListResponse<AppStoreVersionLocalization>

    let versionId: String

    var path: String { "appStoreVersions/\(versionId)/appStoreVersionLocalizations" }
    var method: HTTPMethod { .GET }
}

struct CreateLocalizationEndpoint: ASCEndpoint {
    typealias Response = EmptyResponse

    let versionId: String
    let metadata: AppMetadata

    var path: String { "appStoreVersions/\(versionId)/appStoreVersionLocalizations" }
    var method: HTTPMethod { .POST }
    var body: Data? { try? JSONEncoder().encode(CreateLocalizationBody(versionId: versionId, metadata: metadata)) }
}

struct PatchLocalizationEndpoint: ASCEndpoint {
    typealias Response = EmptyResponse

    let localizationId: String
    let metadata: AppMetadata

    var path: String { "appStoreVersionLocalizations/\(localizationId)" }
    var method: HTTPMethod { .PATCH }
    var body: Data? { try? JSONEncoder().encode(PatchLocalizationBody(localizationId: localizationId, metadata: metadata)) }
}

// MARK: - JSON:API Request Body Types

private struct ASCVersionRef: Encodable {
    let type = "appStoreVersions"
    let id: String
}

private struct ASCVersionRelationship: Encodable {
    let data: ASCVersionRef
}

private struct ASCVersionRelationships: Encodable {
    let appStoreVersion: ASCVersionRelationship
}

private struct SubmitBody: Encodable {
    struct BodyData: Encodable {
        let type = "appStoreVersionSubmissions"
        let relationships: ASCVersionRelationships
    }

    let data: BodyData

    init(versionId: String) {
        data = BodyData(relationships: ASCVersionRelationships(
            appStoreVersion: ASCVersionRelationship(data: ASCVersionRef(id: versionId))
        ))
    }
}

private struct CreateLocalizationBody: Encodable {
    struct BodyData: Encodable {
        let type = "appStoreVersionLocalizations"
        let attributes: Attributes
        let relationships: ASCVersionRelationships

        struct Attributes: Encodable {
            let locale: String
            let description: String
            let keywords: String
            let whatsNew: String
        }
    }

    let data: BodyData

    init(versionId: String, metadata: AppMetadata) {
        data = BodyData(
            attributes: BodyData.Attributes(
                locale: metadata.locale,
                description: metadata.description,
                keywords: metadata.keywords,
                whatsNew: metadata.releaseNotes
            ),
            relationships: ASCVersionRelationships(
                appStoreVersion: ASCVersionRelationship(data: ASCVersionRef(id: versionId))
            )
        )
    }
}

private struct PatchLocalizationBody: Encodable {
    struct BodyData: Encodable {
        let type = "appStoreVersionLocalizations"
        let id: String
        let attributes: Attributes

        struct Attributes: Encodable {
            let description: String
            let keywords: String
            let whatsNew: String
        }
    }

    let data: BodyData

    init(localizationId: String, metadata: AppMetadata) {
        data = BodyData(
            id: localizationId,
            attributes: BodyData.Attributes(
                description: metadata.description,
                keywords: metadata.keywords,
                whatsNew: metadata.releaseNotes
            )
        )
    }
}
