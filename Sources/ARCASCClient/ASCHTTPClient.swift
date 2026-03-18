import ARCASCModels
import ARCNetworking
import Foundation

/// ASC-aware HTTP client that injects JWT authentication, normalizes empty
/// response bodies for 201/204 endpoints, and maps non-2xx responses to ASC errors.
///
/// Use this as the production `HTTPClientProtocol` inside `AppStoreConnectClient`.
/// Inject a stub `HTTPClientProtocol` in tests via `AppStoreConnectClient.init(httpClient:logger:)`.
final class ASCHTTPClient: HTTPClientProtocol {
    private let jwtGenerator: JWTGenerator
    private let session: URLSession
    private let builder: any RequestBuilderProtocol
    private let decoder: JSONDecoder

    init(jwtGenerator: JWTGenerator,
         session: URLSession = .shared,
         builder: any RequestBuilderProtocol = RequestBuilder(),
         decoder: JSONDecoder = JSONDecoder()) {
        self.jwtGenerator = jwtGenerator
        self.session = session
        self.builder = builder
        self.decoder = decoder
    }

    func execute<T: Endpoint>(_ endpoint: T) async throws -> T.Response {
        var request = try builder.buildRequest(from: endpoint)

        let token = try jwtGenerator.generateToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw ASCClientError.invalidResponse
        }

        guard (200 ..< 300).contains(http.statusCode) else {
            if let ascError = try? JSONDecoder().decode(ASCError.self, from: data) {
                throw ascError
            }
            throw ASCClientError.httpError(statusCode: http.statusCode)
        }

        let body = data.isEmpty ? Data("{}".utf8) : data
        return try decoder.decode(T.Response.self, from: body)
    }
}
