// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Monitor protocol types for proven-servers.

namespace Proven;

/// <summary>CheckType matching the Idris2 ABI tags (0-10).</summary>
public enum CheckType : byte
{
    Http = 0,
    Tcp = 1,
    Udp = 2,
    Icmp = 3,
    Dns = 4,
    Certificate = 5,
    Disk = 6,
    Cpu = 7,
    Memory = 8,
    Process = 9,
    Custom = 10
}

/// <summary>Status matching the Idris2 ABI tags (0-4).</summary>
public enum Status : byte
{
    Up = 0,
    Down = 1,
    Degraded = 2,
    Unknown = 3,
    Maintenance = 4
}

/// <summary>AlertChannel matching the Idris2 ABI tags (0-4).</summary>
public enum AlertChannel : byte
{
    Email = 0,
    Sms = 1,
    Webhook = 2,
    Slack = 3,
    PagerDuty = 4
}

/// <summary>Severity matching the Idris2 ABI tags (0-3).</summary>
public enum Severity : byte
{
    Info = 0,
    Warning = 1,
    Error = 2,
    Critical = 3
}

/// <summary>CheckState matching the Idris2 ABI tags (0-5).</summary>
public enum CheckState : byte
{
    Pending = 0,
    Running = 1,
    Passed = 2,
    Failed = 3,
    Timeout = 4,
    CsError = 5
}

/// <summary>MonitorState matching the Idris2 ABI tags (0-5).</summary>
public enum MonitorState : byte
{
    Idle = 0,
    Configured = 1,
    Running = 2,
    MonPaused = 3,
    Alerting = 4,
    Shutdown = 5
}
