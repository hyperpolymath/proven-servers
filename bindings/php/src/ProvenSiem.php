<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SIEM protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** EventSeverity matching the Idris2 ABI tags. */
enum EventSeverity: int
{
    case Info = 0;
    case Low = 1;
    case Medium = 2;
    case High = 3;
    case Critical = 4;
}

/** EventCategory matching the Idris2 ABI tags. */
enum EventCategory: int
{
    case Authentication = 0;
    case NetworkTraffic = 1;
    case FileActivity = 2;
    case ProcessExecution = 3;
    case PolicyViolation = 4;
    case Malware = 5;
    case DataExfiltration = 6;
}

/** CorrelationRule matching the Idris2 ABI tags. */
enum CorrelationRule: int
{
    case Threshold = 0;
    case Sequence = 1;
    case Aggregation = 2;
    case Absence = 3;
    case Statistical = 4;
}

/** AlertState matching the Idris2 ABI tags. */
enum AlertState: int
{
    case New = 0;
    case Acknowledged = 1;
    case InProgress = 2;
    case Resolved = 3;
    case FalsePositive = 4;
}
