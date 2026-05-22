// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TFTP protocol types for proven-servers.

namespace Proven;

/// <summary>Opcode matching the Idris2 ABI tags (0-4).</summary>
public enum Opcode : byte
{
    Rrq = 0,
    Wrq = 1,
    Data = 2,
    Ack = 3,
    Error = 4
}

/// <summary>TransferMode matching the Idris2 ABI tags (0-2).</summary>
public enum TransferMode : byte
{
    NetAscii = 0,
    Octet = 1,
    Mail = 2
}

/// <summary>TftpError matching the Idris2 ABI tags (0-7).</summary>
public enum TftpError : byte
{
    NotDefined = 0,
    FileNotFound = 1,
    AccessViolation = 2,
    DiskFull = 3,
    IllegalOperation = 4,
    UnknownTid = 5,
    FileExists = 6,
    NoSuchUser = 7
}

/// <summary>TransferState matching the Idris2 ABI tags (0-4).</summary>
public enum TransferState : byte
{
    Idle = 0,
    Reading = 1,
    Writing = 2,
    InError = 3,
    Complete = 4
}
