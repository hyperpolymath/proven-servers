// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LDAP protocol types for proven-servers.

namespace Proven;

/// <summary>SessionState matching the Idris2 ABI tags (0-3).</summary>
public enum SessionState : byte
{
    Anonymous = 0,
    Bound = 1,
    Closed = 2,
    Binding = 3
}

/// <summary>Operation matching the Idris2 ABI tags (0-9).</summary>
public enum Operation : byte
{
    Bind = 0,
    Unbind = 1,
    Search = 2,
    Modify = 3,
    Add = 4,
    Delete = 5,
    ModDn = 6,
    Compare = 7,
    Abandon = 8,
    Extended = 9
}

/// <summary>SearchScope matching the Idris2 ABI tags (0-2).</summary>
public enum SearchScope : byte
{
    BaseObject = 0,
    SingleLevel = 1,
    WholeSubtree = 2
}

/// <summary>ResultCode matching the Idris2 ABI tags (0-10).</summary>
public enum ResultCode : byte
{
    Success = 0,
    OperationsError = 1,
    ProtocolError = 2,
    TimeLimitExceeded = 3,
    SizeLimitExceeded = 4,
    AuthMethodNotSupported = 5,
    NoSuchObject = 6,
    InvalidCredentials = 7,
    InsufficientAccessRights = 8,
    Busy = 9,
    Unavailable = 10
}
