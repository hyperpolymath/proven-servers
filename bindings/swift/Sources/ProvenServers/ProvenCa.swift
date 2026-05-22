// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CA protocol types for proven-servers.

/// CertType matching the Idris2 ABI tags.
public enum CertType: UInt8, CaseIterable, Sendable {
    case root = 0
    case intermediate = 1
    case endEntity = 2
    case crossSigned = 3
    case codeSigning = 4
    case emailProtection = 5
    case ocspSigning = 6
}

/// KeyAlgorithm matching the Idris2 ABI tags.
public enum KeyAlgorithm: UInt8, CaseIterable, Sendable {
    case rsa2048 = 0
    case rsa4096 = 1
    case ecdsaP256 = 2
    case ecdsaP384 = 3
    case ed25519 = 4
    case ed448 = 5
}

/// SignatureAlgorithm matching the Idris2 ABI tags.
public enum SignatureAlgorithm: UInt8, CaseIterable, Sendable {
    case sha256WithRsa = 0
    case sha384WithRsa = 1
    case sha512WithRsa = 2
    case sha256WithEcdsa = 3
    case sha384WithEcdsa = 4
    case pureEd25519 = 5
    case pureEd448 = 6
}

/// CertState matching the Idris2 ABI tags.
public enum CertState: UInt8, CaseIterable, Sendable {
    case pending = 0
    case active = 1
    case revoked = 2
    case expired = 3
    case suspended = 4
}

/// RevocationReason matching the Idris2 ABI tags.
public enum RevocationReason: UInt8, CaseIterable, Sendable {
    case unspecified = 0
    case keyCompromise = 1
    case caCompromise = 2
    case affiliationChanged = 3
    case superseded = 4
    case cessationOfOperation = 5
    case certificateHold = 6
}

/// CrlStatus matching the Idris2 ABI tags.
public enum CrlStatus: UInt8, CaseIterable, Sendable {
    case current = 0
    case crlExpired = 1
    case crlPending = 2
    case crlError = 3
}

/// OcspStatus matching the Idris2 ABI tags.
public enum OcspStatus: UInt8, CaseIterable, Sendable {
    case good = 0
    case ocspRevoked = 1
    case unknown = 2
    case unavailable = 3
}

/// Extension matching the Idris2 ABI tags.
public enum Extension: UInt8, CaseIterable, Sendable {
    case basicConstraints = 0
    case keyUsage = 1
    case extKeyUsage = 2
    case subjectAltName = 3
    case authorityInfoAccess = 4
    case crlDistributionPoints = 5
}

/// KeyUsageBit matching the Idris2 ABI tags.
public enum KeyUsageBit: UInt8, CaseIterable, Sendable {
    case digitalSignature = 0
    case nonRepudiation = 1
    case keyEncipherment = 2
    case dataEncipherment = 3
    case keyAgreement = 4
    case keyCertSign = 5
    case crlSign = 6
    case encipherOnly = 7
    case decipherOnly = 8
}
