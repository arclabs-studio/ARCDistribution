import ARCASCModels
import ARCLogger
import Foundation

/// File-system implementation of `MetadataRepositoryProtocol`.
///
/// Reads and writes plain-text files in the iCloud Distribution folder:
/// ```
/// <distributionRoot>/<AppName>/metadata/<locale>/
///   name.txt           (30 chars max)
///   subtitle.txt       (30 chars max)
///   keywords.txt       (100 chars max)
///   description.txt    (4000 chars max)
///   release_notes.txt
/// ```
public final class FileMetadataRepository: MetadataRepositoryProtocol {
    private let distributionRoot: URL
    private let logger: any Logger

    /// - Parameter distributionRoot: Path to the `Distribution/` folder. Defaults to
    ///   `~/Documents/ARCLabsStudio/Distribution/`.
    public init(distributionRoot: URL = FileMetadataRepository.defaultDistributionRoot,
                logger: any Logger = ARCLogger()) {
        self.distributionRoot = distributionRoot
        self.logger = logger
    }

    /// FileManager guarantees at least one URL for .documentDirectory in .userDomainMask
    public static let defaultDistributionRoot: URL =
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appending(path: "ARCLabsStudio/Distribution")

    // MARK: - MetadataRepositoryProtocol

    public func load(appId: String, locale: String) async throws -> AppMetadata {
        let folder = metadataFolder(appId: appId, locale: locale)
        logger.debug("Loading metadata from \(folder.path)")

        return try AppMetadata(appId: appId,
                               locale: locale,
                               name: readFile(folder.appending(path: "name.txt")),
                               subtitle: readFile(folder.appending(path: "subtitle.txt")),
                               keywords: readFile(folder.appending(path: "keywords.txt")),
                               description: readFile(folder.appending(path: "description.txt")),
                               releaseNotes: readFile(folder.appending(path: "release_notes.txt")))
    }

    public func save(_ metadata: AppMetadata) async throws {
        let folder = metadataFolder(appId: metadata.appId, locale: metadata.locale)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        try writeFile(folder.appending(path: "name.txt"), content: metadata.name)
        try writeFile(folder.appending(path: "subtitle.txt"), content: metadata.subtitle)
        try writeFile(folder.appending(path: "keywords.txt"), content: metadata.keywords)
        try writeFile(folder.appending(path: "description.txt"), content: metadata.description)
        try writeFile(folder.appending(path: "release_notes.txt"), content: metadata.releaseNotes)

        logger.info("Saved metadata for \(metadata.appId) [\(metadata.locale)]")
    }

    public func availableLocales(appId: String) async throws -> [String] {
        let metadataRoot = distributionRoot.appending(path: appId).appending(path: "metadata")
        guard FileManager.default.fileExists(atPath: metadataRoot.path) else { return [] }
        let contents = try FileManager.default.contentsOfDirectory(at: metadataRoot,
                                                                   includingPropertiesForKeys: [.isDirectoryKey])
        return contents
            .filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true }
            .map(\.lastPathComponent)
            .sorted()
    }

    // MARK: - Private

    private func metadataFolder(appId: String, locale: String) -> URL {
        distributionRoot
            .appending(path: appId)
            .appending(path: "metadata")
            .appending(path: locale)
    }

    private func readFile(_ url: URL) throws -> String {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw MetadataRepositoryError.fileNotFound(url.lastPathComponent)
        }
        return try String(contentsOf: url, encoding: .utf8)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func writeFile(_ url: URL, content: String) throws {
        try content.write(to: url, atomically: true, encoding: .utf8)
    }
}

// MARK: - Errors

public enum MetadataRepositoryError: Error, Sendable {
    case fileNotFound(String)
    case invalidEncoding(String)
}

// MARK: - Validation

public struct MetadataValidator: Sendable {
    public enum ValidationError: Error, Sendable, CustomStringConvertible {
        case nameTooLong(Int)
        case subtitleTooLong(Int)
        case keywordsTooLong(Int)
        case descriptionTooLong(Int)

        public var description: String {
            switch self {
            case let .nameTooLong(count):
                "Name is \(count) characters (max 30)"
            case let .subtitleTooLong(count):
                "Subtitle is \(count) characters (max 30)"
            case let .keywordsTooLong(count):
                "Keywords are \(count) characters (max 100)"
            case let .descriptionTooLong(count):
                "Description is \(count) characters (max 4000)"
            }
        }
    }

    public static func validate(_ metadata: AppMetadata) throws {
        if metadata.name.count > 30 {
            throw ValidationError.nameTooLong(metadata.name.count)
        }
        if metadata.subtitle.count > 30 {
            throw ValidationError.subtitleTooLong(metadata.subtitle.count)
        }
        if metadata.keywords.count > 100 {
            throw ValidationError.keywordsTooLong(metadata.keywords.count)
        }
        if metadata.description.count > 4000 {
            throw ValidationError.descriptionTooLong(metadata.description.count)
        }
    }

    public static func characterCounts(_ metadata: AppMetadata) -> [String: Int] {
        ["name": metadata.name.count,
         "subtitle": metadata.subtitle.count,
         "keywords": metadata.keywords.count,
         "description": metadata.description.count]
    }
}
