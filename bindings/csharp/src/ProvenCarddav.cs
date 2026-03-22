// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CardDAV protocol types for proven-servers.

namespace Proven;

/// <summary>PropertyType matching the Idris2 ABI tags (0-8).</summary>
public enum PropertyType : byte
{
    FnName = 0,
    N = 1,
    Email = 2,
    Tel = 3,
    Adr = 4,
    Org = 5,
    Photo = 6,
    Url = 7,
    Note = 8
}

/// <summary>CardMethod matching the Idris2 ABI tags (0-6).</summary>
public enum CardMethod : byte
{
    Get = 0,
    Put = 1,
    Delete = 2,
    Propfind = 3,
    Proppatch = 4,
    Report = 5,
    Mkcol = 6
}

/// <summary>VCardVersion matching the Idris2 ABI tags (0-1).</summary>
public enum VCardVersion : byte
{
    Vcard3 = 0,
    Vcard4 = 1
}

/// <summary>CardError matching the Idris2 ABI tags (0-5).</summary>
public enum CardError : byte
{
    ValidAddressData = 0,
    NoResourceType = 1,
    MaxResourceSize = 2,
    UidConflict = 3,
    SupportedAddressData = 4,
    PreconditionFailed = 5
}

/// <summary>ServerState matching the Idris2 ABI tags (0-3).</summary>
public enum ServerState : byte
{
    Idle = 0,
    Bound = 1,
    Serving = 2,
    Shutdown = 3
}
