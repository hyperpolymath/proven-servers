<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CoAP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Method matching the Idris2 ABI tags. */
enum Method: int
{
    case Get = 0;
    case Post = 1;
    case Put = 2;
    case Delete = 3;
}

/** MessageType matching the Idris2 ABI tags. */
enum MessageType: int
{
    case Confirmable = 0;
    case NonConfirmable = 1;
    case Acknowledgement = 2;
    case Reset = 3;
}

/** ContentFormat matching the Idris2 ABI tags. */
enum ContentFormat: int
{
    case TextPlain = 0;
    case LinkFormat = 1;
    case Xml = 2;
    case OctetStream = 3;
    case Exi = 4;
    case Json = 5;
    case Cbor = 6;
}

/** ResponseClass matching the Idris2 ABI tags. */
enum ResponseClass: int
{
    case Success = 0;
    case ClientError = 1;
    case ServerError = 2;
    case Signaling = 3;
    case Empty = 4;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Idle = 0;
    case Bound = 1;
    case Serving = 2;
    case Observing = 3;
    case Shutdown = 4;
}
