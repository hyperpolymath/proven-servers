<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NETCONF protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** NetconfOperation matching the Idris2 ABI tags. */
enum NetconfOperation: int
{
    case Get = 0;
    case GetConfig = 1;
    case EditConfig = 2;
    case CopyConfig = 3;
    case DeleteConfig = 4;
    case Lock = 5;
    case Unlock = 6;
    case CloseSession = 7;
    case KillSession = 8;
    case Commit = 9;
    case Validate = 10;
    case DiscardChanges = 11;
}

/** Datastore matching the Idris2 ABI tags. */
enum Datastore: int
{
    case Running = 0;
    case Startup = 1;
    case Candidate = 2;
}

/** EditOperation matching the Idris2 ABI tags. */
enum EditOperation: int
{
    case Merge = 0;
    case Replace = 1;
    case Create = 2;
    case Delete = 3;
    case Remove = 4;
}

/** NetconfErrorType matching the Idris2 ABI tags. */
enum NetconfErrorType: int
{
    case Transport = 0;
    case Rpc = 1;
    case Protocol = 2;
    case Application = 3;
}

/** ErrorSeverity matching the Idris2 ABI tags. */
enum ErrorSeverity: int
{
    case Error = 0;
    case Warning = 1;
}

/** NetconfState matching the Idris2 ABI tags. */
enum NetconfState: int
{
    case Idle = 0;
    case Connected = 1;
    case Locked = 2;
    case Editing = 3;
    case Closing = 4;
    case Terminated = 5;
}
