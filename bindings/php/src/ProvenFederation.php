<?php
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Federation protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** ActivityType matching the Idris2 ABI tags. */
enum ActivityType: int
{
    case Create = 0;
    case Update = 1;
    case Delete = 2;
    case Follow = 3;
    case Accept = 4;
    case Reject = 5;
    case Announce = 6;
    case Like = 7;
    case Undo = 8;
    case Block = 9;
    case Flag = 10;
}

/** ActorType matching the Idris2 ABI tags. */
enum ActorType: int
{
    case Person = 0;
    case Service = 1;
    case Application = 2;
    case Group = 3;
    case Organization = 4;
}

/** DeliveryStatus matching the Idris2 ABI tags. */
enum DeliveryStatus: int
{
    case Pending = 0;
    case Delivered = 1;
    case Failed = 2;
    case Rejected = 3;
    case Deferred = 4;
}

/** TrustLevel matching the Idris2 ABI tags. */
enum TrustLevel: int
{
    case SelfSigned = 0;
    case PeerVerified = 1;
    case FederationTrusted = 2;
    case Revoked = 3;
    case Unknown = 4;
}

/** ObjectType matching the Idris2 ABI tags. */
enum ObjectType: int
{
    case Note = 0;
    case Article = 1;
    case Image = 2;
    case Video = 3;
    case Audio = 4;
    case Document = 5;
    case Event = 6;
    case Collection = 7;
    case OrderedCollection = 8;
}

/** ServerState matching the Idris2 ABI tags. */
enum ServerState: int
{
    case Idle = 0;
    case Active = 1;
    case Processing = 2;
    case Delivering = 3;
    case Shutdown = 4;
}
