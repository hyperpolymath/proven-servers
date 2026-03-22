// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Config Mgmt protocol types for proven-servers.

namespace Proven;

/// <summary>ResourceType matching the Idris2 ABI tags (0-8).</summary>
public enum ResourceType : byte
{
    File = 0,
    Package = 1,
    Service = 2,
    User = 3,
    Group = 4,
    Cron = 5,
    Mount = 6,
    Firewall = 7,
    Registry = 8
}

/// <summary>ResourceState matching the Idris2 ABI tags (0-5).</summary>
public enum ResourceState : byte
{
    Present = 0,
    Absent = 1,
    Running = 2,
    Stopped = 3,
    Enabled = 4,
    Disabled = 5
}

/// <summary>ChangeAction matching the Idris2 ABI tags (0-5).</summary>
public enum ChangeAction : byte
{
    Create = 0,
    Modify = 1,
    Delete = 2,
    Restart = 3,
    Reload = 4,
    Skip = 5
}

/// <summary>DriftStatus matching the Idris2 ABI tags (0-3).</summary>
public enum DriftStatus : byte
{
    InSync = 0,
    Drifted = 1,
    DUnknown = 2,
    Unmanaged = 3
}

/// <summary>ApplyMode matching the Idris2 ABI tags (0-2).</summary>
public enum ApplyMode : byte
{
    Enforce = 0,
    DryRun = 1,
    Audit = 2
}
