-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- IrcABI.Types: C-ABI-compatible numeric representations of IRC types.
--
-- Maps every constructor of the core IRC sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/irc.zig) exactly.
--
-- Types covered:
--   Command              (17 constructors, tags 0-16)
--   NumericReply          (11 constructors, tags 0-10)
--   ChannelMode           (10 constructors, tags 0-9)
--   IRCState              (5 constructors, tags 0-4)
--   IRCError              (6 constructors, tags 0-5)

module IrcABI.Types

%default total

---------------------------------------------------------------------------
-- Command (17 constructors, tags 0-16)
---------------------------------------------------------------------------

public export
commandSize : Nat
commandSize = 1

||| IRC protocol commands (RFC 2812).
public export
data Command : Type where
  Nick    : Command
  User    : Command
  Join    : Command
  Part    : Command
  Privmsg : Command
  Notice  : Command
  Quit    : Command
  Ping    : Command
  Pong    : Command
  Mode    : Command
  Kick    : Command
  Topic   : Command
  Invite  : Command
  Names   : Command
  List    : Command
  Who     : Command
  Whois   : Command

||| Encode a Command to its ABI tag value.
public export
commandToTag : Command -> Bits8
commandToTag Nick    = 0
commandToTag User    = 1
commandToTag Join    = 2
commandToTag Part    = 3
commandToTag Privmsg = 4
commandToTag Notice  = 5
commandToTag Quit    = 6
commandToTag Ping    = 7
commandToTag Pong    = 8
commandToTag Mode    = 9
commandToTag Kick    = 10
commandToTag Topic   = 11
commandToTag Invite  = 12
commandToTag Names   = 13
commandToTag List    = 14
commandToTag Who     = 15
commandToTag Whois   = 16

||| Decode an ABI tag to a Command.
public export
tagToCommand : Bits8 -> Maybe Command
tagToCommand 0  = Just Nick
tagToCommand 1  = Just User
tagToCommand 2  = Just Join
tagToCommand 3  = Just Part
tagToCommand 4  = Just Privmsg
tagToCommand 5  = Just Notice
tagToCommand 6  = Just Quit
tagToCommand 7  = Just Ping
tagToCommand 8  = Just Pong
tagToCommand 9  = Just Mode
tagToCommand 10 = Just Kick
tagToCommand 11 = Just Topic
tagToCommand 12 = Just Invite
tagToCommand 13 = Just Names
tagToCommand 14 = Just List
tagToCommand 15 = Just Who
tagToCommand 16 = Just Whois
tagToCommand _  = Nothing

||| Roundtrip proof: decoding an encoded Command yields the original.
public export
commandRoundtrip : (c : Command) -> tagToCommand (commandToTag c) = Just c
commandRoundtrip Nick    = Refl
commandRoundtrip User    = Refl
commandRoundtrip Join    = Refl
commandRoundtrip Part    = Refl
commandRoundtrip Privmsg = Refl
commandRoundtrip Notice  = Refl
commandRoundtrip Quit    = Refl
commandRoundtrip Ping    = Refl
commandRoundtrip Pong    = Refl
commandRoundtrip Mode    = Refl
commandRoundtrip Kick    = Refl
commandRoundtrip Topic   = Refl
commandRoundtrip Invite  = Refl
commandRoundtrip Names   = Refl
commandRoundtrip List    = Refl
commandRoundtrip Who     = Refl
commandRoundtrip Whois   = Refl

---------------------------------------------------------------------------
-- NumericReply (11 constructors, tags 0-10)
---------------------------------------------------------------------------

public export
numericReplySize : Nat
numericReplySize = 1

||| Selected numeric reply codes from RFC 2812.
public export
data NumericReply : Type where
  Welcome         : NumericReply
  YourHost        : NumericReply
  Created         : NumericReply
  MyInfo          : NumericReply
  Bounce          : NumericReply
  NickInUse       : NumericReply
  NoSuchNick      : NumericReply
  NoSuchChannel   : NumericReply
  ChannelIsFull   : NumericReply
  InviteOnlyChan  : NumericReply
  BannedFromChan  : NumericReply

