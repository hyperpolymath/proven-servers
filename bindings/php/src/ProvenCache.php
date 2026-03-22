<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Cache protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Command matching the Idris2 ABI tags. */
enum Command: int
{
    case Get = 0;
    case Set = 1;
    case Delete = 2;
    case Exists = 3;
    case Expire = 4;
    case Ttl = 5;
    case Keys = 6;
    case Flush = 7;
    case Incr = 8;
    case Decr = 9;
    case Append = 10;
    case Prepend = 11;
    case Cas = 12;
}

/** EvictionPolicy matching the Idris2 ABI tags. */
enum EvictionPolicy: int
{
    case Lru = 0;
    case Lfu = 1;
    case Random = 2;
    case EvictTtl = 3;
    case NoEviction = 4;
}

/** DataType matching the Idris2 ABI tags. */
enum DataType: int
{
    case StringVal = 0;
    case IntVal = 1;
    case ListVal = 2;
    case SetVal = 3;
    case HashVal = 4;
}

/** ErrorCode matching the Idris2 ABI tags. */
enum ErrorCode: int
{
    case NotFound = 0;
    case TypeMismatch = 1;
    case OutOfMemory = 2;
    case KeyTooLong = 3;
    case ValueTooLarge = 4;
    case CasConflict = 5;
}

/** ReplicationMode matching the Idris2 ABI tags. */
enum ReplicationMode: int
{
    case None = 0;
    case Primary = 1;
    case Replica = 2;
    case Sentinel = 3;
}
