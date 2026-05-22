<?php
// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// XMPP protocol types for proven-servers.

declare(strict_types=1);

namespace ProvenServers;

/** StanzaType matching the Idris2 ABI tags. */
enum StanzaType: int
{
    case Message = 0;
    case Presence = 1;
    case Iq = 2;
}

/** MessageType matching the Idris2 ABI tags. */
enum MessageType: int
{
    case Chat = 0;
    case MessageType_Error = 1;
    case Groupchat = 2;
    case Headline = 3;
    case Normal = 4;
}

/** PresenceType matching the Idris2 ABI tags. */
enum PresenceType: int
{
    case Available = 0;
    case Away = 1;
    case Dnd = 2;
    case Xa = 3;
    case Unavailable = 4;
}

/** IqType matching the Idris2 ABI tags. */
enum IqType: int
{
    case Get = 0;
    case Set = 1;
    case Result = 2;
    case IqType_Error = 3;
}

/** StreamError matching the Idris2 ABI tags. */
enum StreamError: int
{
    case BadFormat = 0;
    case Conflict = 1;
    case ConnectionTimeout = 2;
    case HostGone = 3;
    case HostUnknown = 4;
    case NotAuthorized = 5;
    case PolicyViolation = 6;
    case ResourceConstraint = 7;
    case SystemShutdown = 8;
}
