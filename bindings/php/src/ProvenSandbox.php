<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Sandbox protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** ExecutionPolicy matching the Idris2 ABI tags. */
enum ExecutionPolicy: int
{
    case Unrestricted = 0;
    case ReadOnly = 1;
    case NetworkDenied = 2;
    case Isolated = 3;
    case Ephemeral = 4;
}

/** ResourceLimit matching the Idris2 ABI tags. */
enum ResourceLimit: int
{
    case CpuTime = 0;
    case Memory = 1;
    case DiskIo = 2;
    case NetworkIo = 3;
    case FileDescriptors = 4;
    case Processes = 5;
}

/** SandboxState matching the Idris2 ABI tags. */
enum SandboxState: int
{
    case Creating = 0;
    case Ready = 1;
    case Running = 2;
    case Suspended = 3;
    case Terminated = 4;
    case Destroyed = 5;
}

/** ExitReason matching the Idris2 ABI tags. */
enum ExitReason: int
{
    case Normal = 0;
    case Timeout = 1;
    case MemoryExceeded = 2;
    case PolicyViolation = 3;
    case Killed = 4;
    case Error = 5;
}

/** SyscallPolicy matching the Idris2 ABI tags. */
enum SyscallPolicy: int
{
    case Allow = 0;
    case Deny = 1;
    case Log = 2;
    case Trap = 3;
}
