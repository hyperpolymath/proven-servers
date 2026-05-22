<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Telnet protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Command matching the Idris2 ABI tags. */
enum Command: int
{
    case Se = 0;
    case Nop = 1;
    case DataMark = 2;
    case Break = 3;
    case InterruptProcess = 4;
    case AbortOutput = 5;
    case AreYouThere = 6;
    case EraseChar = 7;
    case EraseLine = 8;
    case GoAhead = 9;
    case Sb = 10;
    case Will = 11;
    case Wont = 12;
    case Do = 13;
    case Dont = 14;
    case Iac = 15;
}

/** TelnetOption matching the Idris2 ABI tags. */
enum TelnetOption: int
{
    case Echo = 0;
    case SuppressGoAhead = 1;
    case Status = 2;
    case TimingMark = 3;
    case TerminalType = 4;
    case WindowSize = 5;
    case TerminalSpeed = 6;
    case RemoteFlowControl = 7;
    case Linemode = 8;
    case Environment = 9;
}

/** NegotiationState matching the Idris2 ABI tags. */
enum NegotiationState: int
{
    case Inactive = 0;
    case WillSent = 1;
    case DoSent = 2;
    case NegotiationState_Active = 3;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Idle = 0;
    case Negotiating = 1;
    case SessionState_Active = 2;
    case Subneg = 3;
    case Closing = 4;
}
