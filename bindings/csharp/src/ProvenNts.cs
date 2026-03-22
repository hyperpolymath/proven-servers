// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NTS protocol types for proven-servers.

namespace Proven;

/// <summary>RecordType matching the Idris2 ABI tags (0-8).</summary>
public enum RecordType : byte
{
    EndOfMessage = 0,
    NextProtocol = 1,
    Error = 2,
    Warning = 3,
    AeadAlgorithm = 4,
    Cookie = 5,
    CookiePlaceholder = 6,
    NtskeServer = 7,
    NtskePort = 8
}

/// <summary>ErrorCode matching the Idris2 ABI tags (0-2).</summary>
public enum ErrorCode : byte
{
    UnrecognizedCritical = 0,
    BadRequest = 1,
    InternalError = 2
}

/// <summary>AeadAlgorithm matching the Idris2 ABI tags (0-2).</summary>
public enum AeadAlgorithm : byte
{
    AeadAes128Gcm = 0,
    AeadAes256Gcm = 1,
    AeadAesSivCmac256 = 2
}

/// <summary>HandshakeState matching the Idris2 ABI tags (0-3).</summary>
public enum HandshakeState : byte
{
    Initial = 0,
    Negotiating = 1,
    Established = 2,
    Failed = 3
}

/// <summary>SessionState matching the Idris2 ABI tags (0-4).</summary>
public enum SessionState : byte
{
    Idle = 0,
    Handshaking = 1,
    Negotiating = 2,
    Established = 3,
    Closing = 4
}
