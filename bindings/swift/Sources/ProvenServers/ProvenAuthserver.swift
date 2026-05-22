// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Auth protocol types for proven-servers.

/// AuthMethod matching the Idris2 ABI tags.
public enum AuthMethod: UInt8, CaseIterable, Sendable {
    case password = 0
    case certificate = 1
    case oAuth2 = 2
    case saml = 3
    case fido2 = 4
    case kerberos = 5
    case ldap = 6
    case radius = 7
}

/// TokenType matching the Idris2 ABI tags.
public enum TokenType: UInt8, CaseIterable, Sendable {
    case access = 0
    case refresh = 1
    case id = 2
    case api = 3
}

/// AuthResult matching the Idris2 ABI tags.
public enum AuthResult: UInt8, CaseIterable, Sendable {
    case success = 0
    case invalidCredentials = 1
    case accountLocked = 2
    case accountExpired = 3
    case mfaRequired = 4
    case ipBlocked = 5
}

/// MfaMethod matching the Idris2 ABI tags.
public enum MfaMethod: UInt8, CaseIterable, Sendable {
    case totp = 0
    case sms = 1
    case push = 2
    case fido2Mfa = 3
    case email = 4
}

/// SessionState matching the Idris2 ABI tags.
public enum SessionState: UInt8, CaseIterable, Sendable {
    case active = 0
    case expired = 1
    case revoked = 2
    case locked = 3
}
