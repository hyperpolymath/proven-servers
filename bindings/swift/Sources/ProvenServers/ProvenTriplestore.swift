// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Triplestore protocol types for proven-servers.

/// Statement matching the Idris2 ABI tags.
public enum Statement: UInt8, CaseIterable, Sendable {
    case triple = 0
    case quad = 1
}

/// IndexOrder matching the Idris2 ABI tags.
public enum IndexOrder: UInt8, CaseIterable, Sendable {
    case spo = 0
    case pos = 1
    case osp = 2
    case gspo = 3
    case gpos = 4
    case gosp = 5
}

/// StorageBackend matching the Idris2 ABI tags.
public enum StorageBackend: UInt8, CaseIterable, Sendable {
    case inMemory = 0
    case bTree = 1
    case lsm = 2
    case persistent = 3
}

/// ImportFormat matching the Idris2 ABI tags.
public enum ImportFormat: UInt8, CaseIterable, Sendable {
    case nTriples = 0
    case turtle = 1
    case rdfXml = 2
    case jsonLd = 3
    case nQuads = 4
    case trig = 5
}

/// TransactionIsolation matching the Idris2 ABI tags.
public enum TransactionIsolation: UInt8, CaseIterable, Sendable {
    case readCommitted = 0
    case serializable = 1
    case snapshot = 2
}

/// StoreState matching the Idris2 ABI tags.
public enum StoreState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case ready = 1
    case inTransaction = 2
    case importing = 3
    case closing = 4
}
