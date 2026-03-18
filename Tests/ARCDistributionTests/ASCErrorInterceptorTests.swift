import ARCASCModels
import ARCNetworking
import Foundation
import Testing
@testable import ARCASCClient

@Suite("ASCErrorInterceptor")
struct ASCErrorInterceptorTests {
    // MARK: - Happy path

    @Test("Passes through successful response unchanged when body is non-empty", .tags(.unit))
    func passesThroughNonEmptyBody() async throws {
        // Given
        let sut = ASCErrorInterceptor()
        let responseBody = Data(#"{"id":"1"}"#.utf8)
        let httpResponse = makeHTTPResponse(statusCode: 200)

        // When
        let (data, response) = try await sut.intercept(URLRequest(url: anyURL())) { _ in
            (responseBody, httpResponse)
        }

        // Then
        #expect(data == responseBody)
        #expect(response.statusCode == 200)
    }

    @Test("Normalises empty 2xx body to {} for EmptyResponse decoding", .tags(.unit))
    func normalisesEmptyBodyToEmptyJSON() async throws {
        // Given
        let sut = ASCErrorInterceptor()
        let httpResponse = makeHTTPResponse(statusCode: 201)

        // When
        let (data, _) = try await sut.intercept(URLRequest(url: anyURL())) { _ in
            (Data(), httpResponse)
        }

        // Then
        #expect(data == Data("{}".utf8))
        // Verify EmptyResponse decodes successfully from the normalised data
        #expect(throws: Never.self) {
            try JSONDecoder().decode(EmptyResponse.self, from: data)
        }
    }

    // MARK: - Error mapping: structured ASCError

    @Test("Maps HTTPError.requestFailed to ASCError when body is valid ASC error envelope", .tags(.unit))
    func mapsToASCErrorWhenBodyIsValidASCEnvelope() async throws {
        // Given
        let sut = ASCErrorInterceptor()
        let ascErrorBody = Data("""
        {
            "errors": [{
                "id": "abc",
                "status": "401",
                "code": "NOT_AUTHORIZED",
                "title": "Authentication credentials are missing or invalid.",
                "detail": "Provide a properly configured and signed bearer token."
            }]
        }
        """.utf8)

        // When/Then
        await #expect(throws: ASCError.self) {
            try await sut.intercept(URLRequest(url: anyURL())) { _ in
                throw HTTPError.requestFailed(statusCode: 401, data: ascErrorBody)
            }
        }
    }

    @Test("ASCError thrown by interceptor preserves error details from body", .tags(.unit))
    func ascErrorPreservesDetails() async throws {
        // Given
        let sut = ASCErrorInterceptor()
        let ascErrorBody = Data("""
        {
            "errors": [{
                "status": "422",
                "code": "ENTITY_ERROR.ATTRIBUTE.INVALID",
                "title": "The provided entity includes an attribute with an invalid value.",
                "detail": "keywords is too long (maximum is 100 characters)"
            }]
        }
        """.utf8)

        // When
        var thrownError: ASCError?
        do {
            _ = try await sut.intercept(URLRequest(url: anyURL())) { _ in
                throw HTTPError.requestFailed(statusCode: 422, data: ascErrorBody)
            }
        } catch let error as ASCError {
            thrownError = error
        }

        // Then
        let ascError = try #require(thrownError)
        #expect(ascError.errors.count == 1)
        #expect(ascError.errors[0].code == "ENTITY_ERROR.ATTRIBUTE.INVALID")
        #expect(ascError.errors[0].status == "422")
    }

    // MARK: - Error mapping: fallback to ASCClientError

    @Test("Falls back to ASCClientError.httpError when body is not a valid ASC error envelope", .tags(.unit))
    func fallsBackToASCClientErrorForNonASCBody() async throws {
        // Given
        let sut = ASCErrorInterceptor()
        let nonASCBody = Data("Internal Server Error".utf8)

        // When/Then
        await #expect(throws: ASCClientError.self) {
            try await sut.intercept(URLRequest(url: anyURL())) { _ in
                throw HTTPError.requestFailed(statusCode: 500, data: nonASCBody)
            }
        }
    }

    @Test("Fallback ASCClientError carries the original status code", .tags(.unit))
    func fallbackCarriesStatusCode() async throws {
        // Given
        let sut = ASCErrorInterceptor()

        // When
        var thrownError: ASCClientError?
        do {
            _ = try await sut.intercept(URLRequest(url: anyURL())) { _ in
                throw HTTPError.requestFailed(statusCode: 403, data: Data())
            }
        } catch let error as ASCClientError {
            thrownError = error
        }

        // Then
        let clientError = try #require(thrownError)
        guard case let .httpError(code) = clientError else {
            Issue.record("Expected .httpError, got \(clientError)")
            return
        }
        #expect(code == 403)
    }
}

// MARK: - Helpers

private func anyURL() -> URL {
    guard let url = URL(string: "https://api.appstoreconnect.apple.com/v1/apps") else {
        preconditionFailure("Hardcoded URL string is invalid")
    }
    return url
}

private func makeHTTPResponse(statusCode: Int) -> HTTPURLResponse {
    guard let response = HTTPURLResponse(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)
    else {
        preconditionFailure("HTTPURLResponse init failed for status \(statusCode)")
    }
    return response
}
