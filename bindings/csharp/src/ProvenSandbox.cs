// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Sandbox protocol types for proven-servers.

namespace Proven;

/// <summary>ExecutionPolicy matching the Idris2 ABI tags (0-4).</summary>
public enum ExecutionPolicy : byte
{
    Unrestricted = 0,
    ReadOnly = 1,
    NetworkDenied = 2,
    Isolated = 3,
    Ephemeral = 4
}

/// <summary>ResourceLimit matching the Idris2 ABI tags (0-5).</summary>
public enum ResourceLimit : byte
{
    CpuTime = 0,
    Memory = 1,
    DiskIo = 2,
    NetworkIo = 3,
    FileDescriptors = 4,
    Processes = 5
}

/// <summary>SandboxState matching the Idris2 ABI tags (0-5).</summary>
public enum SandboxState : byte
{
    Creating = 0,
    Ready = 1,
    Running = 2,
    Suspended = 3,
    Terminated = 4,
    Destroyed = 5
}

/// <summary>ExitReason matching the Idris2 ABI tags (0-5).</summary>
public enum ExitReason : byte
{
    Normal = 0,
    Timeout = 1,
    MemoryExceeded = 2,
    PolicyViolation = 3,
    Killed = 4,
    Error = 5
}

/// <summary>SyscallPolicy matching the Idris2 ABI tags (0-3).</summary>
public enum SyscallPolicy : byte
{
    Allow = 0,
    Deny = 1,
    Log = 2,
    Trap = 3
}
