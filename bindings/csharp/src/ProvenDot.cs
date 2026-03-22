// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoT protocol types for proven-servers.

namespace Proven;

/// <summary>SessionState matching the Idris2 ABI tags (0-4).</summary>
public enum SessionState : byte
{
    Connecting = 0,
    Handshaking = 1,
    Established = 2,
    Closing = 3,
    Closed = 4
}

/// <summary>PaddingStrategy matching the Idris2 ABI tags (0-2).</summary>
public enum PaddingStrategy : byte
{
    NoPadding = 0,
    BlockPadding = 1,
    RandomPadding = 2
}

/// <summary>ErrorReason matching the Idris2 ABI tags (0-3).</summary>
public enum ErrorReason : byte
{
    HandshakeFailed = 0,
    CertificateInvalid = 1,
    Timeout = 2,
    UpstreamError = 3
}

/// <summary>ServerState matching the Idris2 ABI tags (0-4).</summary>
public enum ServerState : byte
{
    Idle = 0,
    Bound = 1,
    Listening = 2,
    Processing = 3,
    Shutdown = 4
}
