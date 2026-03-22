// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Deception protocol types for proven-servers.

namespace Proven;

/// <summary>DecoyType matching the Idris2 ABI tags (0-5).</summary>
public enum DecoyType : byte
{
    Service = 0,
    Credential = 1,
    File = 2,
    Network = 3,
    Token = 4,
    Breadcrumb = 5
}

/// <summary>TriggerEvent matching the Idris2 ABI tags (0-5).</summary>
public enum TriggerEvent : byte
{
    Access = 0,
    Login = 1,
    Read = 2,
    Write = 3,
    Execute = 4,
    Scan = 5
}

/// <summary>AlertPriority matching the Idris2 ABI tags (0-3).</summary>
public enum AlertPriority : byte
{
    Low = 0,
    Medium = 1,
    High = 2,
    Critical = 3
}

/// <summary>DecoyState matching the Idris2 ABI tags (0-3).</summary>
public enum DecoyState : byte
{
    Active = 0,
    Triggered = 1,
    Disabled = 2,
    Expired = 3
}

/// <summary>ResponseAction matching the Idris2 ABI tags (0-4).</summary>
public enum ResponseAction : byte
{
    Alert = 0,
    Redirect = 1,
    Delay = 2,
    Fingerprint = 3,
    Isolate = 4
}

/// <summary>ServerState matching the Idris2 ABI tags (0-4).</summary>
public enum ServerState : byte
{
    Idle = 0,
    Configured = 1,
    Monitoring = 2,
    Responding = 3,
    Shutdown = 4
}
