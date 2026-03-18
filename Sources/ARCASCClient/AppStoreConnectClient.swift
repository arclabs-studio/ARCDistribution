import ARCASCModels
import ARCLogger
import ARCNetworking
import Foundation

/// Live implementation of `AppStoreConnectClientProtocol`.
///
/// Uses JWT authentication via `BearerTokenInterceptor` and maps ASC error
/// responses via `ASCErrorInterceptor` before decoding.
///
/// - Note: Inject `ARCDistributionMocks.MockAppStoreConnectClient` in tests.
public final class AppStoreConnectClient: AppStoreConnectClientProtocol {
    private let httpClient: any HTTPClientProtocol
    private let logger: any Logger

    public init(credentials: ASCCredentials, logger: any Logger = ARCLogger()) {
        let jwtGenerator = JWTGenerator(keyId: credentials.keyId,
                                        issuerId: credentials.issuerId,
                                        privateKeyPEM: credentials.privateKeyPEM)
        httpClient = HTTPClient(interceptors: [BearerTokenInterceptor { try jwtGenerator.generateToken() },
                                               ASCErrorInterceptor(),
                                               LoggingInterceptor()])
        self.logger = logger
    }

    /// Internal initializer for unit tests — inject a stub `HTTPClientProtocol`
    /// to exercise the client without hitting the network.
    init(httpClient: any HTTPClientProtocol, logger: any Logger = ARCLogger()) {
        self.httpClient = httpClient
        self.logger = logger
    }

    // MARK: - AppStoreConnectClientProtocol

    public func fetchApps() async throws -> [App] {
        let response = try await httpClient.execute(FetchAppsEndpoint())
        return response.data
    }

    public func fetchBuilds(appId: String, limit: Int = 20) async throws -> [Build] {
        let response = try await httpClient.execute(FetchBuildsEndpoint(appId: appId, limit: limit))
        return response.data
    }

    public func fetchCurrentVersion(appId: String, platform: Platform) async throws -> AppStoreVersion {
        let response = try await httpClient.execute(FetchAppStoreVersionsEndpoint(appId: appId, platform: platform))
        guard let version = response.data.first else {
            throw ASCClientError.noVersionFound(appId: appId, platform: platform.rawValue)
        }
        return version
    }

    public func submitForReview(versionId: String) async throws {
        _ = try await httpClient.execute(SubmitForReviewEndpoint(versionId: versionId))
        logger.info("Submitted version \(versionId) for review")
    }

    public func uploadMetadata(_ metadata: AppMetadata, versionId: String) async throws {
        let localizations = try await fetchLocalizations(versionId: versionId)

        if let existing = localizations.first(where: { $0.attributes.locale == metadata.locale }) {
            _ = try await httpClient.execute(PatchLocalizationEndpoint(localizationId: existing.id, metadata: metadata))
        } else {
            _ = try await httpClient.execute(CreateLocalizationEndpoint(versionId: versionId, metadata: metadata))
        }
        logger.info("Uploaded metadata for \(metadata.appId) [\(metadata.locale)]")
    }

    public func fetchLocalizations(versionId: String) async throws -> [AppStoreVersionLocalization] {
        let response = try await httpClient.execute(FetchLocalizationsEndpoint(versionId: versionId))
        return response.data
    }
}

// MARK: - Errors

public enum ASCClientError: Error, Sendable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case noVersionFound(appId: String, platform: String)
}
