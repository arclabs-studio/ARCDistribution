import Foundation

/// Base URL for App Store Connect API v1.
public let ascBaseURL = URL(string: "https://api.appstoreconnect.apple.com/v1")!

// MARK: - Endpoint Paths

public enum ASCEndpoint {
    public static func apps() -> URL {
        ascBaseURL.appending(path: "apps")
    }

    public static func builds(appId: String) -> URL {
        ascBaseURL.appending(path: "apps").appending(path: appId).appending(path: "builds")
    }

    public static func appStoreVersions(appId: String) -> URL {
        ascBaseURL.appending(path: "apps").appending(path: appId).appending(path: "appStoreVersions")
    }

    public static func submitForReview(versionId: String) -> URL {
        ascBaseURL.appending(path: "appStoreVersionSubmissions")
    }

    public static func appStoreVersionLocalizations(versionId: String) -> URL {
        ascBaseURL
            .appending(path: "appStoreVersions")
            .appending(path: versionId)
            .appending(path: "appStoreVersionLocalizations")
    }

    public static func localization(localizationId: String) -> URL {
        ascBaseURL
            .appending(path: "appStoreVersionLocalizations")
            .appending(path: localizationId)
    }
}
