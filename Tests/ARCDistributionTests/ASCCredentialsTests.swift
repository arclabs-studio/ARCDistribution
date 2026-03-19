import ARCASCClient
import Foundation
import Testing

@Suite("ASCCredentials")
struct ASCCredentialsTests {
    // MARK: - init

    @Test("init stores all three credential fields", .tags(.unit)) func initStoresAllFields() {
        let sut = ASCCredentials(keyId: "KEY123",
                                 issuerId: "ISSUER456",
                                 privateKeyPEM: "-----BEGIN PRIVATE KEY-----")

        #expect(sut.keyId == "KEY123")
        #expect(sut.issuerId == "ISSUER456")
        #expect(sut.privateKeyPEM == "-----BEGIN PRIVATE KEY-----")
    }

    // MARK: - fromEnvironment — error paths

    @Test("fromEnvironment throws missingEnvironmentVariable when ASC_KEY_ID absent", .tags(.unit))
    func fromEnvironmentThrowsWhenKeyIdMissing() throws {
        // Guard: skip if the env var happens to be set (e.g. CI with real credentials)
        try #require(ProcessInfo.processInfo.environment["ASC_KEY_ID"] == nil,
                     "Skipping: ASC_KEY_ID is present in this environment")

        #expect(throws: ASCCredentialError.self) {
            try ASCCredentials.fromEnvironment()
        }
    }
}
