// ARCASCModels — Codable models for App Store Connect API v2
// Covers: Apps, Builds, App Store Versions, Localizations, Screenshots

import Foundation

// MARK: - JSON:API Envelope

/// Generic JSON:API response wrapper used by all ASC endpoints.
public struct ASCResponse<T: Decodable & Sendable>: Decodable, Sendable {
    public let data: T
    public let links: ASCPageLinks?

    public init(data: T, links: ASCPageLinks? = nil) {
        self.data = data
        self.links = links
    }
}

public struct ASCListResponse<T: Decodable & Sendable>: Decodable, Sendable {
    public let data: [T]
    public let links: ASCPageLinks?
    public let meta: ASCMeta?

    public init(data: [T], links: ASCPageLinks? = nil, meta: ASCMeta? = nil) {
        self.data = data
        self.links = links
        self.meta = meta
    }
}

public struct ASCPageLinks: Decodable, Sendable {
    public let `self`: String?
    public let next: String?
    public let prev: String?
}

public struct ASCMeta: Decodable, Sendable {
    public let paging: ASCPaging?
}

public struct ASCPaging: Decodable, Sendable {
    public let total: Int
    public let limit: Int
}

// MARK: - App

public struct App: Decodable, Sendable, Identifiable {
    public let id: String
    public let type: String
    public let attributes: AppAttributes

    public struct AppAttributes: Decodable, Sendable {
        public let bundleId: String
        public let name: String
        public let primaryLocale: String
        public let sku: String
        public let isOrEverWasMadeForKids: Bool?
    }
}

// MARK: - Build

public struct Build: Decodable, Sendable, Identifiable {
    public let id: String
    public let type: String
    public let attributes: BuildAttributes

    public struct BuildAttributes: Decodable, Sendable {
        public let version: String
        public let uploadedDate: String?
        public let expirationDate: String?
        public let expired: Bool
        public let minOsVersion: String?
        public let processingState: ProcessingState
        public let buildAudienceType: BuildAudienceType?
        public let usesNonExemptEncryption: Bool?
    }
}

public enum ProcessingState: String, Decodable, Sendable {
    case processing = "PROCESSING"
    case failed = "FAILED"
    case invalid = "INVALID"
    case valid = "VALID"
}

public enum BuildAudienceType: String, Decodable, Sendable {
    case internalOnly = "INTERNAL_ONLY"
    case appStoreEligible = "APP_STORE_ELIGIBLE"
}

// MARK: - App Store Version

public struct AppStoreVersion: Decodable, Sendable, Identifiable {
    public let id: String
    public let type: String
    public let attributes: AppStoreVersionAttributes

    public struct AppStoreVersionAttributes: Decodable, Sendable {
        public let platform: Platform
        public let versionString: String
        public let appStoreState: AppStoreState
        public let releaseType: ReleaseType?
        public let usesIdfa: Bool?
        public let isLocalizable: Bool?
        public let earliestReleaseDate: String?
        public let downloadable: Bool?
        public let createdDate: String?
    }
}

public enum Platform: String, Decodable, Sendable {
    case iOS = "IOS"
    case macOS = "MAC_OS"
    case tvOS = "TV_OS"
    case visionOS = "VISION_OS"
}

public enum AppStoreState: String, Decodable, Sendable {
    case acceptedForSale = "ACCEPTED"
    case developerRemovedFromSale = "DEVELOPER_REMOVED_FROM_SALE"
    case developerRejected = "DEVELOPER_REJECTED"
    case inReview = "IN_REVIEW"
    case invalidBinary = "INVALID_BINARY"
    case metadataRejected = "METADATA_REJECTED"
    case pendingAppleRelease = "PENDING_APPLE_RELEASE"
    case pendingDeveloperRelease = "PENDING_DEVELOPER_RELEASE"
    case prepareForSubmission = "PREPARE_FOR_SUBMISSION"
    case processingForDistribution = "PROCESSING_FOR_DISTRIBUTION"
    case readyForDistribution = "READY_FOR_DISTRIBUTION"
    case readyForReview = "READY_FOR_REVIEW"
    case rejected = "REJECTED"
    case removedFromSale = "REMOVED_FROM_SALE"
    case waitingForExportCompliance = "WAITING_FOR_EXPORT_COMPLIANCE"
    case waitingForReview = "WAITING_FOR_REVIEW"
    case replacedWithNewVersion = "REPLACED_WITH_NEW_VERSION"
}

