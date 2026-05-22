<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// POP3 protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Command matching the Idris2 ABI tags. */
enum Command: int
{
    case User = 0;
    case Pass = 1;
    case Stat = 2;
    case List = 3;
    case Retr = 4;
    case Dele = 5;
    case Noop = 6;
    case Rset = 7;
    case Quit = 8;
    case Top = 9;
    case Uidl = 10;
}

/** State matching the Idris2 ABI tags. */
enum State: int
{
    case Authorization = 0;
    case Transaction = 1;
    case Update = 2;
}

/** Response matching the Idris2 ABI tags. */
enum Response: int
{
    case Response_Ok = 0;
    case Err = 1;
}

/** Pop3Error matching the Idris2 ABI tags. */
enum Pop3Error: int
{
    case Pop3Error_Ok = 0;
    case InvalidSlot = 1;
    case NotActive = 2;
    case InvalidTransition = 3;
    case InvalidCommand = 4;
    case AuthFailed = 5;
}
