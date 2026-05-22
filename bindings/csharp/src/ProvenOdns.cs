// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ODNS protocol types for proven-servers.

namespace Proven;

/// <summary>Role matching the Idris2 ABI tags (0-2).</summary>
public enum Role : byte
{
    Client = 0,
    Proxy = 1,
    Target = 2
}

/// <summary>OdnsMessageType matching the Idris2 ABI tags (0-1).</summary>
public enum OdnsMessageType : byte
{
    Query = 0,
    Response = 1
}

/// <summary>OdnsErrorReason matching the Idris2 ABI tags (0-4).</summary>
public enum OdnsErrorReason : byte
{
    ProxyError = 0,
    TargetError = 1,
    DecryptionFailed = 2,
    InvalidConfig = 3,
    PayloadTooLarge = 4
}

/// <summary>EncapsulationFormat matching the Idris2 ABI tags (0-0).</summary>
public enum EncapsulationFormat : byte
{
    Hpke = 0
}

/// <summary>SessionState matching the Idris2 ABI tags (0-4).</summary>
public enum SessionState : byte
{
    Idle = 0,
    KeyExchange = 1,
    Ready = 2,
    Processing = 3,
    Closing = 4
}
