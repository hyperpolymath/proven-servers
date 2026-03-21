//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// IRC protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `IrcABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// IRC Constants
// ===========================================================================

/// Irc Port constant.
pub const irc_port = 6667

/// Ircs Port constant.
pub const ircs_port = 6697

// ===========================================================================
// Command
// ===========================================================================

/// IRC protocol commands (RFC 2812).
/// 
/// Matches `Command` in `IrcABI.Types`.
pub type Command {
  /// NICK — set or change nickname (tag 0).
  Nick
  /// USER — specify username and realname (tag 1).
  User
  /// JOIN — join a channel (tag 2).
  Join
  /// PART — leave a channel (tag 3).
  Part
  /// PRIVMSG — send a message to a user or channel (tag 4).
  Privmsg
  /// NOTICE — send a notice (no auto-reply) (tag 5).
  Notice
  /// QUIT — disconnect from server (tag 6).
  Quit
  /// PING — test connection liveness (tag 7).
  Ping
  /// PONG — reply to PING (tag 8).
  Pong
  /// MODE — set user or channel modes (tag 9).
  Mode
  /// KICK — remove a user from a channel (tag 10).
  Kick
  /// TOPIC — set or view channel topic (tag 11).
  Topic
  /// INVITE — invite a user to a channel (tag 12).
  Invite
  /// NAMES — list users in a channel (tag 13).
  Names
  /// LIST — list channels (tag 14).
  List
  /// WHO — query user information (tag 15).
  Who
  /// WHOIS — query detailed user information (tag 16).
  Whois
}

/// Convert a `Command` to its C-ABI tag value.
pub fn command_to_int(value: Command) -> Int {
  case value {
    Nick -> 0
    User -> 1
    Join -> 2
    Part -> 3
    Privmsg -> 4
    Notice -> 5
    Quit -> 6
    Ping -> 7
    Pong -> 8
    Mode -> 9
    Kick -> 10
    Topic -> 11
    Invite -> 12
    Names -> 13
    List -> 14
    Who -> 15
    Whois -> 16
  }
}

