// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Air Gap protocol types for proven-servers.

/// TransferDirection matching the Idris2 ABI tags.
public enum TransferDirection: UInt8, CaseIterable, Sendable {
    case `import` = 0
    case export = 1
}

/// MediaType matching the Idris2 ABI tags.
public enum MediaType: UInt8, CaseIterable, Sendable {
    case usb = 0
    case opticalDisc = 1
    case tapeCartridge = 2
    case diodeLink = 3
}

/// ScanResult matching the Idris2 ABI tags.
public enum ScanResult: UInt8, CaseIterable, Sendable {
    case clean = 0
    case suspicious = 1
    case malicious = 2
    case unscannable = 3
}

/// TransferState matching the Idris2 ABI tags.
public enum TransferState: UInt8, CaseIterable, Sendable {
    case pending = 0
    case scanning = 1
    case approved = 2
    case rejected = 3
    case inProgress = 4
    case complete = 5
    case failed = 6
}

/// ValidationCheck matching the Idris2 ABI tags.
public enum ValidationCheck: UInt8, CaseIterable, Sendable {
    case hashVerify = 0
    case signatureVerify = 1
    case formatCheck = 2
    case contentInspection = 3
    case malwareScan = 4
}