||| Encode a NumericReply to its ABI tag value.
public export
numericReplyToTag : NumericReply -> Bits8
numericReplyToTag Welcome        = 0
numericReplyToTag YourHost       = 1
numericReplyToTag Created        = 2
numericReplyToTag MyInfo         = 3
numericReplyToTag Bounce         = 4
numericReplyToTag NickInUse      = 5
numericReplyToTag NoSuchNick     = 6
numericReplyToTag NoSuchChannel  = 7
numericReplyToTag ChannelIsFull  = 8
numericReplyToTag InviteOnlyChan = 9
numericReplyToTag BannedFromChan = 10

||| Decode an ABI tag to a NumericReply.
public export
tagToNumericReply : Bits8 -> Maybe NumericReply
tagToNumericReply 0  = Just Welcome
tagToNumericReply 1  = Just YourHost
tagToNumericReply 2  = Just Created
tagToNumericReply 3  = Just MyInfo
tagToNumericReply 4  = Just Bounce
tagToNumericReply 5  = Just NickInUse
tagToNumericReply 6  = Just NoSuchNick
tagToNumericReply 7  = Just NoSuchChannel
tagToNumericReply 8  = Just ChannelIsFull
tagToNumericReply 9  = Just InviteOnlyChan
tagToNumericReply 10 = Just BannedFromChan
tagToNumericReply _  = Nothing

||| Roundtrip proof: decoding an encoded NumericReply yields the original.
public export
numericReplyRoundtrip : (r : NumericReply) -> tagToNumericReply (numericReplyToTag r) = Just r
numericReplyRoundtrip Welcome        = Refl
numericReplyRoundtrip YourHost       = Refl
numericReplyRoundtrip Created        = Refl
numericReplyRoundtrip MyInfo         = Refl
numericReplyRoundtrip Bounce         = Refl
numericReplyRoundtrip NickInUse      = Refl
numericReplyRoundtrip NoSuchNick     = Refl
numericReplyRoundtrip NoSuchChannel  = Refl
numericReplyRoundtrip ChannelIsFull  = Refl
numericReplyRoundtrip InviteOnlyChan = Refl
numericReplyRoundtrip BannedFromChan = Refl

---------------------------------------------------------------------------
-- ChannelMode (10 constructors, tags 0-9)
---------------------------------------------------------------------------

public export
channelModeSize : Nat
channelModeSize = 1

||| IRC channel modes (RFC 2812 Section 4).
public export
data ChannelMode : Type where
  Op             : ChannelMode
  Voice          : ChannelMode
  Ban            : ChannelMode
  Limit          : ChannelMode
  InviteOnly     : ChannelMode
  Moderated      : ChannelMode
  NoExternalMsgs : ChannelMode
  TopicLock      : ChannelMode
  Secret         : ChannelMode
  Private        : ChannelMode

||| Encode a ChannelMode to its ABI tag value.
public export
channelModeToTag : ChannelMode -> Bits8
channelModeToTag Op             = 0
channelModeToTag Voice          = 1
channelModeToTag Ban            = 2
channelModeToTag Limit          = 3
channelModeToTag InviteOnly     = 4
channelModeToTag Moderated      = 5
channelModeToTag NoExternalMsgs = 6
channelModeToTag TopicLock      = 7
channelModeToTag Secret         = 8
channelModeToTag Private        = 9

||| Decode an ABI tag to a ChannelMode.
public export
tagToChannelMode : Bits8 -> Maybe ChannelMode
tagToChannelMode 0 = Just Op
tagToChannelMode 1 = Just Voice
tagToChannelMode 2 = Just Ban
tagToChannelMode 3 = Just Limit
tagToChannelMode 4 = Just InviteOnly
tagToChannelMode 5 = Just Moderated
tagToChannelMode 6 = Just NoExternalMsgs
tagToChannelMode 7 = Just TopicLock
tagToChannelMode 8 = Just Secret
tagToChannelMode 9 = Just Private
tagToChannelMode _ = Nothing

