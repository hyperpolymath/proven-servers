// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NETCONF protocol types for proven-servers.

namespace Proven;

/// <summary>NetconfOperation matching the Idris2 ABI tags (0-11).</summary>
public enum NetconfOperation : byte
{
    Get = 0,
    GetConfig = 1,
    EditConfig = 2,
    CopyConfig = 3,
    DeleteConfig = 4,
    Lock = 5,
    Unlock = 6,
    CloseSession = 7,
    KillSession = 8,
    Commit = 9,
    Validate = 10,
    DiscardChanges = 11
}

/// <summary>Datastore matching the Idris2 ABI tags (0-2).</summary>
public enum Datastore : byte
{
    Running = 0,
    Startup = 1,
    Candidate = 2
}

/// <summary>EditOperation matching the Idris2 ABI tags (0-4).</summary>
public enum EditOperation : byte
{
    Merge = 0,
    Replace = 1,
    Create = 2,
    Delete = 3,
    Remove = 4
}

/// <summary>NetconfErrorType matching the Idris2 ABI tags (0-3).</summary>
public enum NetconfErrorType : byte
{
    Transport = 0,
    Rpc = 1,
    Protocol = 2,
    Application = 3
}

/// <summary>ErrorSeverity matching the Idris2 ABI tags (0-1).</summary>
public enum ErrorSeverity : byte
{
    Error = 0,
    Warning = 1
}

/// <summary>NetconfState matching the Idris2 ABI tags (0-5).</summary>
public enum NetconfState : byte
{
    Idle = 0,
    Connected = 1,
    Locked = 2,
    Editing = 3,
    Closing = 4,
    Terminated = 5
}
