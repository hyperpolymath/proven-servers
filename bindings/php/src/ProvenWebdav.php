<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WebDAV protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Method matching the Idris2 ABI tags. */
enum Method: int
{
    case Propfind = 0;
    case Proppatch = 1;
    case Mkcol = 2;
    case Copy = 3;
    case Move = 4;
    case Lock = 5;
    case Unlock = 6;
}

/** StatusCode matching the Idris2 ABI tags. */
enum StatusCode: int
{
    case MultiStatus = 0;
    case UnprocessableEntity = 1;
    case Locked = 2;
    case FailedDependency = 3;
    case InsufficientStorage = 4;
}

/** LockScope matching the Idris2 ABI tags. */
enum LockScope: int
{
    case Exclusive = 0;
    case Shared = 1;
}

/** LockType matching the Idris2 ABI tags. */
enum LockType: int
{
    case Write = 0;
}

/** Depth matching the Idris2 ABI tags. */
enum Depth: int
{
    case Zero = 0;
    case One = 1;
    case Infinity = 2;
}

/** PropertyOp matching the Idris2 ABI tags. */
enum PropertyOp: int
{
    case Set = 0;
    case Remove = 1;
}
