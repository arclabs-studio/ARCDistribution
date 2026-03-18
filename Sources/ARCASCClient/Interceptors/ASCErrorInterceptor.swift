import ARCASCModels
import ARCNetworking
import Foundation

/// Interceptor that maps App Store Connect API error responses to typed Swift errors.
///
/// Does two things in a single chain position:
/// - **Non-2xx:** decodes `ASCError` from the response body (preserving structured ASC
///   error details); falls back to `ASCClientError.httpError(statusCode:)` if the body
///   is not a valid ASC error envelope.
/// - **2xx with empty body:** normalises `Data()` to `Data("{}".utf8)` so that
///   `EmptyResponse` decodes successfully on 201/204 endpoints.
struct ASCErrorInterceptor: RequestInterceptor {
    func intercept(_ request: URLRequest,
                   next: @Sendable (URLRequest) async throws -> (Data, HTTPURLResponse)) async throws -> (Data,
                                                                                                          HTTPURLResponse) {
        do {
            let (data, response) = try await next(request)
            let body = data.isEmpty ? Data("{}".utf8) : data
            return (body, response)
        } catch let HTTPError.requestFailed(statusCode, data) {
            if let ascError = try? JSONDecoder().decode(ASCError.self, from: data) {
                throw ascError
            }
            throw ASCClientError.httpError(statusCode: statusCode)
        }
    }
}
