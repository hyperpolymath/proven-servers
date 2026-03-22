// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TACACS+ protocol types for proven-servers.

namespace Proven;

/// <summary>PacketType matching the Idris2 ABI tags (0-2).</summary>
public enum PacketType : byte
{
    Authentication = 0,
    Authorization = 1,
    Accounting = 2
}

/// <summary>AuthenType matching the Idris2 ABI tags (0-4).</summary>
public enum AuthenType : byte
{
    Ascii = 0,
    Pap = 1,
    Chap = 2,
    MsChapV1 = 3,
    MsChapV2 = 4
}

/// <summary>AuthenAction matching the Idris2 ABI tags (0-2).</summary>
public enum AuthenAction : byte
{
    Login = 0,
    ChangePass = 1,
    SendAuth = 2
}

/// <summary>AuthenStatus matching the Idris2 ABI tags (0-7).</summary>
public enum AuthenStatus : byte
{
    Pass = 0,
    Fail = 1,
    GetData = 2,
    GetUser = 3,
    GetPass = 4,
    Restart = 5,
    Error = 6,
    Follow = 7
}

/// <summary>AuthorStatus matching the Idris2 ABI tags (0-4).</summary>
public enum AuthorStatus : byte
{
    PassAdd = 0,
    PassRepl = 1,
    Fail = 2,
    Error = 3,
    Follow = 4
}

/// <summary>AcctStatus matching the Idris2 ABI tags (0-2).</summary>
public enum AcctStatus : byte
{
    Success = 0,
    Error = 1,
    Follow = 2
}

/// <summary>AcctFlag matching the Idris2 ABI tags (0-2).</summary>
public enum AcctFlag : byte
{
    Start = 0,
    Stop = 1,
    Watchdog = 2
}

/// <summary>SessionState matching the Idris2 ABI tags (0-4).</summary>
public enum SessionState : byte
{
    Idle = 0,
    Authenticating = 1,
    Authorizing = 2,
    Active = 3,
    Closing = 4
}
