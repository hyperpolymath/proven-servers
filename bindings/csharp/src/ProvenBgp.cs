// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// BGP protocol types for proven-servers.

namespace Proven;

/// <summary>BgpState matching the Idris2 ABI tags (0-5).</summary>
public enum BgpState : byte
{
    Idle = 0,
    Connect = 1,
    Active = 2,
    OpenSent = 3,
    OpenConfirm = 4,
    Established = 5
}

/// <summary>BgpEvent matching the Idris2 ABI tags (0-18).</summary>
public enum BgpEvent : byte
{
    ManualStart = 0,
    ManualStop = 1,
    AutomaticStart = 2,
    ConnectRetryTimerExpires = 3,
    HoldTimerExpires = 4,
    KeepaliveTimerExpires = 5,
    DelayOpenTimerExpires = 6,
    TcpConnectionValid = 7,
    TcpCrAcked = 8,
    TcpConnectionConfirmed = 9,
    TcpConnectionFails = 10,
    BgpOpenReceived = 11,
    BgpHeaderErr = 12,
    BgpOpenMsgErr = 13,
    NotifMsgVerErr = 14,
    NotifMsg = 15,
    KeepaliveMsg = 16,
    UpdateMsg = 17,
    UpdateMsgErr = 18
}

/// <summary>MessageType matching the Idris2 ABI tags (0-3).</summary>
public enum MessageType : byte
{
    Open = 0,
    Update = 1,
    Notification = 2,
    Keepalive = 3
}

/// <summary>ErrorCode matching the Idris2 ABI tags (0-5).</summary>
public enum ErrorCode : byte
{
    MessageHeaderError = 0,
    OpenMessageError = 1,
    UpdateMessageError = 2,
    HoldTimerExpired = 3,
    FsmError = 4,
    Cease = 5
}

/// <summary>Origin matching the Idris2 ABI tags (0-2).</summary>
public enum Origin : byte
{
    Igp = 0,
    Egp = 1,
    Incomplete = 2
}

/// <summary>AsPathSegmentType matching the Idris2 ABI tags (0-1).</summary>
public enum AsPathSegmentType : byte
{
    AsSet = 0,
    AsSequence = 1
}

/// <summary>PathAttrType matching the Idris2 ABI tags (0-7).</summary>
public enum PathAttrType : byte
{
    Origin = 0,
    AsPath = 1,
    NextHop = 2,
    Med = 3,
    LocalPref = 4,
    AtomicAggr = 5,
    Aggregator = 6,
    Unknown = 7
}
