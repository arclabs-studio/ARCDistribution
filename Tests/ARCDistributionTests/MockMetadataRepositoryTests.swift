import ARCASCModels
import ARCDistributionMocks
import ARCMetadataManager
import Testing

@Suite("MockMetadataRepository")
struct MockMetadataRepositoryTests {
    // MARK: - load — success

    @Test("load returns stubbed metadata for matching key", .tags(.unit)) func loadReturnsStubbed() async throws {
        // Given
        let sut = MockMetadataRepository()
        let metadata = makeMetadata(appId: "com.example", locale: "en-US")
        sut.stubbedMetadata["com.example-en-US"] = metadata

        // When
        let result = try await sut.load(appId: "com.example", locale: "en-US")

        // Then
        #expect(result.appId == "com.example")
        #expect(result.locale == "en-US")
        #expect(sut.loadCallCount == 1)
    }

    // MARK: - load — not found

    @Test("load throws when key is absent from stubs", .tags(.unit)) func loadThrowsFileNotFound() async throws {
        // Given
        let sut = MockMetadataRepository()

        // When / Then
        await #expect(throws: MetadataRepositoryError.self) {
            try await sut.load(appId: "com.missing", locale: "en-US")
        }
        #expect(sut.loadCallCount == 1)
    }

    // MARK: - load — stubbed error

    @Test("load throws stubbedError when loadError is set", .tags(.unit)) func loadThrowsStubbedError() async throws {
        // Given
        let sut = MockMetadataRepository()
        sut.loadError = MetadataRepositoryError.fileNotFound("forced")

        // When / Then
        await #expect(throws: (any Error).self) {
            try await sut.load(appId: "com.example", locale: "en-US")
        }
        #expect(sut.loadCallCount == 1)
    }

    // MARK: - save — success

    @Test("save stores metadata and increments saveCallCount", .tags(.unit)) func saveStoresMetadata() async throws {
        // Given
        let sut = MockMetadataRepository()
        let metadata = makeMetadata(appId: "com.example", locale: "en-US")

        // When
        try await sut.save(metadata)

        // Then
        #expect(sut.saveCallCount == 1)
        #expect(sut.lastSavedMetadata?.appId == "com.example")
        let loaded = try await sut.load(appId: "com.example", locale: "en-US")
        #expect(loaded.name == metadata.name)
    }

    // MARK: - save — stubbed error

    @Test("save throws stubbedError when saveError is set", .tags(.unit)) func saveThrowsStubbedError() async throws {
        // Given
        let sut = MockMetadataRepository()
        sut.saveError = MetadataRepositoryError.fileNotFound("forced")
        let metadata = makeMetadata(appId: "com.example", locale: "en-US")

        // When / Then
        await #expect(throws: (any Error).self) {
            try await sut.save(metadata)
        }
        #expect(sut.saveCallCount == 1)
    }

    // MARK: - availableLocales — stubbed

    @Test("availableLocales returns stubbed locales for app ID", .tags(.unit))
    func availableLocalesReturnsStubbedLocales() async throws {
        // Given
        let sut = MockMetadataRepository()
        sut.stubbedLocales["com.example"] = ["en-US", "fr-FR"]

        // When
        let locales = try await sut.availableLocales(appId: "com.example")

        // Then
        #expect(locales == ["en-US", "fr-FR"])
    }

    // MARK: - availableLocales — not stubbed

    @Test("availableLocales returns empty array when app ID is not stubbed", .tags(.unit))
    func availableLocalesReturnsEmptyWhenNotStubbed() async throws {
        // Given
        let sut = MockMetadataRepository()

        // When
        let locales = try await sut.availableLocales(appId: "com.missing")

        // Then
        #expect(locales.isEmpty)
    }
}

// MARK: - Helper

private func makeMetadata(appId: String, locale: String) -> AppMetadata {
    AppMetadata(appId: appId,
                locale: locale,
                name: "Test App",
                subtitle: "Subtitle",
                keywords: "test",
                description: "A test app.",
                releaseNotes: "Initial release.")
}
