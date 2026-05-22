<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IRC protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** Command matching the Idris2 ABI tags. */
enum Command: int
{
    case Nick = 0;
    case User = 1;
    case Join = 2;
    case Part = 3;
    case Privmsg = 4;
    case Notice = 5;
    case Quit = 6;
    case Ping = 7;
    case Pong = 8;
    case Mode = 9;
    case Kick = 10;
    case Topic = 11;
    case Invite = 12;
    case Names = 13;
    case List = 14;
    case Who = 15;
    case Whois = 16;
}

/** NumericReply matching the Idris2 ABI tags. */
enum NumericReply: int
{
    case Welcome = 0;
    case YourHost = 1;
    case Created = 2;
    case MyInfo = 3;
    case Bounce = 4;
    case NumericReply_NickInUse = 5;
    case NoSuchNick = 6;
    case NoSuchChannel = 7;
    case ChannelIsFull = 8;
    case InviteOnlyChan = 9;
    case BannedFromChan = 10;
}

/** ChannelMode matching the Idris2 ABI tags. */
enum ChannelMode: int
{
    case Op = 0;
    case Voice = 1;
    case Ban = 2;
    case Limit = 3;
    case ChannelMode_InviteOnly = 4;
    case Moderated = 5;
    case NoExternalMsgs = 6;
    case TopicLock = 7;
    case Secret = 8;
    case Private = 9;
}

/** State matching the Idris2 ABI tags. */
enum State: int
{
    case Disconnected = 0;
    case Connecting = 1;
    case Registered = 2;
    case InChannel = 3;
    case Quitting = 4;
}

/** IrcError matching the Idris2 ABI tags. */
enum IrcError: int
{
    case None = 0;
    case IrcError_NickInUse = 1;
    case ChannelFull = 2;
    case IrcError_InviteOnly = 3;
    case Banned = 4;
    case NotRegistered = 5;
}
