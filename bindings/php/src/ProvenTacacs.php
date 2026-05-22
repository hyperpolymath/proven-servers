<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TACACS+ protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** PacketType matching the Idris2 ABI tags. */
enum PacketType: int
{
    case Authentication = 0;
    case Authorization = 1;
    case Accounting = 2;
}

/** AuthenType matching the Idris2 ABI tags. */
enum AuthenType: int
{
    case Ascii = 0;
    case Pap = 1;
    case Chap = 2;
    case MsChapV1 = 3;
    case MsChapV2 = 4;
}

/** AuthenAction matching the Idris2 ABI tags. */
enum AuthenAction: int
{
    case Login = 0;
    case ChangePass = 1;
    case SendAuth = 2;
}

/** AuthenStatus matching the Idris2 ABI tags. */
enum AuthenStatus: int
{
    case Pass = 0;
    case AuthenStatus_Fail = 1;
    case GetData = 2;
    case GetUser = 3;
    case GetPass = 4;
    case Restart = 5;
    case AuthenStatus_Error = 6;
    case AuthenStatus_Follow = 7;
}

/** AuthorStatus matching the Idris2 ABI tags. */
enum AuthorStatus: int
{
    case PassAdd = 0;
    case PassRepl = 1;
    case AuthorStatus_Fail = 2;
    case AuthorStatus_Error = 3;
    case AuthorStatus_Follow = 4;
}

/** AcctStatus matching the Idris2 ABI tags. */
enum AcctStatus: int
{
    case Success = 0;
    case AcctStatus_Error = 1;
    case AcctStatus_Follow = 2;
}

/** AcctFlag matching the Idris2 ABI tags. */
enum AcctFlag: int
{
    case Start = 0;
    case Stop = 1;
    case Watchdog = 2;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Idle = 0;
    case Authenticating = 1;
    case Authorizing = 2;
    case Active = 3;
    case Closing = 4;
}
