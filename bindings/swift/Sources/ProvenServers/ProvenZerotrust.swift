// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Zero Trust protocol types for proven-servers.

/// PolicyType matching the Idris2 ABI tags.
public enum PolicyType: UInt8, CaseIterable, Sendable {
    case alwaysVerify = 0
    case neverTrust = 1
    case leastPrivilege = 2
    case microSegmentation = 3
}

/// IdentityConfidence matching the Idris2 ABI tags.
public enum IdentityConfidence: UInt8, CaseIterable, Sendable {
    case unverified = 0
    case basicAuth = 1
    case mfaVerified = 2
    case strongAuth = 3
    case continuousAuth = 4
}

/// DeviceTrustScore matching the Idris2 ABI tags.
public enum DeviceTrustScore: UInt8, CaseIterable, Sendable {
    case deviceUnknown = 0
    case devicePartial = 1
    case deviceCompliant = 2
    case deviceManaged = 3
    case deviceHardened = 4
}

/// AccessDecision matching the Idris2 ABI tags.
public enum AccessDecision: UInt8, CaseIterable, Sendable {
    case allow = 0
    case deny = 1
    case challenge = 2
    case stepUp = 3
}

/// ContextSignalKind matching the Idris2 ABI tags.
public enum ContextSignalKind: UInt8, CaseIterable, Sendable {
    case location = 0
    case time = 1
    case device = 2
    case behavior = 3
    case network = 4
}

/// AuthFactor matching the Idris2 ABI tags.
public enum AuthFactor: UInt8, CaseIterable, Sendable {
    case certificate = 0
    case token = 1
    case biometric = 2
    case fido2 = 3
    case totp = 4
    case push = 5
}
