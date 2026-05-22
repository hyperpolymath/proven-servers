// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SMB protocol types for proven-servers.

namespace Proven;

/// <summary>Command matching the Idris2 ABI tags (0-15).</summary>
public enum Command : byte
{
    Negotiate = 0,
    SessionSetup = 1,
    Logoff = 2,
    TreeConnect = 3,
    TreeDisconnect = 4,
    Create = 5,
    Close = 6,
    Read = 7,
    Write = 8,
    Lock = 9,
    Ioctl = 10,
    Cancel = 11,
    QueryDirectory = 12,
    ChangeNotify = 13,
    QueryInfo = 14,
    SetInfo = 15
}

/// <summary>Dialect matching the Idris2 ABI tags (0-4).</summary>
public enum Dialect : byte
{
    Smb2_0_2 = 0,
    Smb2_1 = 1,
    Smb3_0 = 2,
    Smb3_0_2 = 3,
    Smb3_1_1 = 4
}

/// <summary>ShareType matching the Idris2 ABI tags (0-2).</summary>
public enum ShareType : byte
{
    Disk = 0,
    Pipe = 1,
    Print = 2
}

/// <summary>SessionState matching the Idris2 ABI tags (0-5).</summary>
public enum SessionState : byte
{
    Idle = 0,
    Negotiated = 1,
    Authenticated = 2,
    TreeConnected = 3,
    FileOpen = 4,
    Disconnecting = 5
}
