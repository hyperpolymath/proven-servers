// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PTP protocol types for proven-servers.

namespace Proven;

/// <summary>PtpMessageType matching the Idris2 ABI tags (0-9).</summary>
public enum PtpMessageType : byte
{
    Sync = 0,
    DelayReq = 1,
    PdelayReq = 2,
    PdelayResp = 3,
    FollowUp = 4,
    DelayResp = 5,
    PdelayRespFollowUp = 6,
    Announce = 7,
    Signaling = 8,
    Management = 9
}

/// <summary>ClockClass matching the Idris2 ABI tags (0-3).</summary>
public enum ClockClass : byte
{
    PrimaryClock = 0,
    ApplicationSpecific = 1,
    SlaveOnly = 2,
    DefaultClass = 3
}

/// <summary>PtpPortState matching the Idris2 ABI tags (0-8).</summary>
public enum PtpPortState : byte
{
    Initializing = 0,
    Faulty = 1,
    Disabled = 2,
    Listening = 3,
    PreMaster = 4,
    Master = 5,
    Passive = 6,
    Uncalibrated = 7,
    Slave = 8
}

/// <summary>DelayMechanism matching the Idris2 ABI tags (0-2).</summary>
public enum DelayMechanism : byte
{
    E2E = 0,
    P2P = 1,
    DmDisabled = 2
}
