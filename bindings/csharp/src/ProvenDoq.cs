// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoQ protocol types for proven-servers.

namespace Proven;

/// <summary>StreamType matching the Idris2 ABI tags (0-1).</summary>
public enum StreamType : byte
{
    Unidirectional = 0,
    Bidirectional = 1
}

/// <summary>ErrorCode matching the Idris2 ABI tags (0-3).</summary>
public enum ErrorCode : byte
{
    NoError = 0,
    InternalError = 1,
    ExcessiveLoad = 2,
    ProtocolError = 3
}

/// <summary>SessionState matching the Idris2 ABI tags (0-4).</summary>
public enum SessionState : byte
{
    Initial = 0,
    Handshaking = 1,
    Ready = 2,
    Draining = 3,
    Closed = 4
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
