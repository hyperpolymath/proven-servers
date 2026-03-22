// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OCSP protocol types for proven-servers.

namespace Proven;

/// <summary>CertStatus matching the Idris2 ABI tags (0-2).</summary>
public enum CertStatus : byte
{
    Good = 0,
    Revoked = 1,
    Unknown = 2
}

/// <summary>ResponseStatus matching the Idris2 ABI tags (0-5).</summary>
public enum ResponseStatus : byte
{
    Successful = 0,
    MalformedRequest = 1,
    InternalError = 2,
    TryLater = 3,
    SigRequired = 4,
    Unauthorized = 5
}

/// <summary>HashAlgorithm matching the Idris2 ABI tags (0-3).</summary>
public enum HashAlgorithm : byte
{
    Sha1 = 0,
    Sha256 = 1,
    Sha384 = 2,
    Sha512 = 3
}

/// <summary>ResponderState matching the Idris2 ABI tags (0-4).</summary>
public enum ResponderState : byte
{
    Idle = 0,
    Ready = 1,
    Processing = 2,
    Signing = 3,
    Closing = 4
}
