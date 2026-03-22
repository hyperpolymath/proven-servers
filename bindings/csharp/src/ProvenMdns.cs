// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// mDNS protocol types for proven-servers.

namespace Proven;

/// <summary>MdnsRecordType matching the Idris2 ABI tags (0-4).</summary>
public enum MdnsRecordType : byte
{
    A = 0,
    Aaaa = 1,
    Ptr = 2,
    Srv = 3,
    Txt = 4
}

/// <summary>QueryType matching the Idris2 ABI tags (0-2).</summary>
public enum QueryType : byte
{
    Standard = 0,
    OneShot = 1,
    Continuous = 2
}

/// <summary>ConflictAction matching the Idris2 ABI tags (0-2).</summary>
public enum ConflictAction : byte
{
    Probe = 0,
    Defend = 1,
    Withdraw = 2
}

/// <summary>ServiceFlag matching the Idris2 ABI tags (0-1).</summary>
public enum ServiceFlag : byte
{
    Unique = 0,
    Shared = 1
}

/// <summary>ResponderState matching the Idris2 ABI tags (0-4).</summary>
public enum ResponderState : byte
{
    Idle = 0,
    Probing = 1,
    Announcing = 2,
    Running = 3,
    ShuttingDown = 4
}