||| Roundtrip proof: decoding an encoded ChannelMode yields the original.
public export
channelModeRoundtrip : (m : ChannelMode) -> tagToChannelMode (channelModeToTag m) = Just m
channelModeRoundtrip Op             = Refl
channelModeRoundtrip Voice          = Refl
channelModeRoundtrip Ban            = Refl
channelModeRoundtrip Limit          = Refl
channelModeRoundtrip InviteOnly     = Refl
channelModeRoundtrip Moderated      = Refl
channelModeRoundtrip NoExternalMsgs = Refl
channelModeRoundtrip TopicLock      = Refl
channelModeRoundtrip Secret         = Refl
channelModeRoundtrip Private        = Refl

---------------------------------------------------------------------------
-- IRCState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
ircStateSize : Nat
ircStateSize = 1

||| IRC client connection lifecycle states.
public export
data IRCState : Type where
  Disconnected : IRCState
  Connecting   : IRCState
  Registered   : IRCState
  InChannel    : IRCState
  Quitting     : IRCState

||| Encode an IRCState to its ABI tag value.
public export
ircStateToTag : IRCState -> Bits8
ircStateToTag Disconnected = 0
ircStateToTag Connecting   = 1
ircStateToTag Registered   = 2
ircStateToTag InChannel    = 3
ircStateToTag Quitting     = 4

||| Decode an ABI tag to an IRCState.
public export
tagToIRCState : Bits8 -> Maybe IRCState
tagToIRCState 0 = Just Disconnected
tagToIRCState 1 = Just Connecting
tagToIRCState 2 = Just Registered
tagToIRCState 3 = Just InChannel
tagToIRCState 4 = Just Quitting
tagToIRCState _ = Nothing

||| Roundtrip proof: decoding an encoded IRCState yields the original.
public export
ircStateRoundtrip : (s : IRCState) -> tagToIRCState (ircStateToTag s) = Just s
ircStateRoundtrip Disconnected = Refl
ircStateRoundtrip Connecting   = Refl
ircStateRoundtrip Registered   = Refl
ircStateRoundtrip InChannel    = Refl
ircStateRoundtrip Quitting     = Refl

---------------------------------------------------------------------------
-- IRCError (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
ircErrorSize : Nat
ircErrorSize = 1

||| IRC server error categories.
public export
data IRCError : Type where
  IrcErrNone          : IRCError
  IrcErrNickInUse     : IRCError
  IrcErrChannelFull   : IRCError
  IrcErrInviteOnly    : IRCError
  IrcErrBanned        : IRCError
  IrcErrNotRegistered : IRCError

||| Encode an IRCError to its ABI tag value.
public export
ircErrorToTag : IRCError -> Bits8
ircErrorToTag IrcErrNone          = 0
ircErrorToTag IrcErrNickInUse     = 1
ircErrorToTag IrcErrChannelFull   = 2
ircErrorToTag IrcErrInviteOnly    = 3
ircErrorToTag IrcErrBanned        = 4
ircErrorToTag IrcErrNotRegistered = 5

||| Decode an ABI tag to an IRCError.
public export
tagToIRCError : Bits8 -> Maybe IRCError
tagToIRCError 0 = Just IrcErrNone
tagToIRCError 1 = Just IrcErrNickInUse
tagToIRCError 2 = Just IrcErrChannelFull
tagToIRCError 3 = Just IrcErrInviteOnly
tagToIRCError 4 = Just IrcErrBanned
tagToIRCError 5 = Just IrcErrNotRegistered
tagToIRCError _ = Nothing

||| Roundtrip proof: decoding an encoded IRCError yields the original.
public export
ircErrorRoundtrip : (e : IRCError) -> tagToIRCError (ircErrorToTag e) = Just e
ircErrorRoundtrip IrcErrNone          = Refl
ircErrorRoundtrip IrcErrNickInUse     = Refl
ircErrorRoundtrip IrcErrChannelFull   = Refl
ircErrorRoundtrip IrcErrInviteOnly    = Refl
ircErrorRoundtrip IrcErrBanned        = Refl
ircErrorRoundtrip IrcErrNotRegistered = Refl
