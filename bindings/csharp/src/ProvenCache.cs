// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Cache protocol types for proven-servers.

namespace Proven;

/// <summary>Command matching the Idris2 ABI tags (0-12).</summary>
public enum Command : byte
{
    Get = 0,
    Set = 1,
    Delete = 2,
    Exists = 3,
    Expire = 4,
    Ttl = 5,
    Keys = 6,
    Flush = 7,
    Incr = 8,
    Decr = 9,
    Append = 10,
    Prepend = 11,
    Cas = 12
}

/// <summary>EvictionPolicy matching the Idris2 ABI tags (0-4).</summary>
public enum EvictionPolicy : byte
{
    Lru = 0,
    Lfu = 1,
    Random = 2,
    EvictTtl = 3,
    NoEviction = 4
}

/// <summary>DataType matching the Idris2 ABI tags (0-4).</summary>
public enum DataType : byte
{
    StringVal = 0,
    IntVal = 1,
    ListVal = 2,
    SetVal = 3,
    HashVal = 4
}

/// <summary>ErrorCode matching the Idris2 ABI tags (0-5).</summary>
public enum ErrorCode : byte
{
    NotFound = 0,
    TypeMismatch = 1,
    OutOfMemory = 2,
    KeyTooLong = 3,
    ValueTooLarge = 4,
    CasConflict = 5
}

/// <summary>ReplicationMode matching the Idris2 ABI tags (0-3).</summary>
public enum ReplicationMode : byte
{
    None = 0,
    Primary = 1,
    Replica = 2,
    Sentinel = 3
}