public enum ReleaseType: String, Decodable, Sendable {
    case manual = "MANUAL"
    case afterApproval = "AFTER_APPROVAL"
    case scheduled = "SCHEDULED"
}

// MARK: - App Store Version Localization

public struct AppStoreVersionLocalization: Decodable, Sendable, Identifiable {
    public let id: String
    public let type: String
    public let attributes: LocalizationAttributes

    public struct LocalizationAttributes: Decodable, Sendable {
        public let locale: String
        public let description: String?
        public let keywords: String?
        public let marketingUrl: String?
        public let promotionalText: String?
        public let supportUrl: String?
        public let whatsNew: String?
    }
}

// MARK: - App Metadata (local model)

/// Flat representation of all metadata for one app + locale combination.
/// Used by ARCMetadataManager when reading from and writing to the iCloud folder.
public struct AppMetadata: Sendable {
    public let appId: String
    public let locale: String
    public let name: String
    public let subtitle: String
    public let keywords: String
    public let description: String
    public let releaseNotes: String

    public init(appId: String,
                locale: String,
                name: String,
                subtitle: String,
                keywords: String,
                description: String,
                releaseNotes: String) {
        self.appId = appId
        self.locale = locale
        self.name = name
        self.subtitle = subtitle
        self.keywords = keywords
        self.description = description
        self.releaseNotes = releaseNotes
    }
}

// MARK: - Screenshot

public struct AppScreenshot: Decodable, Sendable, Identifiable {
    public let id: String
    public let type: String
    public let attributes: ScreenshotAttributes

    public struct ScreenshotAttributes: Decodable, Sendable {
        public let fileSize: Int?
        public let fileName: String?
        public let sourceFileChecksum: String?
        public let imageAsset: ImageAsset?
        public let assetToken: String?
        public let assetType: String?
        public let uploadOperations: [UploadOperation]?
        public let assetDeliveryState: AssetDeliveryState?
        public let displayType: DisplayType?
    }
}

public struct ImageAsset: Decodable, Sendable {
    public let templateUrl: String?
    public let width: Int?
    public let height: Int?
}

public struct UploadOperation: Decodable, Sendable {
    public let method: String
    public let url: String
    public let length: Int
    public let offset: Int
    public let requestHeaders: [HTTPHeader]
}

public struct HTTPHeader: Decodable, Sendable {
    public let name: String
    public let value: String
}

public struct AssetDeliveryState: Decodable, Sendable {
    public let state: String?
    public let errors: [AssetError]?
    public let warnings: [AssetWarning]?
}

public struct AssetError: Decodable, Sendable {
    public let code: String?
    public let description: String?
}

public struct AssetWarning: Decodable, Sendable {
    public let code: String?
    public let description: String?
}

public enum DisplayType: String, Decodable, Sendable {
    case appIphone65 = "APP_IPHONE_65"
    case appIphone61 = "APP_IPHONE_61"
    case appIphone55 = "APP_IPHONE_55"
    case appIphone47 = "APP_IPHONE_47"
    case appIphone40 = "APP_IPHONE_40"
    case appIphone35 = "APP_IPHONE_35"
    case appIpadPro3Gen129 = "APP_IPAD_PRO_3GEN_129"
    case appIpadPro3Gen11 = "APP_IPAD_PRO_3GEN_11"
    case appIpadPro129 = "APP_IPAD_PRO_129"
    case appIpad105 = "APP_IPAD_105"
    case appIpad97 = "APP_IPAD_97"
}

// MARK: - Empty Response

/// Sentinel type for ASC endpoints that return HTTP 201/204 with an empty body.
/// The custom initializer ignores all content, so it decodes successfully from `{}`.
public struct EmptyResponse: Decodable, Sendable {
    public init(from _: any Decoder) throws {}
}

// MARK: - ASC Error

public struct ASCError: Decodable, Sendable, Error {
    public let errors: [ASCErrorDetail]

    public struct ASCErrorDetail: Decodable, Sendable {
        public let id: String?
        public let status: String
        public let code: String
        public let title: String
        public let detail: String?
        public let source: ASCErrorSource?
    }
}

public struct ASCErrorSource: Decodable, Sendable {
    public let pointer: String?
    public let parameter: String?
    public let header: String?
}
