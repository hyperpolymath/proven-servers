<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PTP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** PtpMessageType matching the Idris2 ABI tags. */
enum PtpMessageType: int
{
    case Sync = 0;
    case DelayReq = 1;
    case PdelayReq = 2;
    case PdelayResp = 3;
    case FollowUp = 4;
    case DelayResp = 5;
    case PdelayRespFollowUp = 6;
    case Announce = 7;
    case Signaling = 8;
    case Management = 9;
}

/** ClockClass matching the Idris2 ABI tags. */
enum ClockClass: int
{
    case PrimaryClock = 0;
    case ApplicationSpecific = 1;
    case SlaveOnly = 2;
    case DefaultClass = 3;
}

/** PtpPortState matching the Idris2 ABI tags. */
enum PtpPortState: int
{
    case Initializing = 0;
    case Faulty = 1;
    case Disabled = 2;
    case Listening = 3;
    case PreMaster = 4;
    case Master = 5;
    case Passive = 6;
    case Uncalibrated = 7;
    case Slave = 8;
}

/** DelayMechanism matching the Idris2 ABI tags. */
enum DelayMechanism: int
{
    case E2E = 0;
    case P2P = 1;
    case DmDisabled = 2;
}
