import ARCASCModels
import ARCMetadataManager
import Testing

@Suite("MetadataValidator")
struct MetadataValidatorTests {
    @Test("Valid metadata passes validation", .tags(.unit)) func validMetadataPasses() throws {
        // Given
        let metadata = makeMetadata(name: "FavRes",
                                    subtitle: "Save your restaurants",
                                    keywords: "restaurant,food,favorites",
                                    description: "A short description.")

        // When/Then — no throw
        try MetadataValidator.validate(metadata)
    }

    @Test("Name exceeding 30 chars fails", .tags(.unit)) func nameTooLongFails() {
        // Given
        let metadata = makeMetadata(name: String(repeating: "A", count: 31))

        // When/Then
        #expect(throws: MetadataValidator.ValidationError.self) {
            try MetadataValidator.validate(metadata)
        }
    }

    @Test("Subtitle exceeding 30 chars fails", .tags(.unit)) func subtitleTooLongFails() {
        // Given
        let metadata = makeMetadata(subtitle: String(repeating: "B", count: 31))

        // When/Then
        #expect(throws: MetadataValidator.ValidationError.self) {
            try MetadataValidator.validate(metadata)
        }
    }

    @Test("Keywords exceeding 100 chars fails", .tags(.unit)) func keywordsTooLongFails() {
        // Given
        let metadata = makeMetadata(keywords: String(repeating: "k,", count: 51))

        // When/Then
        #expect(throws: MetadataValidator.ValidationError.self) {
            try MetadataValidator.validate(metadata)
        }
    }

    @Test("Description exceeding 4000 chars fails", .tags(.unit)) func descriptionTooLongFails() {
        // Given
        let metadata = makeMetadata(description: String(repeating: "D", count: 4001))

        // When/Then
        #expect(throws: MetadataValidator.ValidationError.self) {
            try MetadataValidator.validate(metadata)
        }
    }

    @Test("Character counts match metadata lengths", .tags(.unit)) func characterCountsAreAccurate() {
        // Given
        let metadata = makeMetadata(name: "FavRes", subtitle: "Short", keywords: "a,b,c")

        // When
        let counts = MetadataValidator.characterCounts(metadata)

        // Then
        #expect(counts["name"] == 6)
        #expect(counts["subtitle"] == 5)
        #expect(counts["keywords"] == 5)
    }

    // MARK: - SUT Factory

    private func makeMetadata(name: String = "Test App",
                              subtitle: String = "A subtitle",
                              keywords: String = "key,words",
                              description: String = "A description.") -> AppMetadata {
        AppMetadata(appId: "test-app",
                    locale: "en-US",
                    name: name,
                    subtitle: subtitle,
                    keywords: keywords,
                    description: description,
                    releaseNotes: "What's new.")
    }
}
