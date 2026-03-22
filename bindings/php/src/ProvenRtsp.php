<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// RTSP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Method matching the Idris2 ABI tags. */
enum Method: int
{
    case Describe = 0;
    case Setup = 1;
    case Play = 2;
    case Pause = 3;
    case Teardown = 4;
    case GetParameter = 5;
    case SetParameter = 6;
    case Options = 7;
    case Announce = 8;
    case Record = 9;
    case Redirect = 10;
}

/** TransportProtocol matching the Idris2 ABI tags. */
enum TransportProtocol: int
{
    case RtpAvpUdp = 0;
    case RtpAvpTcp = 1;
    case RtpAvpUdpMulticast = 2;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Init = 0;
    case Ready = 1;
    case Playing = 2;
    case Recording = 3;
}

/** StatusCode matching the Idris2 ABI tags. */
enum StatusCode: int
{
    case StatusCode_Ok = 0;
    case MovedPermanently = 1;
    case MovedTemporarily = 2;
    case BadRequest = 3;
    case Unauthorized = 4;
    case NotFound = 5;
    case StatusCode_MethodNotAllowed = 6;
    case NotAcceptable = 7;
    case SessionNotFound = 8;
    case InternalServerError = 9;
    case NotImplemented = 10;
    case ServiceUnavailable = 11;
}

/** RtspError matching the Idris2 ABI tags. */
enum RtspError: int
{
    case RtspError_Ok = 0;
    case InvalidSlot = 1;
    case NotActive = 2;
    case InvalidTransition = 3;
    case RtspError_MethodNotAllowed = 4;
    case TransportError = 5;
    case SessionExpired = 6;
}
