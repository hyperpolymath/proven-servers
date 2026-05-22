// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Chat protocol types for proven-servers.

namespace Proven;

/// <summary>MessageType matching the Idris2 ABI tags (0-8).</summary>
public enum MessageType : byte
{
    Text = 0,
    Image = 1,
    File = 2,
    System = 3,
    Reaction = 4,
    Edit = 5,
    Delete = 6,
    Reply = 7,
    Thread = 8
}

/// <summary>PresenceStatus matching the Idris2 ABI tags (0-4).</summary>
public enum PresenceStatus : byte
{
    Online = 0,
    Away = 1,
    Dnd = 2,
    Invisible = 3,
    Offline = 4
}

/// <summary>RoomType matching the Idris2 ABI tags (0-3).</summary>
public enum RoomType : byte
{
    Direct = 0,
    Group = 1,
    Channel = 2,
    Broadcast = 3
}

/// <summary>Permission matching the Idris2 ABI tags (0-7).</summary>
public enum Permission : byte
{
    Read = 0,
    Write = 1,
    Admin = 2,
    Invite = 3,
    Kick = 4,
    Ban = 5,
    Pin = 6,
    DeleteOthers = 7
}

/// <summary>Event matching the Idris2 ABI tags (0-6).</summary>
public enum Event : byte
{
    MessageSent = 0,
    MessageDelivered = 1,
    MessageRead = 2,
    UserJoined = 3,
    UserLeft = 4,
    Typing = 5,
    RoomCreated = 6
}
