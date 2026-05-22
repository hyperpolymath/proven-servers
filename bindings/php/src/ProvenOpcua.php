<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OPC UA protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** ServiceType matching the Idris2 ABI tags. */
enum ServiceType: int
{
    case Read = 0;
    case Write = 1;
    case Browse = 2;
    case Subscribe = 3;
    case Publish = 4;
    case Call = 5;
    case CreateSession = 6;
    case ActivateSession = 7;
    case CloseSession = 8;
    case CreateSubscription = 9;
    case DeleteSubscription = 10;
}

/** NodeClass matching the Idris2 ABI tags. */
enum NodeClass: int
{
    case Object = 0;
    case Variable = 1;
    case Method = 2;
    case ObjectType = 3;
    case VariableType = 4;
    case ReferenceType = 5;
    case DataType = 6;
    case View = 7;
}

/** StatusCode matching the Idris2 ABI tags. */
enum StatusCode: int
{
    case Good = 0;
    case Uncertain = 1;
    case Bad = 2;
    case BadNodeIdUnknown = 3;
    case BadAttributeIdInvalid = 4;
    case BadNotReadable = 5;
    case BadNotWritable = 6;
    case BadOutOfRange = 7;
    case BadTypeMismatch = 8;
    case BadSessionIdInvalid = 9;
    case BadSubscriptionIdInvalid = 10;
    case BadTimeout = 11;
}

/** SecurityMode matching the Idris2 ABI tags. */
enum SecurityMode: int
{
    case None = 0;
    case Sign = 1;
    case SignAndEncrypt = 2;
}

/** SessionState matching the Idris2 ABI tags. */
enum SessionState: int
{
    case Idle = 0;
    case Connected = 1;
    case Created = 2;
    case Activated = 3;
    case Monitoring = 4;
    case Closing = 5;
}
