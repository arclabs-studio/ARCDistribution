import ARCASCClient
import ARCASCModels
import ARCLogger
import ARCMetadataManager
import Foundation

// MARK: - arc-distribution CLI
//
// Usage:
//   arc-distribution builds list --app-id <ID>
//   arc-distribution metadata sync --app-id <ID> [--locale en-US]
//   arc-distribution submit --app-id <ID>
//   arc-distribution validate-metadata --app-id <ID> [--locale en-US]

let logger: any Logger = ARCLogger()

// Parse top-level command
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
            print("Unknown command: \(command)")
            printUsage()
            exit(1)
        }
    } catch {
        print("Error: \(error)")
        exit(1)
    }
}

// MARK: - Command Handlers

func handleBuilds(args: [String]) async throws {
    guard args.first == "list" else {
        print("Usage: arc-distribution builds list --app-id <ID>")
        exit(1)
    }
    let appId = try requireArg("--app-id", from: args)
    let credentials = try ASCCredentials.fromEnvironment()
    let client = AppStoreConnectClient(credentials: credentials)
    let builds = try await client.fetchBuilds(appId: appId, limit: 10)

    print("\nBuilds for app \(appId):\n")
    for build in builds {
        let state = build.attributes.processingState.rawValue
        print("  \(build.attributes.version)  [\(state)]  id=\(build.id)")
    }
    print("")
}

func handleMetadata(args: [String]) async throws {
    guard args.first == "sync" else {
        print("Usage: arc-distribution metadata sync --app-id <ID> [--locale en-US]")
        exit(1)
    }
    let appId = try requireArg("--app-id", from: args)
    let locale = arg("--locale", from: args) ?? "en-US"

    let credentials = try ASCCredentials.fromEnvironment()
    let client = AppStoreConnectClient(credentials: credentials)
    let repo = FileMetadataRepository()

    let metadata = try await repo.load(appId: appId, locale: locale)
    try MetadataValidator.validate(metadata)

    let version = try await client.fetchCurrentVersion(appId: appId, platform: .iOS)
    try await client.uploadMetadata(metadata, versionId: version.id)

    print("Metadata synced: \(appId) [\(locale)] → version \(version.attributes.versionString)")
}

func handleSubmit(args: [String]) async throws {
    let appId = try requireArg("--app-id", from: args)

    let credentials = try ASCCredentials.fromEnvironment()
    let client = AppStoreConnectClient(credentials: credentials)
    let version = try await client.fetchCurrentVersion(appId: appId, platform: .iOS)

    print("Submitting \(appId) v\(version.attributes.versionString) for review...")
    try await client.submitForReview(versionId: version.id)
    print("Submitted.")
}

func handleValidateMetadata(args: [String]) async throws {
    let appId = try requireArg("--app-id", from: args)
    let locale = arg("--locale", from: args) ?? "en-US"

    let repo = FileMetadataRepository()
    let metadata = try await repo.load(appId: appId, locale: locale)
    let counts = MetadataValidator.characterCounts(metadata)

    print("\nMetadata validation for \(appId) [\(locale)]:\n")
    print("  name:        \(counts["name"] ?? 0)/30 chars")
    print("  subtitle:    \(counts["subtitle"] ?? 0)/30 chars")
    print("  keywords:    \(counts["keywords"] ?? 0)/100 chars")
    print("  description: \(counts["description"] ?? 0)/4000 chars")

    do {
        try MetadataValidator.validate(metadata)
        print("\n  All fields valid.\n")
    } catch {
        print("\n  VALIDATION FAILED: \(error)\n")
        exit(1)
    }
}

// MARK: - Argument Helpers

func requireArg(_ name: String, from args: [String]) throws -> String {
    guard let value = arg(name, from: args) else {
        print("Missing required argument: \(name)")
        exit(1)
    }
    return value
}

func arg(_ name: String, from args: [String]) -> String? {
    guard let idx = args.firstIndex(of: name), args.indices.contains(idx + 1) else { return nil }
    return args[idx + 1]
}

func printUsage() {
    print("""
    arc-distribution — ARC Labs Studio App Store distribution tool

    Commands:
      builds list --app-id <ID>                       List recent builds
      metadata sync --app-id <ID> [--locale en-US]    Sync metadata from iCloud folder to ASC
      submit --app-id <ID>                            Submit current version for review
      validate-metadata --app-id <ID> [--locale en-US] Validate metadata character counts

    Environment:
      ASC_KEY_ID       App Store Connect API key ID
      ASC_ISSUER_ID    App Store Connect API issuer ID
      ASC_PRIVATE_KEY  Base64-encoded .p8 private key
    """)
}

// Run
await run()
