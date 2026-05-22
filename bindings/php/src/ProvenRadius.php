<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// RADIUS protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** PacketType matching the Idris2 ABI tags. */
enum PacketType: int
{
    case AccessRequest = 1;
    case AccessAccept = 2;
    case AccessReject = 3;
    case AccountingRequest = 4;
    case AccountingResponse = 5;
    case AccessChallenge = 11;
}

/** AttributeType matching the Idris2 ABI tags. */
enum AttributeType: int
{
    case UserName = 1;
    case UserPassword = 2;
    case NasIpAddress = 4;
    case NasPort = 5;
    case ServiceType = 6;
    case FramedProtocol = 7;
    case FramedIpAddress = 8;
    case ReplyMessage = 18;
    case SessionTimeout = 27;
}

/** ServiceType matching the Idris2 ABI tags. */
enum ServiceType: int
{
    case Login = 1;
    case Framed = 2;
    case CallbackLogin = 3;
    case CallbackFramed = 4;
    case Outbound = 5;
    case Administrative = 6;
}

/** AuthMethod matching the Idris2 ABI tags. */
enum AuthMethod: int
{
    case Pap = 0;
    case Chap = 1;
    case Mschap = 2;
    case Mschapv2 = 3;
    case Eap = 4;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Idle = 0;
    case Authenticating = 1;
    case Authorized = 2;
    case Rejected = 3;
    case Challenged = 4;
    case Accounting = 5;
    case Complete = 6;
}

/** RadiusResult matching the Idris2 ABI tags. */
enum RadiusResult: int
{
    case Ok = 0;
    case Err = 1;
    case InvalidParam = 2;
    case PoolExhausted = 3;
    case BadSecret = 4;
}
