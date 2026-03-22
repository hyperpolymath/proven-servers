// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// XMPP protocol types for proven-servers.

namespace Proven;

/// <summary>StanzaType matching the Idris2 ABI tags (0-2).</summary>
public enum StanzaType : byte
{
    Message = 0,
    Presence = 1,
    Iq = 2
}

/// <summary>MessageType matching the Idris2 ABI tags (0-4).</summary>
public enum MessageType : byte
{
    Chat = 0,
    Error = 1,
    Groupchat = 2,
    Headline = 3,
    Normal = 4
}

/// <summary>PresenceType matching the Idris2 ABI tags (0-4).</summary>
public enum PresenceType : byte
{
    Available = 0,
    Away = 1,
    Dnd = 2,
    Xa = 3,
    Unavailable = 4
}

/// <summary>IqType matching the Idris2 ABI tags (0-3).</summary>
public enum IqType : byte
{
    Get = 0,
    Set = 1,
    Result = 2,
    Error = 3
}

/// <summary>StreamError matching the Idris2 ABI tags (0-8).</summary>
public enum StreamError : byte
{
    BadFormat = 0,
    Conflict = 1,
    ConnectionTimeout = 2,
    HostGone = 3,
    HostUnknown = 4,
    NotAuthorized = 5,
    PolicyViolation = 6,
    ResourceConstraint = 7,
    SystemShutdown = 8
}
