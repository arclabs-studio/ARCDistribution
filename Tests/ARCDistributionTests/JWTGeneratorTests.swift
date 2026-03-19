import CryptoKit
import Foundation
import Testing
@testable import ARCASCClient

@Suite("JWTGenerator")
struct JWTGeneratorTests {
    // MARK: - Token structure

    @Test("Generated token has three dot-separated components", .tags(.unit)) func tokenHasThreeComponents() throws {
        // Given
        let sut = JWTGenerator(keyId: "KEYID123",
                               issuerId: "issuer-456",
                               privateKeyPEM: validPrivateKeyPEM())

        // When
        let token = try sut.generateToken()

        // Then
        let parts = token.split(separator: ".", omittingEmptySubsequences: false)
        #expect(parts.count == 3)
    }

    @Test("Header part decodes to ES256 alg and correct kid", .tags(.unit))
    func headerContainsCorrectAlgAndKid() throws {
        // Given
        let keyId = "MYKEYID"
        let sut = JWTGenerator(keyId: keyId,
                               issuerId: "issuer-789",
                               privateKeyPEM: validPrivateKeyPEM())

        // When
        let token = try sut.generateToken()
        let headerPart = String(token.split(separator: ".", omittingEmptySubsequences: false)[0])
        let header = try decodeBase64URLJSON(headerPart)

        // Then
        #expect(header["alg"] as? String == "ES256")
        #expect(header["kid"] as? String == keyId)
        #expect(header["typ"] as? String == "JWT")
    }

    @Test("Payload contains correct issuer and audience", .tags(.unit))
    func payloadContainsCorrectIssuerAndAudience() throws {
        // Given
        let issuerId = "team-issuer-id"
        let sut = JWTGenerator(keyId: "KEY",
                               issuerId: issuerId,
                               privateKeyPEM: validPrivateKeyPEM())

        // When
        let token = try sut.generateToken()
        let payloadPart = String(token.split(separator: ".", omittingEmptySubsequences: false)[1])
        let payload = try decodeBase64URLJSON(payloadPart)

        // Then
        #expect(payload["iss"] as? String == issuerId)
        #expect(payload["aud"] as? String == "appstoreconnect-v1")
    }

    @Test("Payload iat is before exp by approximately 20 minutes", .tags(.unit))
    func payloadExpiryIsAbout20MinutesAfterIssued() throws {
        // Given
        let sut = JWTGenerator(keyId: "K",
                               issuerId: "I",
                               privateKeyPEM: validPrivateKeyPEM())

        // When
        let token = try sut.generateToken()
        let payloadPart = String(token.split(separator: ".", omittingEmptySubsequences: false)[1])
        let payload = try decodeBase64URLJSON(payloadPart)

        let iat = try #require(payload["iat"] as? Int)
        let exp = try #require(payload["exp"] as? Int)

        // Then — allow ±5 s window for test execution time
        let diff = exp - iat
        #expect(diff >= 20 * 60 - 5)
        #expect(diff <= 20 * 60 + 5)
    }

    @Test("generateToken throws JWTError.invalidPrivateKey for garbage PEM", .tags(.unit)) func throwsForInvalidPEM() {
        // Given
        let sut = JWTGenerator(keyId: "K", issuerId: "I", privateKeyPEM: "not-a-key")

        // When/Then
        #expect(throws: JWTError.self) {
            try sut.generateToken()
        }
    }
}

// MARK: - Helpers

/// Generates a real P256 key and returns it as a PEM string (for testing only).
private func validPrivateKeyPEM() -> String {
    P256.Signing.PrivateKey().pemRepresentation
}

/// Decodes a base64url-encoded JSON string into a dictionary.
private func decodeBase64URLJSON(_ encoded: String) throws -> [String: Any] {
    var base64 = encoded
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")

    // Add padding
    let remainder = base64.count % 4
    if remainder != 0 {
        base64 += String(repeating: "=", count: 4 - remainder)
    }

    let data = try #require(Data(base64Encoded: base64))
    return try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
}
