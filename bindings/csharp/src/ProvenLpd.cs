// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LPD protocol types for proven-servers.

namespace Proven;

/// <summary>CommandCode matching the Idris2 ABI tags (0-4).</summary>
public enum CommandCode : byte
{
    PrintJob = 0,
    ReceiveJob = 1,
    ShortQueue = 2,
    LongQueue = 3,
    RemoveJobs = 4
}

/// <summary>SubCommandCode matching the Idris2 ABI tags (0-2).</summary>
public enum SubCommandCode : byte
{
    AbortJob = 0,
    ControlFile = 1,
    DataFile = 2
}

/// <summary>JobStatus matching the Idris2 ABI tags (0-3).</summary>
public enum JobStatus : byte
{
    Pending = 0,
    Printing = 1,
    Complete = 2,
    Failed = 3
}
