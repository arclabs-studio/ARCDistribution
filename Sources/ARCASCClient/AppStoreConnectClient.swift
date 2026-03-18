import ARCASCModels
import ARCLogger
import Foundation

/// Live implementation of `AppStoreConnectClientProtocol`.
///
/// Uses JWT authentication and URLSession to call the App Store Connect API v1.
///
/// - Note: Inject `ARCDistributionMocks.MockAppStoreConnectClient` in tests.
public final class AppStoreConnectClient: AppStoreConnectClientProtocol {

    private let credentials: ASCCredentials
    private let session: URLSession
    private let logger: any Logger
    private let jwtGenerator: JWTGenerator

    public init(
        credentials: ASCCredentials,
        session: URLSession = .shared,
        logger: any Logger = ARCLogger()
    ) {
        self.credentials = credentials
        self.session = session
        self.logger = logger
        self.jwtGenerator = JWTGenerator(
            keyId: credentials.keyId,
            issuerId: credentials.issuerId,
            privateKeyPEM: credentials.privateKeyPEM
        )
    }

    // MARK: - AppStoreConnectClientProtocol

    public func fetchApps() async throws -> [App] {
        let url = ASCEndpoint.apps()
        let response: ASCListResponse<App> = try await get(url: url)
        return response.data
    }

    public func fetchBuilds(appId: String, limit: Int = 20) async throws -> [Build] {
        var components = URLComponents(url: ASCEndpoint.builds(appId: appId), resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "sort", value: "-uploadedDate")
        ]
        guard let url = components?.url else { throw ASCClientError.invalidURL }
        let response: ASCListResponse<Build> = try await get(url: url)
        return response.data
    }

    public func fetchCurrentVersion(appId: String, platform: Platform) async throws -> AppStoreVersion {
        var components = URLComponents(
            url: ASCEndpoint.appStoreVersions(appId: appId),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "filter[platform]", value: platform.rawValue),
            URLQueryItem(name: "filter[appStoreState]", value: "PREPARE_FOR_SUBMISSION")
        ]
        guard let url = components?.url else { throw ASCClientError.invalidURL }
        let response: ASCListResponse<AppStoreVersion> = try await get(url: url)
        guard let version = response.data.first else {
            throw ASCClientError.noVersionFound(appId: appId, platform: platform.rawValue)
        }
        return version
    }

    public func submitForReview(versionId: String) async throws {
        let url = ASCEndpoint.submitForReview(versionId: versionId)
        let body: [String: Any] = [
            "data": [
                "type": "appStoreVersionSubmissions",
                "relationships": [
                    "appStoreVersion": [
                        "data": ["type": "appStoreVersions", "id": versionId]
                    ]
                ]
            ]
        ]
        try await post(url: url, body: body)
        logger.info("Submitted version \(versionId) for review")
    }

    public func uploadMetadata(_ metadata: AppMetadata, versionId: String) async throws {
        let localizations = try await fetchLocalizations(versionId: versionId)

        if let existing = localizations.first(where: { $0.attributes.locale == metadata.locale }) {
            try await patchLocalization(id: existing.id, metadata: metadata)
        } else {
            try await createLocalization(versionId: versionId, metadata: metadata)
        }
        logger.info("Uploaded metadata for \(metadata.appId) [\(metadata.locale)]")
    }

    public func fetchLocalizations(versionId: String) async throws -> [AppStoreVersionLocalization] {
        let url = ASCEndpoint.appStoreVersionLocalizations(versionId: versionId)
        let response: ASCListResponse<AppStoreVersionLocalization> = try await get(url: url)
        return response.data
    }

    // MARK: - Private HTTP Helpers

    private func makeRequest(url: URL, method: String) throws -> URLRequest {
        let token = try jwtGenerator.generateToken()
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func get<T: Decodable>(url: URL) async throws -> T {
        let request = try makeRequest(url: url, method: "GET")
        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func post(url: URL, body: [String: Any]) async throws {
        var request = try makeRequest(url: url, method: "POST")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
    }

    private func patch(url: URL, body: [String: Any]) async throws {
        var request = try makeRequest(url: url, method: "PATCH")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
    }

    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { throw ASCClientError.invalidResponse }
        guard (200 ..< 300).contains(http.statusCode) else {
            if let ascError = try? JSONDecoder().decode(ASCError.self, from: data) {
                throw ascError
            }
            throw ASCClientError.httpError(statusCode: http.statusCode)
        }
    }

    private func patchLocalization(id: String, metadata: AppMetadata) async throws {
        let url = ASCEndpoint.localization(localizationId: id)
        let body: [String: Any] = [
            "data": [
                "type": "appStoreVersionLocalizations",
                "id": id,
                "attributes": [
                    "description": metadata.description,
                    "keywords": metadata.keywords,
                    "whatsNew": metadata.releaseNotes
                ]
            ]
        ]
        try await patch(url: url, body: body)
    }

    private func createLocalization(versionId: String, metadata: AppMetadata) async throws {
        let url = ASCEndpoint.appStoreVersionLocalizations(versionId: versionId)
        let body: [String: Any] = [
            "data": [
                "type": "appStoreVersionLocalizations",
                "attributes": [
                    "locale": metadata.locale,
                    "description": metadata.description,
                    "keywords": metadata.keywords,
                    "whatsNew": metadata.releaseNotes
                ],
                "relationships": [
                    "appStoreVersion": [
                        "data": ["type": "appStoreVersions", "id": versionId]
                    ]
                ]
            ]
        ]
        try await post(url: url, body: body)
    }
}

// MARK: - Errors

public enum ASCClientError: Error, Sendable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case noVersionFound(appId: String, platform: String)
}
