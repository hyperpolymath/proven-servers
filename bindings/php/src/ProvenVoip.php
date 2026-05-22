<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// VoIP/SIP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Method matching the Idris2 ABI tags. */
enum Method: int
{
    case Invite = 0;
    case Ack = 1;
    case Bye = 2;
    case Cancel = 3;
    case Register = 4;
    case Options = 5;
    case Info = 6;
    case Update = 7;
    case Subscribe = 8;
    case Notify = 9;
    case Refer = 10;
    case Message = 11;
    case Prack = 12;
}

/** ResponseCode matching the Idris2 ABI tags. */
enum ResponseCode: int
{
    case Trying = 0;
    case Ringing = 1;
    case SessionProgress = 2;
    case Ok = 3;
    case MultipleChoices = 4;
    case MovedPermanently = 5;
    case MovedTemporarily = 6;
    case BadRequest = 7;
    case Unauthorized = 8;
    case Forbidden = 9;
    case NotFound = 10;
    case MethodNotAllowed = 11;
    case RequestTimeout = 12;
    case BusyHere = 13;
    case Decline = 14;
    case ServerInternalError = 15;
    case ServiceUnavailable = 16;
}

/** DialogState matching the Idris2 ABI tags. */
enum DialogState: int
{
    case Early = 0;
    case Confirmed = 1;
    case Terminated = 2;
}
