// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SIEM protocol types for proven-servers.

namespace Proven;

/// <summary>EventSeverity matching the Idris2 ABI tags (0-4).</summary>
public enum EventSeverity : byte
{
    Info = 0,
    Low = 1,
    Medium = 2,
    High = 3,
    Critical = 4
}

/// <summary>EventCategory matching the Idris2 ABI tags (0-6).</summary>
public enum EventCategory : byte
{
    Authentication = 0,
    NetworkTraffic = 1,
    FileActivity = 2,
    ProcessExecution = 3,
    PolicyViolation = 4,
    Malware = 5,
    DataExfiltration = 6
}

/// <summary>CorrelationRule matching the Idris2 ABI tags (0-4).</summary>
public enum CorrelationRule : byte
{
    Threshold = 0,
    Sequence = 1,
    Aggregation = 2,
    Absence = 3,
    Statistical = 4
}

/// <summary>AlertState matching the Idris2 ABI tags (0-4).</summary>
public enum AlertState : byte
{
    New = 0,
    Acknowledged = 1,
    InProgress = 2,
    Resolved = 3,
    FalsePositive = 4
}
