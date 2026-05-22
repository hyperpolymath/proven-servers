// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IRC protocol types for proven-servers.

namespace Proven;

/// <summary>Command matching the Idris2 ABI tags (0-16).</summary>
public enum Command : byte
{
    Nick = 0,
    User = 1,
    Join = 2,
    Part = 3,
    Privmsg = 4,
    Notice = 5,
    Quit = 6,
    Ping = 7,
    Pong = 8,
    Mode = 9,
    Kick = 10,
    Topic = 11,
    Invite = 12,
    Names = 13,
    List = 14,
    Who = 15,
    Whois = 16
}

/// <summary>NumericReply matching the Idris2 ABI tags (0-10).</summary>
public enum NumericReply : byte
{
    Welcome = 0,
    YourHost = 1,
    Created = 2,
    MyInfo = 3,
    Bounce = 4,
    NickInUse = 5,
    NoSuchNick = 6,
    NoSuchChannel = 7,
    ChannelIsFull = 8,
    InviteOnlyChan = 9,
    BannedFromChan = 10
}

/// <summary>ChannelMode matching the Idris2 ABI tags (0-9).</summary>
public enum ChannelMode : byte
{
    Op = 0,
    Voice = 1,
    Ban = 2,
    Limit = 3,
    InviteOnly = 4,
    Moderated = 5,
    NoExternalMsgs = 6,
    TopicLock = 7,
    Secret = 8,
    Private = 9
}

/// <summary>State matching the Idris2 ABI tags (0-4).</summary>
public enum State : byte
{
    Disconnected = 0,
    Connecting = 1,
    Registered = 2,
    InChannel = 3,
    Quitting = 4
}

/// <summary>IrcError matching the Idris2 ABI tags (0-5).</summary>
public enum IrcError : byte
{
    None = 0,
    NickInUse = 1,
    ChannelFull = 2,
    InviteOnly = 3,
    Banned = 4,
    NotRegistered = 5
}
