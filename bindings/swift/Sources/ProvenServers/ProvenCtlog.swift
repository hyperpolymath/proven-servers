// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CT Log protocol types for proven-servers.

/// LogEntryType matching the Idris2 ABI tags.
public enum LogEntryType: UInt8, CaseIterable, Sendable {
    case x509Entry = 0
    case precertEntry = 1
}

/// SignatureType matching the Idris2 ABI tags.
public enum SignatureType: UInt8, CaseIterable, Sendable {
    case certificateTimestamp = 0
    case treeHash = 1
}

/// MerkleLeafType matching the Idris2 ABI tags.
public enum MerkleLeafType: UInt8, CaseIterable, Sendable {
    case timestampedEntry = 0
}

/// SubmissionStatus matching the Idris2 ABI tags.
public enum SubmissionStatus: UInt8, CaseIterable, Sendable {
    case accepted = 0
    case duplicate = 1
    case rateLimited = 2
    case rejected = 3
    case invalidChain = 4
    case unknownAnchor = 5
}

/// VerificationResult matching the Idris2 ABI tags.
public enum VerificationResult: UInt8, CaseIterable, Sendable {
    case validProof = 0
    case invalidProof = 1
    case inconsistentTree = 2
    case staleSth = 3
}

/// ServerState matching the Idris2 ABI tags.
public enum ServerState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case active = 1
    case merging = 2
    case signing = 3
    case shutdown = 4
}
