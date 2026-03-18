import CryptoKit
import Foundation

/// Generates a signed JWT for App Store Connect API authentication.
///
/// See: https://developer.apple.com/documentation/appstoreconnectapi/generating_tokens_for_api_requests
public struct JWTGenerator: Sendable {
    private let keyId: String
    private let issuerId: String
    private let privateKeyPEM: String

    public init(keyId: String, issuerId: String, privateKeyPEM: String) {
        self.keyId = keyId
        self.issuerId = issuerId
        self.privateKeyPEM = privateKeyPEM
    }

    /// Generates a signed JWT valid for 20 minutes.
    public func generateToken() throws -> String {
        let header = Header(alg: "ES256", kid: keyId, typ: "JWT")
        let now = Date()
        let payload = Payload(iss: issuerId,
                              iat: Int(now.timeIntervalSince1970),
                              exp: Int(now.addingTimeInterval(20 * 60).timeIntervalSince1970),
                              aud: "appstoreconnect-v1")

        let encodedHeader = try base64URLEncode(header)
        let encodedPayload = try base64URLEncode(payload)
        let signingInput = "\(encodedHeader).\(encodedPayload)"

        let privateKey = try loadPrivateKey()
        let signature = try sign(signingInput, with: privateKey)

        return "\(signingInput).\(signature)"
    }

    // MARK: - Private

    private func loadPrivateKey() throws -> P256.Signing.PrivateKey {
        // Strip PEM headers and base64-decode
        let stripped = privateKeyPEM
            .replacingOccurrences(of: "-----BEGIN PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----BEGIN EC PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "-----END EC PRIVATE KEY-----", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .trimmingCharacters(in: .whitespaces)

        guard let derData = Data(base64Encoded: stripped) else {
            throw JWTError.invalidPrivateKey
        }

        return try P256.Signing.PrivateKey(derRepresentation: derData)
    }

    private func sign(_ input: String, with key: P256.Signing.PrivateKey) throws -> String {
        guard let data = input.data(using: .utf8) else {
            throw JWTError.encodingFailed
        }
        let signature = try key.signature(for: data)
        return base64URLEncode(signature.rawRepresentation)
    }

    private func base64URLEncode(_ value: some Encodable) throws -> String {
        let data = try JSONEncoder().encode(value)
        return base64URLEncode(data)
    }

    private func base64URLEncode(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    // MARK: - JWT Parts

    private struct Header: Encodable {
        let alg: String
        let kid: String
        let typ: String
    }

    private struct Payload: Encodable {
        let iss: String
        let iat: Int
        let exp: Int
        let aud: String
    }
}

// MARK: - Errors

public enum JWTError: Error, Sendable {
    case invalidPrivateKey
    case encodingFailed
    case signingFailed
}