/// Decode from a C-ABI tag value.
pub fn command_from_int(tag: Int) -> Result(Command, Nil) {
  case tag {
    0 -> Ok(Nick)
    1 -> Ok(User)
    2 -> Ok(Join)
    3 -> Ok(Part)
    4 -> Ok(Privmsg)
    5 -> Ok(Notice)
    6 -> Ok(Quit)
    7 -> Ok(Ping)
    8 -> Ok(Pong)
    9 -> Ok(Mode)
    10 -> Ok(Kick)
    11 -> Ok(Topic)
    12 -> Ok(Invite)
    13 -> Ok(Names)
    14 -> Ok(List)
    15 -> Ok(Who)
    16 -> Ok(Whois)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NumericReply
// ===========================================================================

/// Selected IRC numeric reply codes (RFC 2812).
/// 
/// Matches `NumericReply` in `IrcABI.Types`.
pub type NumericReply {
  /// RPLWELCOME (001) — welcome to IRC (tag 0).
  Welcome
  /// RPLYOURHOST (002) — your host info (tag 1).
  YourHost
  /// RPLCREATED (003) — server creation date (tag 2).
  Created
  /// RPLMYINFO (004) — server info (tag 3).
  MyInfo
  /// RPLBOUNCE (005) — server redirect or capabilities (tag 4).
  Bounce
  /// ERRNICKNAMEINUSE (433) — nick already taken (tag 5).
  NumericReplyNickInUse
  /// ERRNOSUCHNICK (401) — no such nick (tag 6).
  NoSuchNick
  /// ERRNOSUCHCHANNEL (403) — no such channel (tag 7).
  NoSuchChannel
  /// ERRCHANNELISFULL (471) — channel is full (tag 8).
  ChannelIsFull
  /// ERRINVITEONLYCHAN (473) — invite-only channel (tag 9).
  InviteOnlyChan
  /// ERRBANNEDFROMCHAN (474) — banned from channel (tag 10).
  BannedFromChan
}

/// Convert a `NumericReply` to its C-ABI tag value.
pub fn numeric_reply_to_int(value: NumericReply) -> Int {
  case value {
    Welcome -> 0
    YourHost -> 1
    Created -> 2
    MyInfo -> 3
    Bounce -> 4
    NumericReplyNickInUse -> 5
    NoSuchNick -> 6
    NoSuchChannel -> 7
    ChannelIsFull -> 8
    InviteOnlyChan -> 9
    BannedFromChan -> 10
  }
}

/// Decode from a C-ABI tag value.
pub fn numeric_reply_from_int(tag: Int) -> Result(NumericReply, Nil) {
  case tag {
    0 -> Ok(Welcome)
    1 -> Ok(YourHost)
    2 -> Ok(Created)
    3 -> Ok(MyInfo)
    4 -> Ok(Bounce)
    5 -> Ok(NumericReplyNickInUse)
    6 -> Ok(NoSuchNick)
    7 -> Ok(NoSuchChannel)
    8 -> Ok(ChannelIsFull)
    9 -> Ok(InviteOnlyChan)
    10 -> Ok(BannedFromChan)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ChannelMode
// ===========================================================================

/// IRC channel modes (RFC 2812 Section 4).
/// 
/// Matches `ChannelMode` in `IrcABI.Types`.
pub type ChannelMode {
  /// +o — channel operator (tag 0).
  Op
  /// +v — voice (tag 1).
  Voice
  /// +b — ban mask (tag 2).
  Ban
  /// +l — user limit (tag 3).
  Limit
  /// +i — invite only (tag 4).
  ChannelModeInviteOnly
  /// +m — moderated (tag 5).
  Moderated
  /// +n — no external messages (tag 6).
  NoExternalMsgs
  /// +t — topic lock (tag 7).
  TopicLock
  /// +s — secret channel (tag 8).
  Secret
  /// +p — private channel (tag 9).
  Private
}

/// Convert a `ChannelMode` to its C-ABI tag value.
pub fn channel_mode_to_int(value: ChannelMode) -> Int {
  case value {
    Op -> 0
    Voice -> 1
    Ban -> 2
    Limit -> 3
    ChannelModeInviteOnly -> 4
    Moderated -> 5
    NoExternalMsgs -> 6
    TopicLock -> 7
    Secret -> 8
    Private -> 9
  }
}

/// Decode from a C-ABI tag value.
pub fn channel_mode_from_int(tag: Int) -> Result(ChannelMode, Nil) {
  case tag {
    0 -> Ok(Op)
    1 -> Ok(Voice)
    2 -> Ok(Ban)
    3 -> Ok(Limit)
    4 -> Ok(ChannelModeInviteOnly)
    5 -> Ok(Moderated)
    6 -> Ok(NoExternalMsgs)
    7 -> Ok(TopicLock)
    8 -> Ok(Secret)
    9 -> Ok(Private)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// State
// ===========================================================================

/// IRC client connection lifecycle states.
/// 
/// Matches `IRCState` in `IrcABI.Types`.
pub type State {
  /// Not connected (tag 0).
  Disconnected
  /// TCP connection in progress (tag 1).
  Connecting
  /// NICK/USER sent and accepted (tag 2).
  Registered
  /// Joined at least one channel (tag 3).
  InChannel
  /// QUIT sent, awaiting disconnect (tag 4).
  Quitting
}

/// Convert a `State` to its C-ABI tag value.
pub fn state_to_int(value: State) -> Int {
  case value {
    Disconnected -> 0
    Connecting -> 1
    Registered -> 2
    InChannel -> 3
    Quitting -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn state_from_int(tag: Int) -> Result(State, Nil) {
  case tag {
    0 -> Ok(Disconnected)
    1 -> Ok(Connecting)
    2 -> Ok(Registered)
    3 -> Ok(InChannel)
    4 -> Ok(Quitting)
    _ -> Error(Nil)
  }
}

/// Validate whether a state transition is allowed.
pub fn state_can_transition_to(from: State, to: State) -> Bool {
  case from, to {
    Disconnected, Connecting -> True
    Connecting, Registered -> True
    Registered, InChannel -> True
    InChannel, Registered -> True
    Registered, Quitting -> True
    InChannel, Quitting -> True
    Quitting, Disconnected -> True
    _, _ -> False
  }
}

// ===========================================================================
// IrcError
// ===========================================================================

/// IRC server error categories.
/// 
/// Matches `IRCError` in `IrcABI.Types`.
pub type IrcError {
  /// No error (tag 0).
  IrcErrorNone
  /// Nickname already in use (tag 1).
  IrcErrorNickInUse
  /// Channel is full (tag 2).
  ChannelFull
  /// Channel is invite-only (tag 3).
  IrcErrorInviteOnly
  /// Banned from channel (tag 4).
  Banned
  /// Not registered (tag 5).
  NotRegistered
}

/// Convert a `IrcError` to its C-ABI tag value.
pub fn irc_error_to_int(value: IrcError) -> Int {
  case value {
    IrcErrorNone -> 0
    IrcErrorNickInUse -> 1
    ChannelFull -> 2
    IrcErrorInviteOnly -> 3
    Banned -> 4
    NotRegistered -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn irc_error_from_int(tag: Int) -> Result(IrcError, Nil) {
  case tag {
    0 -> Ok(IrcErrorNone)
    1 -> Ok(IrcErrorNickInUse)
    2 -> Ok(ChannelFull)
    3 -> Ok(IrcErrorInviteOnly)
    4 -> Ok(Banned)
    5 -> Ok(NotRegistered)
    _ -> Error(Nil)
  }
}

