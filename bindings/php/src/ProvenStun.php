<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// STUN/TURN protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** MessageType matching the Idris2 ABI tags. */
enum MessageType: int
{
    case BindingRequest = 0;
    case BindingResponse = 1;
    case BindingError = 2;
    case AllocateRequest = 3;
    case AllocateResponse = 4;
    case AllocateError = 5;
    case RefreshRequest = 6;
    case RefreshResponse = 7;
    case SendIndication = 8;
    case DataIndication = 9;
    case CreatePermission = 10;
    case ChannelBind = 11;
}

/** TransportProtocol matching the Idris2 ABI tags. */
enum TransportProtocol: int
{
    case Udp = 0;
    case Tcp = 1;
    case Tls = 2;
    case Dtls = 3;
}

/** ErrorCode matching the Idris2 ABI tags. */
enum ErrorCode: int
{
    case TryAlternate = 0;
    case BadRequest = 1;
    case Unauthorized = 2;
    case Forbidden = 3;
    case MobilityForbidden = 4;
    case StaleNonce = 5;
    case ServerError = 6;
    case InsufficientCapacity = 7;
}
