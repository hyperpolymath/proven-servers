<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Auth protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** AuthMethod matching the Idris2 ABI tags. */
enum AuthMethod: int
{
    case Password = 0;
    case Certificate = 1;
    case OAuth2 = 2;
    case Saml = 3;
    case Fido2 = 4;
    case Kerberos = 5;
    case Ldap = 6;
    case Radius = 7;
}

/** TokenType matching the Idris2 ABI tags. */
enum TokenType: int
{
    case Access = 0;
    case Refresh = 1;
    case Id = 2;
    case Api = 3;
}

/** AuthResult matching the Idris2 ABI tags. */
enum AuthResult: int
{
    case Success = 0;
    case InvalidCredentials = 1;
    case AccountLocked = 2;
    case AccountExpired = 3;
    case MfaRequired = 4;
    case IpBlocked = 5;
}

/** MfaMethod matching the Idris2 ABI tags. */
enum MfaMethod: int
{
    case Totp = 0;
    case Sms = 1;
    case Push = 2;
    case Fido2Mfa = 3;
    case Email = 4;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Active = 0;
    case Expired = 1;
    case Revoked = 2;
    case Locked = 3;
}
