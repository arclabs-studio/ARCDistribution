import Foundation

/// API key credentials for App Store Connect.
///
/// Obtain from App Store Connect → Users and Access → Integrations → App Store Connect API.
public struct ASCCredentials: Sendable {
    public let keyId: String
    public let issuerId: String
    public let privateKeyPEM: String

    public init(keyId: String, issuerId: String, privateKeyPEM: String) {
        self.keyId = keyId
        self.issuerId = issuerId
        self.privateKeyPEM = privateKeyPEM
    }

    /// Load credentials from environment variables.
    /// Expects: `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_PRIVATE_KEY` (base64-encoded PEM).
    public static func fromEnvironment() throws -> ASCCredentials {
        guard let keyId = ProcessInfo.processInfo.environment["ASC_KEY_ID"] else {
            throw ASCCredentialError.missingEnvironmentVariable("ASC_KEY_ID")
        }
        guard let issuerId = ProcessInfo.processInfo.environment["ASC_ISSUER_ID"] else {
            throw ASCCredentialError.missingEnvironmentVariable("ASC_ISSUER_ID")
        }
        guard let privateKeyBase64 = ProcessInfo.processInfo.environment["ASC_PRIVATE_KEY"] else {
            throw ASCCredentialError.missingEnvironmentVariable("ASC_PRIVATE_KEY")
        }
        guard let privateKeyData = Data(base64Encoded: privateKeyBase64),
              let privateKeyPEM = String(data: privateKeyData, encoding: .utf8) else {
            throw ASCCredentialError.invalidPrivateKey
        }

        return ASCCredentials(keyId: keyId, issuerId: issuerId, privateKeyPEM: privateKeyPEM)
    }
}

public enum ASCCredentialError: Error, Sendable {
    case missingEnvironmentVariable(String)
    case invalidPrivateKey
}
