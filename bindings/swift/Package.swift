// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SwiftPM manifest for proven-servers Swift bindings.
// Links against the Zig-compiled C-ABI shared library (libproven_servers).

// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ProvenServers",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "ProvenServers",
            targets: ["ProvenServers"]
        ),
    ],
    targets: [
        // System library target wrapping the Zig FFI C-ABI shared library.
        .systemLibrary(
            name: "CProvenServers",
            pkgConfig: "proven-servers",
            providers: [
                .brew(["proven-servers"]),
                .apt(["libproven-servers-dev"]),
            ]
        ),
        // Swift wrapper library with idiomatic Swift types.
        .target(
            name: "ProvenServers",
            dependencies: ["CProvenServers"],
            path: "Sources/ProvenServers"
        ),
        .testTarget(
            name: "ProvenServersTests",
            dependencies: ["ProvenServers"]
        ),
    ]
)
