// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OCSP protocol types for proven-servers.

/// CertStatus matching the Idris2 ABI tags.
public enum CertStatus: UInt8, CaseIterable, Sendable {
    case good = 0
    case revoked = 1
    case unknown = 2
}

/// ResponseStatus matching the Idris2 ABI tags.
public enum ResponseStatus: UInt8, CaseIterable, Sendable {
    case successful = 0
    case malformedRequest = 1
    case internalError = 2
    case tryLater = 3
    case sigRequired = 4
    case unauthorized = 5
}

/// HashAlgorithm matching the Idris2 ABI tags.
public enum HashAlgorithm: UInt8, CaseIterable, Sendable {
    case sha1 = 0
    case sha256 = 1
    case sha384 = 2
    case sha512 = 3
}

/// ResponderState matching the Idris2 ABI tags.
public enum ResponderState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case ready = 1
    case processing = 2
    case signing = 3
    case closing = 4
}
