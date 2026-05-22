<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Chat protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** MessageType matching the Idris2 ABI tags. */
enum MessageType: int
{
    case Text = 0;
    case Image = 1;
    case File = 2;
    case System = 3;
    case Reaction = 4;
    case Edit = 5;
    case Delete = 6;
    case Reply = 7;
    case Thread = 8;
}

/** PresenceStatus matching the Idris2 ABI tags. */
enum PresenceStatus: int
{
    case Online = 0;
    case Away = 1;
    case Dnd = 2;
    case Invisible = 3;
    case Offline = 4;
}

/** RoomType matching the Idris2 ABI tags. */
enum RoomType: int
{
    case Direct = 0;
    case Group = 1;
    case Channel = 2;
    case Broadcast = 3;
}

/** Permission matching the Idris2 ABI tags. */
enum Permission: int
{
    case Read = 0;
    case Write = 1;
    case Admin = 2;
    case Invite = 3;
    case Kick = 4;
    case Ban = 5;
    case Pin = 6;
    case DeleteOthers = 7;
}

/** Event matching the Idris2 ABI tags. */
enum Event: int
{
    case MessageSent = 0;
    case MessageDelivered = 1;
    case MessageRead = 2;
    case UserJoined = 3;
    case UserLeft = 4;
    case Typing = 5;
    case RoomCreated = 6;
}
