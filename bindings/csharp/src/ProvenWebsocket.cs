// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WebSocket protocol types for proven-servers.

namespace Proven;

/// <summary>Opcode matching the Idris2 ABI tags (0-5).</summary>
public enum Opcode : byte
{
    Continuation = 0,
    Text = 1,
    Binary = 2,
    Close = 3,
    Ping = 4,
    Pong = 5
}

/// <summary>CloseCode matching the Idris2 ABI tags (0-10).</summary>
public enum CloseCode : byte
{
    Normal = 0,
    GoingAway = 1,
    ProtocolError = 2,
    UnsupportedData = 3,
    NoStatus = 4,
    Abnormal = 5,
    InvalidPayload = 6,
    PolicyViolation = 7,
    MessageTooBig = 8,
    MandatoryExtension = 9,
    InternalError = 10
}
