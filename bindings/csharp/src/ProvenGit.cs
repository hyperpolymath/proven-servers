// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Git protocol types for proven-servers.

namespace Proven;

/// <summary>Command matching the Idris2 ABI tags (0-2).</summary>
public enum Command : byte
{
    UploadPack = 0,
    ReceivePack = 1,
    UploadArchive = 2
}

/// <summary>PacketType matching the Idris2 ABI tags (0-7).</summary>
public enum PacketType : byte
{
    Flush = 0,
    Delimiter = 1,
    ResponseEnd = 2,
    Data = 3,
    PktError = 4,
    SidebandData = 5,
    SidebandProgress = 6,
    SidebandError = 7
}

/// <summary>RefType matching the Idris2 ABI tags (0-4).</summary>
public enum RefType : byte
{
    Branch = 0,
    Tag = 1,
    Head = 2,
    Remote = 3,
    GitNote = 4
}

/// <summary>Capability matching the Idris2 ABI tags (0-8).</summary>
public enum Capability : byte
{
    MultiAck = 0,
    ThinPack = 1,
    SideBand64k = 2,
    OfsDelta = 3,
    Shallow = 4,
    DeepenSince = 5,
    DeepenNot = 6,
    FilterSpec = 7,
    ObjectFormat = 8
}

/// <summary>HookResult matching the Idris2 ABI tags (0-1).</summary>
public enum HookResult : byte
{
    Accept = 0,
    Reject = 1
}

/// <summary>ServerState matching the Idris2 ABI tags (0-4).</summary>
public enum ServerState : byte
{
    Idle = 0,
    Discovery = 1,
    Negotiating = 2,
    Transfer = 3,
    Shutdown = 4
}
