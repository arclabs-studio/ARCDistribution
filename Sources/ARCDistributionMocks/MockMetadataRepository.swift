import ARCASCModels
import ARCMetadataManager
import Foundation

/// Test double for `MetadataRepositoryProtocol`.
public final class MockMetadataRepository: MetadataRepositoryProtocol, @unchecked Sendable {

    // MARK: - Stubs

    public var stubbedMetadata: [String: AppMetadata] = [:]
    public var stubbedLocales: [String: [String]] = [:]

    // MARK: - Errors

    public var loadError: Error?
    public var saveError: Error?

    // MARK: - Call Tracking

    public private(set) var loadCallCount = 0
    public private(set) var saveCallCount = 0
    public private(set) var lastSavedMetadata: AppMetadata?

    public init() {}

    // MARK: - MetadataRepositoryProtocol

    public func load(appId: String, locale: String) async throws -> AppMetadata {
        loadCallCount += 1
        if let error = loadError { throw error }
        let key = "\(appId)-\(locale)"
        guard let metadata = stubbedMetadata[key] else {
            throw MetadataRepositoryError.fileNotFound(key)
        }
        return metadata
    }

    public func save(_ metadata: AppMetadata) async throws {
        saveCallCount += 1
        lastSavedMetadata = metadata
        if let error = saveError { throw error }
        stubbedMetadata["\(metadata.appId)-\(metadata.locale)"] = metadata
    }

    public func availableLocales(appId: String) async throws -> [String] {
        return stubbedLocales[appId] ?? []
    }
}
