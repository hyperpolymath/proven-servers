// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Auth protocol types for proven-servers.

namespace Proven;

/// <summary>AuthMethod matching the Idris2 ABI tags (0-7).</summary>
public enum AuthMethod : byte
{
    Password = 0,
    Certificate = 1,
    OAuth2 = 2,
    Saml = 3,
    Fido2 = 4,
    Kerberos = 5,
    Ldap = 6,
    Radius = 7
}

/// <summary>TokenType matching the Idris2 ABI tags (0-3).</summary>
public enum TokenType : byte
{
    Access = 0,
    Refresh = 1,
    Id = 2,
    Api = 3
}

/// <summary>AuthResult matching the Idris2 ABI tags (0-5).</summary>
public enum AuthResult : byte
{
    Success = 0,
    InvalidCredentials = 1,
    AccountLocked = 2,
    AccountExpired = 3,
    MfaRequired = 4,
    IpBlocked = 5
}

/// <summary>MfaMethod matching the Idris2 ABI tags (0-4).</summary>
public enum MfaMethod : byte
{
    Totp = 0,
    Sms = 1,
    Push = 2,
    Fido2Mfa = 3,
    Email = 4
}

/// <summary>SessionState matching the Idris2 ABI tags (0-3).</summary>
public enum SessionState : byte
{
    Active = 0,
    Expired = 1,
    Revoked = 2,
    Locked = 3
}
