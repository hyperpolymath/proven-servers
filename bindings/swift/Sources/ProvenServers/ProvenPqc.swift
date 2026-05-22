// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PQC protocol types for proven-servers.

/// PqcAlgorithm matching the Idris2 ABI tags.
public enum PqcAlgorithm: UInt8, CaseIterable, Sendable {
    case crystalsKyber = 0
    case crystalsDilithium = 1
    case falcon = 2
    case sphincsPlus = 3
    case classicMceliece = 4
    case bike = 5
    case hqc = 6
    case frodokem = 7
}

/// NistLevel matching the Idris2 ABI tags.
public enum NistLevel: UInt8, CaseIterable, Sendable {
    case nist1 = 0
    case nist2 = 1
    case nist3 = 2
    case nist4 = 3
    case nist5 = 4
}

/// Operation matching the Idris2 ABI tags.
public enum Operation: UInt8, CaseIterable, Sendable {
    case keygen = 0
    case encapsulate = 1
    case decapsulate = 2
    case sign = 3
    case verify = 4
}

/// HybridMode matching the Idris2 ABI tags.
public enum HybridMode: UInt8, CaseIterable, Sendable {
    case classicalOnly = 0
    case pqcOnly = 1
    case hybrid = 2
}

/// AlgorithmCategory matching the Idris2 ABI tags.
public enum AlgorithmCategory: UInt8, CaseIterable, Sendable {
    case kem = 0
    case signature = 1
}

/// KeyState matching the Idris2 ABI tags.
public enum KeyState: UInt8, CaseIterable, Sendable {
    case empty = 0
    case generating = 1
    case generated = 2
    case active = 3
    case expired = 4
    case compromised = 5
}
