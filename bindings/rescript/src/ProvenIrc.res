// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IRC protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module IrcABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard IRC port (RFC 2812).
let ircPort = 6667

/// Standard IRC over TLS port.
let ircsPort = 6697

// ===========================================================================
// Command (tags 0-16)
// ===========================================================================

/// Standard IRC port (RFC 2812).
type command =
  | @as(0) Nick
  | @as(1) User
  | @as(2) Join
  | @as(3) Part
  | @as(4) Privmsg
  | @as(5) Notice
  | @as(6) Quit
  | @as(7) Ping
  | @as(8) Pong
  | @as(9) Mode
  | @as(10) Kick
  | @as(11) Topic
  | @as(12) Invite
  | @as(13) Names
  | @as(14) List
  | @as(15) Who
  | @as(16) Whois

/// Decode from the C-ABI tag value.
let commandFromTag = (tag: int): option<command> =>
  switch tag {
  | 0 => Some(Nick)
  | 1 => Some(User)
  | 2 => Some(Join)
  | 3 => Some(Part)
  | 4 => Some(Privmsg)
  | 5 => Some(Notice)
  | 6 => Some(Quit)
  | 7 => Some(Ping)
  | 8 => Some(Pong)
  | 9 => Some(Mode)
  | 10 => Some(Kick)
  | 11 => Some(Topic)
  | 12 => Some(Invite)
  | 13 => Some(Names)
  | 14 => Some(List)
  | 15 => Some(Who)
  | 16 => Some(Whois)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let commandToTag = (v: command): int =>
  switch v {
  | Nick => 0
  | User => 1
  | Join => 2
  | Part => 3
  | Privmsg => 4
  | Notice => 5
  | Quit => 6
  | Ping => 7
  | Pong => 8
  | Mode => 9
  | Kick => 10
  | Topic => 11
  | Invite => 12
  | Names => 13
  | List => 14
  | Who => 15
  | Whois => 16
  }

/// Whether this command requires channel operator privileges.
let commandRequiresOp = (v: command): bool =>
  switch v {
  | Kick | Mode => true
  | _ => false
  }

/// Whether this command requires registered status.
let commandRequiresRegistration = (v: command): bool =>
  switch v {
  | Nick | User | Ping | Pong | Quit => false
  | _ => true
  }

// ===========================================================================
// NumericReply (tags 0-10)
// ===========================================================================

/// Decode from an ABI tag value.
type numericReply =
  | @as(0) Welcome
  | @as(1) YourHost
  | @as(2) Created
  | @as(3) MyInfo
  | @as(4) Bounce
  | @as(5) NickInUse
  | @as(6) NoSuchNick
  | @as(7) NoSuchChannel
  | @as(8) ChannelIsFull
  | @as(9) InviteOnlyChan
  | @as(10) BannedFromChan

/// Decode from the C-ABI tag value.
let numericReplyFromTag = (tag: int): option<numericReply> =>
  switch tag {
  | 0 => Some(Welcome)
  | 1 => Some(YourHost)
  | 2 => Some(Created)
  | 3 => Some(MyInfo)
  | 4 => Some(Bounce)
  | 5 => Some(NickInUse)
  | 6 => Some(NoSuchNick)
  | 7 => Some(NoSuchChannel)
  | 8 => Some(ChannelIsFull)
  | 9 => Some(InviteOnlyChan)
  | 10 => Some(BannedFromChan)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let numericReplyToTag = (v: numericReply): int =>
  switch v {
  | Welcome => 0
  | YourHost => 1
  | Created => 2
  | MyInfo => 3
  | Bounce => 4
  | NickInUse => 5
  | NoSuchNick => 6
  | NoSuchChannel => 7
  | ChannelIsFull => 8
  | InviteOnlyChan => 9
  | BannedFromChan => 10
  }

/// Whether this reply indicates an error.
let numericReplyIsError = (v: numericReply): bool =>
  switch v {
  | NickInUse | NoSuchNick | NoSuchChannel | ChannelIsFull | InviteOnlyChan | BannedFromChan => true
  | _ => false
  }

// ===========================================================================
// ChannelMode (tags 0-9)
// ===========================================================================

/// Decode from an ABI tag value.
type channelMode =
  | @as(0) Op
  | @as(1) Voice
  | @as(2) Ban
  | @as(3) Limit
  | @as(4) InviteOnly
  | @as(5) Moderated
  | @as(6) NoExternalMsgs
  | @as(7) TopicLock
  | @as(8) Secret
  | @as(9) Private

/// Decode from the C-ABI tag value.
let channelModeFromTag = (tag: int): option<channelMode> =>
  switch tag {
  | 0 => Some(Op)
  | 1 => Some(Voice)
  | 2 => Some(Ban)
  | 3 => Some(Limit)
  | 4 => Some(InviteOnly)
  | 5 => Some(Moderated)
  | 6 => Some(NoExternalMsgs)
  | 7 => Some(TopicLock)
  | 8 => Some(Secret)
  | 9 => Some(Private)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let channelModeToTag = (v: channelMode): int =>
  switch v {
  | Op => 0
  | Voice => 1
  | Ban => 2
  | Limit => 3
  | InviteOnly => 4
  | Moderated => 5
  | NoExternalMsgs => 6
  | TopicLock => 7
  | Secret => 8
  | Private => 9
  }

/// Whether this mode requires a parameter when set.
let channelModeRequiresParameter = (v: channelMode): bool =>
  switch v {
  | Op | Voice | Ban | Limit => true
  | _ => false
  }

// ===========================================================================
// State (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type state =
  | @as(0) Disconnected
  | @as(1) Connecting
  | @as(2) Registered
  | @as(3) InChannel
  | @as(4) Quitting

/// Decode from the C-ABI tag value.
let stateFromTag = (tag: int): option<state> =>
  switch tag {
  | 0 => Some(Disconnected)
  | 1 => Some(Connecting)
  | 2 => Some(Registered)
  | 3 => Some(InChannel)
  | 4 => Some(Quitting)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let stateToTag = (v: state): int =>
  switch v {
  | Disconnected => 0
  | Connecting => 1
  | Registered => 2
  | InChannel => 3
  | Quitting => 4
  }

/// Validate whether a state transition is allowed.
let stateCanTransitionTo = (from: state, to: state): bool =>
  switch (from, to) {
  | _ => false
  }

// ===========================================================================
// IrcError (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type ircError =
  | @as(0) None
  | @as(1) NickInUse
  | @as(2) ChannelFull
  | @as(3) InviteOnly
  | @as(4) Banned
  | @as(5) NotRegistered

/// Decode from the C-ABI tag value.
let ircErrorFromTag = (tag: int): option<ircError> =>
  switch tag {
  | 0 => Some(None)
  | 1 => Some(NickInUse)
  | 2 => Some(ChannelFull)
  | 3 => Some(InviteOnly)
  | 4 => Some(Banned)
  | 5 => Some(NotRegistered)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let ircErrorToTag = (v: ircError): int =>
  switch v {
  | None => 0
  | NickInUse => 1
  | ChannelFull => 2
  | InviteOnly => 3
  | Banned => 4
  | NotRegistered => 5
  }

/// Whether this error code indicates success.
let ircErrorIsSuccess = (v: ircError): bool =>
  switch v {
  | None => true
  | _ => false
  }

/// Whether this error relates to channel access.
let ircErrorIsChannelError = (v: ircError): bool =>
  switch v {
  | ChannelFull | InviteOnly | Banned => true
  | _ => false
  }

