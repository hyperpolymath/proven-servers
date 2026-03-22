<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Monitor protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** CheckType matching the Idris2 ABI tags. */
enum CheckType: int
{
    case Http = 0;
    case Tcp = 1;
    case Udp = 2;
    case Icmp = 3;
    case Dns = 4;
    case Certificate = 5;
    case Disk = 6;
    case Cpu = 7;
    case Memory = 8;
    case Process = 9;
    case Custom = 10;
}

/** Status matching the Idris2 ABI tags. */
enum Status: int
{
    case Up = 0;
    case Down = 1;
    case Degraded = 2;
    case Unknown = 3;
    case Maintenance = 4;
}

/** AlertChannel matching the Idris2 ABI tags. */
enum AlertChannel: int
{
    case Email = 0;
    case Sms = 1;
    case Webhook = 2;
    case Slack = 3;
    case PagerDuty = 4;
}

/** Severity matching the Idris2 ABI tags. */
enum Severity: int
{
    case Info = 0;
    case Warning = 1;
    case Error = 2;
    case Critical = 3;
}

/** CheckState matching the Idris2 ABI tags. */
enum CheckState: int
{
    case Pending = 0;
    case CheckState_Running = 1;
    case Passed = 2;
    case Failed = 3;
    case Timeout = 4;
    case CsError = 5;
}

/** MonitorState matching the Idris2 ABI tags. */
enum MonitorState: int
{
    case Idle = 0;
    case Configured = 1;
    case MonitorState_Running = 2;
    case MonPaused = 3;
    case Alerting = 4;
    case Shutdown = 5;
}
