// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WebDAV protocol types for proven-servers.

namespace Proven;

/// <summary>Method matching the Idris2 ABI tags (0-6).</summary>
public enum Method : byte
{
    Propfind = 0,
    Proppatch = 1,
    Mkcol = 2,
    Copy = 3,
    Move = 4,
    Lock = 5,
    Unlock = 6
}

/// <summary>StatusCode matching the Idris2 ABI tags (0-4).</summary>
public enum StatusCode : byte
{
    MultiStatus = 0,
    UnprocessableEntity = 1,
    Locked = 2,
    FailedDependency = 3,
    InsufficientStorage = 4
}

/// <summary>LockScope matching the Idris2 ABI tags (0-1).</summary>
public enum LockScope : byte
{
    Exclusive = 0,
    Shared = 1
}

/// <summary>LockType matching the Idris2 ABI tags (0-0).</summary>
public enum LockType : byte
{
    Write = 0
}

/// <summary>Depth matching the Idris2 ABI tags (0-2).</summary>
public enum Depth : byte
{
    Zero = 0,
    One = 1,
    Infinity = 2
}

/// <summary>PropertyOp matching the Idris2 ABI tags (0-1).</summary>
public enum PropertyOp : byte
{
    Set = 0,
    Remove = 1
}
