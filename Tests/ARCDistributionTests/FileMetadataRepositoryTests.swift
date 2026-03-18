import ARCASCModels
import ARCMetadataManager
import Foundation
import Testing

@Suite("FileMetadataRepository", .tags(.integration))
struct FileMetadataRepositoryTests {
    let tmpRoot: URL
    let sut: FileMetadataRepository

    init() {
        tmpRoot = FileManager.default.temporaryDirectory
            .appending(path: "ARCDistributionTests-\(UUID().uuidString)")
        sut = FileMetadataRepository(distributionRoot: tmpRoot)
    }

    // MARK: - Round-trip

    @Test("load returns metadata matching what was saved", .tags(.integration))
    func roundTrip() async throws {
        let metadata = makeMetadata()
        try await sut.save(metadata)
        let loaded = try await sut.load(appId: metadata.appId, locale: metadata.locale)

        #expect(loaded.appId == metadata.appId)
        #expect(loaded.locale == metadata.locale)
        #expect(loaded.name == metadata.name)
        #expect(loaded.subtitle == metadata.subtitle)
        #expect(loaded.keywords == metadata.keywords)
        #expect(loaded.description == metadata.description)
        #expect(loaded.releaseNotes == metadata.releaseNotes)
    }

    @Test("save overwrites existing files with new values", .tags(.integration))
    func saveOverwrites() async throws {
        let original = makeMetadata(name: "Original Name")
        try await sut.save(original)

        let updated = makeMetadata(name: "Updated Name")
        try await sut.save(updated)

        let loaded = try await sut.load(appId: updated.appId, locale: updated.locale)
        #expect(loaded.name == "Updated Name")
    }

    // MARK: - Error paths

    @Test("load throws fileNotFound when folder does not exist", .tags(.integration))
    func loadMissingFolder() async throws {
        do {
            _ = try await sut.load(appId: "com.missing.app", locale: "en-US")
            Issue.record("Expected fileNotFound error, but load succeeded")
        } catch let error as MetadataRepositoryError {
            guard case .fileNotFound = error else {
                Issue.record("Expected fileNotFound, got \(error)")
                return
            }
        }
    }

    @Test("load throws fileNotFound when individual file is missing", .tags(.integration))
    func loadMissingFile() async throws {
        // Create the folder but omit one file by writing partial metadata manually
        let folder = tmpRoot
            .appending(path: "com.test.app")
            .appending(path: "metadata")
            .appending(path: "en-US")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try "Test App".write(to: folder.appending(path: "name.txt"), atomically: true, encoding: .utf8)
        // subtitle.txt is intentionally missing

        do {
            _ = try await sut.load(appId: "com.test.app", locale: "en-US")
            Issue.record("Expected fileNotFound error, but load succeeded")
        } catch let error as MetadataRepositoryError {
            guard case .fileNotFound = error else {
                Issue.record("Expected fileNotFound, got \(error)")
                return
            }
        }
    }

    // MARK: - availableLocales

    @Test("availableLocales returns empty array when app folder does not exist", .tags(.integration))
    func availableLocalesNoFolder() async throws {
        let locales = try await sut.availableLocales(appId: "com.missing.app")
        #expect(locales.isEmpty)
    }

    @Test("availableLocales returns all saved locales sorted alphabetically", .tags(.integration))
    func availableLocalesSorted() async throws {
        let appId = "com.test.app"
        for locale in ["zh-Hans", "en-US", "fr-FR"] {
            try await sut.save(makeMetadata(appId: appId, locale: locale))
        }
        let locales = try await sut.availableLocales(appId: appId)
        #expect(locales == ["en-US", "fr-FR", "zh-Hans"])
    }

    @Test("availableLocales ignores files in the metadata folder", .tags(.integration))
    func availableLocalesIgnoresFiles() async throws {
        let appId = "com.test.app"
        try await sut.save(makeMetadata(appId: appId, locale: "en-US"))

        // Plant a stray file alongside the locale directory
        let metadataRoot = tmpRoot.appending(path: appId).appending(path: "metadata")
        try "stray".write(to: metadataRoot.appending(path: "stray.txt"), atomically: true, encoding: .utf8)

        let locales = try await sut.availableLocales(appId: appId)
        #expect(locales == ["en-US"])
    }

    // MARK: - Helpers

    private func makeMetadata(appId: String = "com.test.app",
                              locale: String = "en-US",
                              name: String = "Test App") -> AppMetadata {
        AppMetadata(appId: appId,
                    locale: locale,
                    name: name,
                    subtitle: "A great app",
                    keywords: "test,app,swift",
                    description: "This is a test app.",
                    releaseNotes: "Bug fixes.")
    }
}
