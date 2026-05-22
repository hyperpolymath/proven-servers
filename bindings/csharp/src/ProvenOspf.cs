// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OSPF protocol types for proven-servers.

namespace Proven;

/// <summary>PacketType matching the Idris2 ABI tags (0-4).</summary>
public enum PacketType : byte
{
    Hello = 0,
    DatabaseDescription = 1,
    LinkStateRequest = 2,
    LinkStateUpdate = 3,
    LinkStateAck = 4
}

/// <summary>NeighborState matching the Idris2 ABI tags (0-7).</summary>
public enum NeighborState : byte
{
    Down = 0,
    Attempt = 1,
    Init = 2,
    TwoWay = 3,
    ExStart = 4,
    Exchange = 5,
    Loading = 6,
    Full = 7
}

/// <summary>LsaType matching the Idris2 ABI tags (0-4).</summary>
public enum LsaType : byte
{
    RouterLsa = 0,
    NetworkLsa = 1,
    SummaryLsa = 2,
    AsbrSummaryLsa = 3,
    AsExternalLsa = 4
}

/// <summary>AreaType matching the Idris2 ABI tags (0-3).</summary>
public enum AreaType : byte
{
    Normal = 0,
    Stub = 1,
    TotallyStub = 2,
    Nssa = 3
}

/// <summary>OspfError matching the Idris2 ABI tags (0-6).</summary>
public enum OspfError : byte
{
    Ok = 0,
    InvalidSlot = 1,
    NotActive = 2,
    InvalidTransition = 3,
    InvalidPacket = 4,
    AreaError = 5,
    FloodLimit = 6
}
