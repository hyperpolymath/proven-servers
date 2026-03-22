// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SNMP protocol types for proven-servers.

namespace Proven;

/// <summary>Version matching the Idris2 ABI tags (0-2).</summary>
public enum Version : byte
{
    V1 = 0,
    V2c = 1,
    V3 = 2
}

/// <summary>PduType matching the Idris2 ABI tags (0-6).</summary>
public enum PduType : byte
{
    GetRequest = 0,
    GetNextRequest = 1,
    GetResponse = 2,
    SetRequest = 3,
    GetBulkRequest = 4,
    InformRequest = 5,
    SnmpV2Trap = 6
}

/// <summary>ErrorStatus matching the Idris2 ABI tags (0-15).</summary>
public enum ErrorStatus : byte
{
    NoError = 0,
    TooBig = 1,
    NoSuchName = 2,
    BadValue = 3,
    ReadOnly = 4,
    GenErr = 5,
    NoAccess = 6,
    WrongType = 7,
    WrongLength = 8,
    WrongValue = 9,
    NoCreation = 10,
    InconsistentValue = 11,
    ResourceUnavailable = 12,
    CommitFailed = 13,
    UndoFailed = 14,
    AuthorizationError = 15
}
