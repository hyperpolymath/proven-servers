// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SDN protocol types for proven-servers.

namespace Proven;

/// <summary>SdnMessageType matching the Idris2 ABI tags (0-11).</summary>
public enum SdnMessageType : byte
{
    Hello = 0,
    Error = 1,
    EchoRequest = 2,
    EchoReply = 3,
    FeaturesRequest = 4,
    FeaturesReply = 5,
    FlowMod = 6,
    PacketIn = 7,
    PacketOut = 8,
    PortStatus = 9,
    BarrierRequest = 10,
    BarrierReply = 11
}

/// <summary>FlowAction matching the Idris2 ABI tags (0-6).</summary>
public enum FlowAction : byte
{
    Output = 0,
    SetField = 1,
    Drop = 2,
    PushVlan = 3,
    PopVlan = 4,
    SetQueue = 5,
    Group = 6
}

/// <summary>MatchField matching the Idris2 ABI tags (0-10).</summary>
public enum MatchField : byte
{
    InPort = 0,
    EthDst = 1,
    EthSrc = 2,
    EthType = 3,
    VlanId = 4,
    IpSrc = 5,
    IpDst = 6,
    TcpSrc = 7,
    TcpDst = 8,
    UdpSrc = 9,
    UdpDst = 10
}

/// <summary>PortState matching the Idris2 ABI tags (0-2).</summary>
public enum PortState : byte
{
    Up = 0,
    Down = 1,
    Blocked = 2
}
