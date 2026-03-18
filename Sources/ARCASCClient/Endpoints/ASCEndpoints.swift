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

// MARK: - Endpoint Structs

struct FetchAppsEndpoint: Endpoint {
    typealias Response = ASCListResponse<App>

    var baseURL: URL {
        ascBaseURL
    }

    var path: String {
        "apps"
    }

    var method: HTTPMethod {
        .GET
    }

    var headers: [String: String]? {
        nil
    }

    var queryItems: [URLQueryItem]? {
        nil
    }

    var body: Data? {
        nil
    }
}

struct FetchBuildsEndpoint: Endpoint {
    typealias Response = ASCListResponse<Build>

    let appId: String
    let limit: Int

    var baseURL: URL {
        ascBaseURL
    }

    var path: String {
        "apps/\(appId)/builds"
    }

    var method: HTTPMethod {
        .GET
    }

    var headers: [String: String]? {
        nil
    }

    var queryItems: [URLQueryItem]? {
        [URLQueryItem(name: "limit", value: "\(limit)"),
         URLQueryItem(name: "sort", value: "-uploadedDate")]
    }

    var body: Data? {
        nil
    }
}

struct FetchAppStoreVersionsEndpoint: Endpoint {
    typealias Response = ASCListResponse<AppStoreVersion>

    let appId: String
    let platform: Platform

    var baseURL: URL {
        ascBaseURL
    }

    var path: String {
        "apps/\(appId)/appStoreVersions"
    }

    var method: HTTPMethod {
        .GET
    }

    var headers: [String: String]? {
        nil
    }

    var queryItems: [URLQueryItem]? {
        [URLQueryItem(name: "filter[platform]", value: platform.rawValue),
         URLQueryItem(name: "filter[appStoreState]", value: "PREPARE_FOR_SUBMISSION")]
    }

    var body: Data? {
        nil
    }
}

struct SubmitForReviewEndpoint: Endpoint {
    typealias Response = EmptyResponse

    let versionId: String

    var baseURL: URL {
        ascBaseURL
    }

    var path: String {
        "appStoreVersionSubmissions"
    }

    var method: HTTPMethod {
        .POST
    }

    var headers: [String: String]? {
        nil
    }

    var queryItems: [URLQueryItem]? {
        nil
    }

    var body: Data? {
        let dict: [String: Any] = ["data": ["type": "appStoreVersionSubmissions",
                                            "relationships": ["appStoreVersion": ["data": ["type": "appStoreVersions",
                                                                                           "id": versionId]]]]]
        return try? JSONSerialization.data(withJSONObject: dict)
    }
}

struct FetchLocalizationsEndpoint: Endpoint {
    typealias Response = ASCListResponse<AppStoreVersionLocalization>

    let versionId: String

    var baseURL: URL {
        ascBaseURL
    }

    var path: String {
        "appStoreVersions/\(versionId)/appStoreVersionLocalizations"
    }

    var method: HTTPMethod {
        .GET
    }

    var headers: [String: String]? {
        nil
    }

    var queryItems: [URLQueryItem]? {
        nil
    }

    var body: Data? {
        nil
    }
}

struct CreateLocalizationEndpoint: Endpoint {
    typealias Response = EmptyResponse

    let versionId: String
    let metadata: AppMetadata

    var baseURL: URL {
        ascBaseURL
    }

    var path: String {
        "appStoreVersions/\(versionId)/appStoreVersionLocalizations"
    }

    var method: HTTPMethod {
        .POST
    }

    var headers: [String: String]? {
        nil
    }

    var queryItems: [URLQueryItem]? {
        nil
    }

    var body: Data? {
        let dict: [String: Any] = ["data": ["type": "appStoreVersionLocalizations",
                                            "attributes": ["locale": metadata.locale,
                                                           "description": metadata.description,
                                                           "keywords": metadata.keywords,
                                                           "whatsNew": metadata.releaseNotes],
                                            "relationships": ["appStoreVersion": ["data": ["type": "appStoreVersions",
                                                                                           "id": versionId]]]]]
        return try? JSONSerialization.data(withJSONObject: dict)
    }
}

struct PatchLocalizationEndpoint: Endpoint {
    typealias Response = EmptyResponse

    let localizationId: String
    let metadata: AppMetadata

    var baseURL: URL {
        ascBaseURL
    }

    var path: String {
        "appStoreVersionLocalizations/\(localizationId)"
    }

    var method: HTTPMethod {
        .PATCH
    }

    var headers: [String: String]? {
        nil
    }

    var queryItems: [URLQueryItem]? {
        nil
    }

    var body: Data? {
        let dict: [String: Any] = ["data": ["type": "appStoreVersionLocalizations",
                                            "id": localizationId,
                                            "attributes": ["description": metadata.description,
                                                           "keywords": metadata.keywords,
                                                           "whatsNew": metadata.releaseNotes]]]
        return try? JSONSerialization.data(withJSONObject: dict)
    }
}
