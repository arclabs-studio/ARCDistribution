// swift-tools-version: 6.0

import PackageDescription

let package = Package(name: "ARCDistribution",

                      // MARK: - Platforms

                      platforms: [.iOS(.v17),
                                  .macOS(.v14)],

                      // MARK: - Products

                      products: [.library(name: "ARCDistribution",
                                          targets: ["ARCASCClient", "ARCASCModels", "ARCMetadataManager"]),
                                 .library(name: "ARCDistributionMocks",
                                          targets: ["ARCDistributionMocks"]),
                                 .executable(name: "arc-distribution",
                                             targets: ["ARCDistributionCLI"])],

                      // MARK: - Dependencies

                      dependencies: [.package(url: "https://github.com/arclabs-studio/ARCNetworking.git",
                                              branch: "develop"),
                                     .package(url: "https://github.com/arclabs-studio/ARCLogger.git", from: "1.0.0")],

                      // MARK: - Targets

                      targets: [// MARK: ARCASCModels — Codable models for App Store Connect entities

                          .target(name: "ARCASCModels",
                                  dependencies: [],
                                  path: "Sources/ARCASCModels"),

                          // MARK: ARCASCClient — JWT auth + HTTP client for App Store Connect API

                          .target(name: "ARCASCClient",
                                  dependencies: ["ARCASCModels",
                                                 .product(name: "ARCNetworking", package: "ARCNetworking"),
                                                 .product(name: "ARCLogger", package: "ARCLogger")],
                                  path: "Sources/ARCASCClient"),

                          // MARK: ARCMetadataManager — Read/write localized metadata from iCloud folder

                          .target(name: "ARCMetadataManager",
                                  dependencies: ["ARCASCModels",
                                                 .product(name: "ARCLogger", package: "ARCLogger")],
                                  path: "Sources/ARCMetadataManager"),

                          // MARK: ARCDistributionMocks — Test doubles for all protocols

                          .target(name: "ARCDistributionMocks",
                                  dependencies: ["ARCASCClient",
                                                 "ARCASCModels",
                                                 "ARCMetadataManager"],
                                  path: "Sources/ARCDistributionMocks"),

                          // MARK: ARCDistributionCLI — CLI executable for ci_scripts and terminal

                          .executableTarget(name: "ARCDistributionCLI",
                                            dependencies: ["ARCASCClient",
                                                           "ARCASCModels",
                                                           "ARCMetadataManager",
                                                           .product(name: "ARCLogger", package: "ARCLogger")],
                                            path: "Sources/ARCDistributionCLI"),

                          // MARK: Tests

                          .testTarget(name: "ARCDistributionTests",
                                      dependencies: ["ARCASCClient",
                                                     "ARCASCModels",
                                                     "ARCMetadataManager",
                                                     "ARCDistributionMocks",
                                                     .product(name: "ARCNetworking", package: "ARCNetworking")],
                                      path: "Tests/ARCDistributionTests")],

                      // MARK: - Swift Language

                      swiftLanguageModes: [.v6])
