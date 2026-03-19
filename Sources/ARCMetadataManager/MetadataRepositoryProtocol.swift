import ARCASCModels
import Foundation

/// Read/write localized metadata from the iCloud Distribution folder structure.
///
/// Default path: `~/Documents/ARCLabsStudio/Distribution/<AppName>/metadata/<locale>/`
/// Inject `ARCDistributionMocks.MockMetadataRepository` in tests.
public protocol MetadataRepositoryProtocol: Sendable {
    /// Loads metadata for a given app and locale from the iCloud folder.
    func load(appId: String, locale: String) async throws -> AppMetadata

    /// Saves metadata to the iCloud folder, overwriting existing files.
    func save(_ metadata: AppMetadata) async throws

    /// Returns all locales available for the given app.
    func availableLocales(appId: String) async throws -> [String]
}
