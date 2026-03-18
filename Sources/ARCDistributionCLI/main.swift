import ARCASCClient
import ARCASCModels
import ARCLogger
import ARCMetadataManager
import Foundation

// MARK: - arc-distribution CLI

//
// Usage:
//   arc-distribution builds list --app-id <ID>
//   arc-distribution metadata sync --app-id <ID> [--locale en-US] [--platform ios]
//   arc-distribution submit --app-id <ID> [--platform ios]
//   arc-distribution validate-metadata --app-id <ID> [--locale en-US]

let logger: any Logger = ARCLogger()

/// Parse top-level command
let args = CommandLine.arguments.dropFirst()
guard let command = args.first else {
    printUsage()
    exit(1)
}

let subargs = Array(args.dropFirst())

func run() async {
    do {
        switch command {
        case "builds":
            try await handleBuilds(args: subargs)
        case "metadata":
            try await handleMetadata(args: subargs)
        case "submit":
            try await handleSubmit(args: subargs)
        case "validate-metadata":
            try await handleValidateMetadata(args: subargs)
        case "help", "--help", "-h":
            printUsage()
        default:
            logger.warning("Unknown command: \(command)")
            printUsage()
            exit(1)
        }
    } catch {
        logger.error("Error: \(error)")
        exit(1)
    }
}

// MARK: - Command Handlers

func handleBuilds(args: [String]) async throws {
    guard args.first == "list" else {
        logger.error("Usage: arc-distribution builds list --app-id <ID>")
        exit(1)
    }
    let appId = try requireArg("--app-id", from: args)
    let credentials = try ASCCredentials.fromEnvironment()
    let client = AppStoreConnectClient(credentials: credentials)
    let builds = try await client.fetchBuilds(appId: appId, limit: 10)

    logger.info("Builds for app \(appId):")
    for build in builds {
        let state = build.attributes.processingState.rawValue
        logger.info("  \(build.attributes.version)  [\(state)]  id=\(build.id)")
    }
}

func handleMetadata(args: [String]) async throws {
    guard args.first == "sync" else {
        logger.error("Usage: arc-distribution metadata sync --app-id <ID> [--locale en-US] [--platform ios]")
        exit(1)
    }
    let appId = try requireArg("--app-id", from: args)
    let locale = arg("--locale", from: args) ?? "en-US"
    let platform = try parsePlatform(from: args)

    let credentials = try ASCCredentials.fromEnvironment()
    let client = AppStoreConnectClient(credentials: credentials)
    let repo = FileMetadataRepository()

    let metadata = try await repo.load(appId: appId, locale: locale)
    try MetadataValidator.validate(metadata)

    let version = try await client.fetchCurrentVersion(appId: appId, platform: platform)
    try await client.uploadMetadata(metadata, versionId: version.id)

    logger.info("Metadata synced: \(appId) [\(locale)] → version \(version.attributes.versionString)")
}

func handleSubmit(args: [String]) async throws {
    let appId = try requireArg("--app-id", from: args)
    let platform = try parsePlatform(from: args)

    let credentials = try ASCCredentials.fromEnvironment()
    let client = AppStoreConnectClient(credentials: credentials)
    let version = try await client.fetchCurrentVersion(appId: appId, platform: platform)

    logger.info("Submitting \(appId) v\(version.attributes.versionString) for review...")
    try await client.submitForReview(versionId: version.id)
    logger.info("Submitted.")
}

func handleValidateMetadata(args: [String]) async throws {
    let appId = try requireArg("--app-id", from: args)
    let locale = arg("--locale", from: args) ?? "en-US"

    let repo = FileMetadataRepository()
    let metadata = try await repo.load(appId: appId, locale: locale)
    let counts = MetadataValidator.characterCounts(metadata)

    logger.info("Metadata validation for \(appId) [\(locale)]:")
    logger.info("  name:        \(counts["name"] ?? 0)/30 chars")
    logger.info("  subtitle:    \(counts["subtitle"] ?? 0)/30 chars")
    logger.info("  keywords:    \(counts["keywords"] ?? 0)/100 chars")
    logger.info("  description: \(counts["description"] ?? 0)/4000 chars")

    do {
        try MetadataValidator.validate(metadata)
        logger.info("  All fields valid.")
    } catch {
        logger.error("  VALIDATION FAILED: \(error)")
        exit(1)
    }
}

// MARK: - Argument Helpers

func requireArg(_ name: String, from args: [String]) throws -> String {
    guard let value = arg(name, from: args) else {
        throw CLIError.missingArgument(name)
    }
    return value
}

func arg(_ name: String, from args: [String]) -> String? {
    guard let idx = args.firstIndex(of: name), args.indices.contains(idx + 1) else { return nil }
    return args[idx + 1]
}

func parsePlatform(from args: [String]) throws -> Platform {
    let raw = arg("--platform", from: args) ?? "ios"
    return try Platform(cliValue: raw)
}

// MARK: - CLI Errors

enum CLIError: Error, CustomStringConvertible {
    case missingArgument(String)
    case unknownPlatform(String)

    var description: String {
        switch self {
        case let .missingArgument(name): "Missing required argument: \(name)"
        case let .unknownPlatform(value): "Unknown platform '\(value)'. Valid values: ios, macos, tvos, visionos"
        }
    }
}

extension Platform {
    init(cliValue: String) throws {
        switch cliValue.lowercased() {
        case "ios": self = .iOS
        case "macos": self = .macOS
        case "tvos": self = .tvOS
        case "visionos": self = .visionOS
        default: throw CLIError.unknownPlatform(cliValue)
        }
    }
}

func printUsage() {
    logger.info("""
    arc-distribution — ARC Labs Studio App Store distribution tool

    Commands:
      builds list --app-id <ID>                                      List recent builds
      metadata sync --app-id <ID> [--locale en-US] [--platform ios]  Sync metadata to ASC
      submit --app-id <ID> [--platform ios]                          Submit for review
      validate-metadata --app-id <ID> [--locale en-US]               Validate character counts

    Options:
      --platform  Target platform: ios, macos, tvos, visionos (default: ios)

    Environment:
      ASC_KEY_ID       App Store Connect API key ID
      ASC_ISSUER_ID    App Store Connect API issuer ID
      ASC_PRIVATE_KEY  Base64-encoded .p8 private key
    """)
}

// Run
await run()
