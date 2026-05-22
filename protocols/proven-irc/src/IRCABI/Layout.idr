-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- IRCABI.Layout: C-ABI-compatible numeric representations of IRC types.
--
-- Maps every constructor of the core IRC sum types to fixed Bits8 values
-- for C interop.  Each type gets a total encoder, partial decoder, and
-- roundtrip proof guaranteeing encoding/decoding never loses information.
--
-- Tag values here MUST match the C header (generated/abi/irc.h) and the
-- Zig FFI enums (ffi/zig/src/irc.zig) exactly.
--
-- Types covered:
--   Command        (17 constructors, tags 0-16)
--   NumericReply   (11 constructors, tags 0-10)
--   ChannelMode    (10 constructors, tags 0-9)
--   IRCState       (5 constructors, tags 0-4) -- defined here for ABI
--   IRCError       (6 constructors, tags 0-5) -- defined here for ABI

module IRCABI.Layout

import IRC.Types

%default total

---------------------------------------------------------------------------
-- Command (17 constructors, tags 0-16)
---------------------------------------------------------------------------

public export
commandSize : Nat
commandSize = 1

||| Encode Command to its ABI tag value.
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
--
-- Server-side client connection states for the ABI layer.
---------------------------------------------------------------------------

||| IRC client connection lifecycle states.
public export
data IRCState : Type where
  ||| No client connected. Initial state.
  Disconnected  : IRCState
  ||| TCP connected, awaiting NICK + USER registration.
  Connecting    : IRCState
  ||| Client fully registered and active.
  Registered    : IRCState
  ||| Client has joined at least one channel.
  InChannel     : IRCState
  ||| Client sent QUIT or connection dropped.
  Quitting      : IRCState

public export
Eq IRCState where
  Disconnected == Disconnected = True
  Connecting   == Connecting   = True
  Registered   == Registered   = True
  InChannel    == InChannel    = True
  Quitting     == Quitting     = True
  _            == _            = False

public export
Show IRCState where
  show Disconnected = "Disconnected"
  show Connecting   = "Connecting"
  show Registered   = "Registered"
  show InChannel    = "InChannel"
  show Quitting     = "Quitting"

public export
ircStateSize : Nat
ircStateSize = 1

public export
ircStateToTag : IRCState -> Bits8
ircStateToTag Disconnected = 0
ircStateToTag Connecting   = 1
ircStateToTag Registered   = 2
ircStateToTag InChannel    = 3
ircStateToTag Quitting     = 4

public export
tagToIRCState : Bits8 -> Maybe IRCState
tagToIRCState 0 = Just Disconnected
tagToIRCState 1 = Just Connecting
tagToIRCState 2 = Just Registered
tagToIRCState 3 = Just InChannel
tagToIRCState 4 = Just Quitting
tagToIRCState _ = Nothing

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

||| IRC server error categories for the ABI layer.
public export
data IRCError : Type where
  ||| No error (success sentinel).
  IRCErrNone          : IRCError
  ||| Nickname already in use.
  IRCErrNickInUse     : IRCError
  ||| Channel is full (cannot join).
  IRCErrChannelFull   : IRCError
  ||| Invite-only channel (not invited).
  IRCErrInviteOnly    : IRCError
  ||| Banned from channel.
  IRCErrBanned        : IRCError
  ||| Not registered (command requires registration first).
  IRCErrNotRegistered : IRCError

public export
Eq IRCError where
  IRCErrNone          == IRCErrNone          = True
  IRCErrNickInUse     == IRCErrNickInUse     = True
  IRCErrChannelFull   == IRCErrChannelFull   = True
  IRCErrInviteOnly    == IRCErrInviteOnly    = True
  IRCErrBanned        == IRCErrBanned        = True
  IRCErrNotRegistered == IRCErrNotRegistered = True
  _                   == _                   = False

public export
ircErrorSize : Nat
ircErrorSize = 1

public export
ircErrorToTag : IRCError -> Bits8
ircErrorToTag IRCErrNone          = 0
ircErrorToTag IRCErrNickInUse     = 1
ircErrorToTag IRCErrChannelFull   = 2
ircErrorToTag IRCErrInviteOnly    = 3
ircErrorToTag IRCErrBanned        = 4
ircErrorToTag IRCErrNotRegistered = 5

public export
tagToIRCError : Bits8 -> Maybe IRCError
tagToIRCError 0 = Just IRCErrNone
tagToIRCError 1 = Just IRCErrNickInUse
tagToIRCError 2 = Just IRCErrChannelFull
tagToIRCError 3 = Just IRCErrInviteOnly
tagToIRCError 4 = Just IRCErrBanned
tagToIRCError 5 = Just IRCErrNotRegistered
tagToIRCError _ = Nothing

public export
ircErrorRoundtrip : (e : IRCError) -> tagToIRCError (ircErrorToTag e) = Just e
ircErrorRoundtrip IRCErrNone          = Refl
ircErrorRoundtrip IRCErrNickInUse     = Refl
ircErrorRoundtrip IRCErrChannelFull   = Refl
ircErrorRoundtrip IRCErrInviteOnly    = Refl
ircErrorRoundtrip IRCErrBanned        = Refl
ircErrorRoundtrip IRCErrNotRegistered = Refl
