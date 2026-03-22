// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IRC protocol types for proven-servers.

/// Command matching the Idris2 ABI tags.
public enum Command: UInt8, CaseIterable, Sendable {
    case nick = 0
    case user = 1
    case join = 2
    case part = 3
    case privmsg = 4
    case notice = 5
    case quit = 6
    case ping = 7
    case pong = 8
    case mode = 9
    case kick = 10
    case topic = 11
    case invite = 12
    case names = 13
    case list = 14
    case who = 15
    case whois = 16
}

/// NumericReply matching the Idris2 ABI tags.
public enum NumericReply: UInt8, CaseIterable, Sendable {
    case welcome = 0
    case yourHost = 1
    case created = 2
    case myInfo = 3
    case bounce = 4
    case numericReply_NickInUse = 5
    case noSuchNick = 6
    case noSuchChannel = 7
    case channelIsFull = 8
    case inviteOnlyChan = 9
    case bannedFromChan = 10
}

/// ChannelMode matching the Idris2 ABI tags.
public enum ChannelMode: UInt8, CaseIterable, Sendable {
    case op = 0
    case voice = 1
    case ban = 2
    case limit = 3
    case channelMode_InviteOnly = 4
    case moderated = 5
    case noExternalMsgs = 6
    case topicLock = 7
    case secret = 8
    case `private` = 9
}

/// State matching the Idris2 ABI tags.
public enum State: UInt8, CaseIterable, Sendable {
    case disconnected = 0
    case connecting = 1
    case registered = 2
    case inChannel = 3
    case quitting = 4
}

/// IrcError matching the Idris2 ABI tags.
public enum IrcError: UInt8, CaseIterable, Sendable {
    case none = 0
    case ircError_NickInUse = 1
    case channelFull = 2
    case ircError_InviteOnly = 3
    case banned = 4
    case notRegistered = 5
}
