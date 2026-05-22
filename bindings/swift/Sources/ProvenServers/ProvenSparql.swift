// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SPARQL protocol types for proven-servers.

/// SparqlQueryType matching the Idris2 ABI tags.
public enum SparqlQueryType: UInt8, CaseIterable, Sendable {
    case select = 0
    case construct = 1
    case ask = 2
    case describe = 3
}

/// UpdateType matching the Idris2 ABI tags.
public enum UpdateType: UInt8, CaseIterable, Sendable {
    case insert = 0
    case delete = 1
    case load = 2
    case clear = 3
    case create = 4
    case drop = 5
}

/// ResultFormat matching the Idris2 ABI tags.
public enum ResultFormat: UInt8, CaseIterable, Sendable {
    case xml = 0
    case json = 1
    case csv = 2
    case tsv = 3
}

/// SparqlErrorType matching the Idris2 ABI tags.
public enum SparqlErrorType: UInt8, CaseIterable, Sendable {
    case parseError = 0
    case queryTimeout = 1
    case resultsTooLarge = 2
    case unknownGraph = 3
    case accessDenied = 4
}
