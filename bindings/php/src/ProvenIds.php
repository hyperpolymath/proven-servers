<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IDS protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** AlertSeverity matching the Idris2 ABI tags. */
enum AlertSeverity: int
{
    case AlertSeverity_Low = 0;
    case AlertSeverity_Medium = 1;
    case AlertSeverity_High = 2;
    case AlertSeverity_Critical = 3;
}

/** DetectionMethod matching the Idris2 ABI tags. */
enum DetectionMethod: int
{
    case Signature = 0;
    case Anomaly = 1;
    case Stateful = 2;
    case Heuristic = 3;
}

/** IdsProtocol matching the Idris2 ABI tags. */
enum IdsProtocol: int
{
    case Tcp = 0;
    case Udp = 1;
    case Icmp = 2;
    case Dns = 3;
    case Http = 4;
    case Tls = 5;
    case Ssh = 6;
}

/** IdsAction matching the Idris2 ABI tags. */
enum IdsAction: int
{
    case Alert = 0;
    case Drop = 1;
    case Log = 2;
    case Block = 3;
    case Pass = 4;
}

/** Direction matching the Idris2 ABI tags. */
enum Direction: int
{
    case Inbound = 0;
    case Outbound = 1;
    case Both = 2;
}

/** ThreatLevel matching the Idris2 ABI tags. */
enum ThreatLevel: int
{
    case Info = 0;
    case ThreatLevel_Low = 1;
    case ThreatLevel_Medium = 2;
    case ThreatLevel_High = 3;
    case ThreatLevel_Critical = 4;
}
