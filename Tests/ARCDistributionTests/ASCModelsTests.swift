import ARCASCModels
import Foundation
import Testing

@Suite("ASC Models")
struct ASCModelsTests {
    // MARK: - EmptyResponse

    @Test("EmptyResponse decodes from empty JSON object {}", .tags(.unit))
    func emptyResponseDecodesFromEmptyObject() throws {
        let data = Data("{}".utf8)
        #expect(throws: Never.self) {
            try JSONDecoder().decode(EmptyResponse.self, from: data)
        }
    }

    @Test("EmptyResponse decodes from any JSON object (ignores content)", .tags(.unit))
    func emptyResponseDecodesFromAnyObject() throws {
        let data = Data(#"{"id":"1","status":"OK","extra":{"nested":true}}"#.utf8)
        #expect(throws: Never.self) {
            try JSONDecoder().decode(EmptyResponse.self, from: data)
        }
    }

    // MARK: - ASCError

    @Test("ASCError decodes error envelope with all fields", .tags(.unit)) func ascErrorDecodesFullEnvelope() throws {
        let json = Data("""
        {
            "errors": [{
                "id": "err-1",
                "status": "401",
                "code": "NOT_AUTHORIZED",
                "title": "Authentication credentials are missing or invalid.",
                "detail": "Provide a properly configured and signed bearer token.",
                "source": {
                    "pointer": "/data/attributes/token"
                }
            }]
        }
        """.utf8)

        let sut = try JSONDecoder().decode(ASCError.self, from: json)

        #expect(sut.errors.count == 1)
        #expect(sut.errors[0].id == "err-1")
        #expect(sut.errors[0].status == "401")
        #expect(sut.errors[0].code == "NOT_AUTHORIZED")
        #expect(sut.errors[0].title == "Authentication credentials are missing or invalid.")
        #expect(sut.errors[0].detail == "Provide a properly configured and signed bearer token.")
        #expect(sut.errors[0].source?.pointer == "/data/attributes/token")
    }

    @Test("ASCError decodes envelope with optional fields absent", .tags(.unit))
    func ascErrorDecodesWithoutOptionalFields() throws {
        let json = Data("""
        {
            "errors": [{
                "status": "422",
                "code": "INVALID",
                "title": "Invalid value"
            }]
        }
        """.utf8)

        let sut = try JSONDecoder().decode(ASCError.self, from: json)
        #expect(sut.errors[0].id == nil)
        #expect(sut.errors[0].detail == nil)
        #expect(sut.errors[0].source == nil)
    }

    // MARK: - Build

    @Test("Build decodes all ProcessingState raw values", .tags(.unit)) func buildDecodesAllProcessingStates() throws {
        let states: [(String, ProcessingState)] = [("PROCESSING", .processing),
                                                   ("FAILED", .failed),
                                                   ("INVALID", .invalid),
                                                   ("VALID", .valid)]

        for (raw, expected) in states {
            let json = Data("""
            {
                "id": "b1",
                "type": "builds",
                "attributes": {
                    "version": "1.0",
                    "expired": false,
                    "processingState": "\(raw)"
                }
            }
            """.utf8)
            let build = try JSONDecoder().decode(Build.self, from: json)
            #expect(build.attributes.processingState == expected)
        }
    }

    // MARK: - AppStoreVersion

    @Test("AppStoreVersion decodes all Platform raw values", .tags(.unit))
    func appStoreVersionDecodesAllPlatforms() throws {
        let platforms: [(String, Platform)] = [("IOS", .iOS),
                                               ("MAC_OS", .macOS),
                                               ("TV_OS", .tvOS),
                                               ("VISION_OS", .visionOS)]

        for (raw, expected) in platforms {
            let json = Data("""
            {
                "id": "v1",
                "type": "appStoreVersions",
                "attributes": {
                    "platform": "\(raw)",
                    "versionString": "1.0",
                    "appStoreState": "PREPARE_FOR_SUBMISSION"
                }
            }
            """.utf8)
            let version = try JSONDecoder().decode(AppStoreVersion.self, from: json)
            #expect(version.attributes.platform == expected)
        }
    }

    // MARK: - ASCListResponse

    @Test("ASCListResponse decodes data array and pagination metadata", .tags(.unit))
    func ascListResponseDecodesPagination() throws {
        let json = Data("""
        {
            "data": [],
            "links": {
                "self": "https://api.appstoreconnect.apple.com/v1/apps",
                "next": "https://api.appstoreconnect.apple.com/v1/apps?cursor=abc"
            },
            "meta": {
                "paging": {
                    "total": 42,
                    "limit": 20
                }
            }
        }
        """.utf8)

        let sut = try JSONDecoder().decode(ASCListResponse<App>.self, from: json)
        #expect(sut.data.isEmpty)
        #expect(sut.links?.next != nil)
        #expect(sut.meta?.paging?.total == 42)
        #expect(sut.meta?.paging?.limit == 20)
    }
}
