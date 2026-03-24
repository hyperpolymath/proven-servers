-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | IRC protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Irc
  (
    ircPort
  , ircsPort
  , Command(..)
  , commandToTag
  , commandFromTag
  , requiresOp
  , requiresRegistration
  , name
  , NumericReply(..)
  , numericReplyToTag
  , numericReplyFromTag
  , isError
  , ChannelMode(..)
  , channelModeToTag
  , channelModeFromTag
  , requiresParameter
  , State(..)
  , stateToTag
  , stateFromTag
  , stateCanTransitionTo
  , IrcError(..)
  , ircErrorToTag
  , ircErrorFromTag
  , isSuccess
  , isChannelError
  ) where

import Data.Word (Word16, Word8)

-- | Standard IRC port (RFC 2812).
ircPort :: Word16
ircPort = 6667

-- | Standard IRC over TLS port.
ircsPort :: Word16
ircsPort = 6697

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------

-- | Standard IRC port (RFC 2812).
--
-- Tags 0-16 (17 constructors).
data Command
  = Nick  -- ^ NICK — set or change nickname (tag 0).
  | User  -- ^ USER — specify username and realname (tag 1).
  | Join  -- ^ JOIN — join a channel (tag 2).
  | Part  -- ^ PART — leave a channel (tag 3).
  | Privmsg  -- ^ PRIVMSG — send a message to a user or channel (tag 4).
  | Notice  -- ^ NOTICE — send a notice (no auto-reply) (tag 5).
  | Quit  -- ^ QUIT — disconnect from server (tag 6).
  | Ping  -- ^ PING — test connection liveness (tag 7).
  | Pong  -- ^ PONG — reply to PING (tag 8).
  | Mode  -- ^ MODE — set user or channel modes (tag 9).
  | Kick  -- ^ KICK — remove a user from a channel (tag 10).
  | Topic  -- ^ TOPIC — set or view channel topic (tag 11).
  | Invite  -- ^ INVITE — invite a user to a channel (tag 12).
  | Names  -- ^ NAMES — list users in a channel (tag 13).
  | List  -- ^ LIST — list channels (tag 14).
  | Who  -- ^ WHO — query user information (tag 15).
  | Whois  -- ^ WHOIS — query detailed user information (tag 16).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Command' to its ABI tag value.
commandToTag :: Command -> Word8
commandToTag = fromIntegral . fromEnum

-- | Decode a 'Command' from its ABI tag value.
commandFromTag :: Word8 -> Maybe Command
commandFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Command)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this command requires channel operator privileges.
requiresOp :: Command -> Bool
requiresOp Kick = True
requiresOp Mode = True
requiresOp _ = False

-- | Whether this command requires registered status.
requiresRegistration :: Command -> Bool
requiresRegistration Nick = False
requiresRegistration User = False
requiresRegistration Ping = False
requiresRegistration Pong = False
requiresRegistration Quit = False
requiresRegistration _ = True

-- | The IRC command name string.
name :: Command -> String
name Nick = "NICK"
name User = "USER"
name Join = "JOIN"
name Part = "PART"
name Privmsg = "PRIVMSG"
name Notice = "NOTICE"
name Quit = "QUIT"
name Ping = "PING"
name Pong = "PONG"
name Mode = "MODE"
name Kick = "KICK"
name Topic = "TOPIC"
name Invite = "INVITE"
name Names = "NAMES"
name List = "LIST"
name Who = "WHO"
name Whois = "WHOIS"

-- ---------------------------------------------------------------------------
-- NumericReply
-- ---------------------------------------------------------------------------

-- | Selected IRC numeric reply codes (RFC 2812).
--
-- Tags 0-10 (11 constructors).
data NumericReply
  = Welcome  -- ^ RPL_WELCOME (001) — welcome to IRC (tag 0).
  | YourHost  -- ^ RPL_YOURHOST (002) — your host info (tag 1).
  | Created  -- ^ RPL_CREATED (003) — server creation date (tag 2).
  | MyInfo  -- ^ RPL_MYINFO (004) — server info (tag 3).
  | Bounce  -- ^ RPL_BOUNCE (005) — server redirect or capabilities (tag 4).
  | NickInUse  -- ^ ERR_NICKNAMEINUSE (433) — nick already taken (tag 5).
  | NoSuchNick  -- ^ ERR_NOSUCHNICK (401) — no such nick (tag 6).
  | NoSuchChannel  -- ^ ERR_NOSUCHCHANNEL (403) — no such channel (tag 7).
  | ChannelIsFull  -- ^ ERR_CHANNELISFULL (471) — channel is full (tag 8).
  | InviteOnlyChan  -- ^ ERR_INVITEONLYCHAN (473) — invite-only channel (tag 9).
  | BannedFromChan  -- ^ ERR_BANNEDFROMCHAN (474) — banned from channel (tag 10).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NumericReply' to its ABI tag value.
numericReplyToTag :: NumericReply -> Word8
numericReplyToTag = fromIntegral . fromEnum

-- | Decode a 'NumericReply' from its ABI tag value.
numericReplyFromTag :: Word8 -> Maybe NumericReply
numericReplyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NumericReply)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this reply indicates an error.
isError :: NumericReply -> Bool
isError NickInUse = True
isError NoSuchNick = True
isError NoSuchChannel = True
isError ChannelIsFull = True
isError InviteOnlyChan = True
isError BannedFromChan = True
isError _ = False

-- ---------------------------------------------------------------------------
-- ChannelMode
-- ---------------------------------------------------------------------------

-- | IRC channel modes (RFC 2812 Section 4).
--
-- Tags 0-9 (10 constructors).
data ChannelMode
  = Op  -- ^ +o — channel operator (tag 0).
  | Voice  -- ^ +v — voice (tag 1).
  | Ban  -- ^ +b — ban mask (tag 2).
  | Limit  -- ^ +l — user limit (tag 3).
  | InviteOnly  -- ^ +i — invite only (tag 4).
  | Moderated  -- ^ +m — moderated (tag 5).
  | NoExternalMsgs  -- ^ +n — no external messages (tag 6).
  | TopicLock  -- ^ +t — topic lock (tag 7).
  | Secret  -- ^ +s — secret channel (tag 8).
  | Private  -- ^ +p — private channel (tag 9).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ChannelMode' to its ABI tag value.
channelModeToTag :: ChannelMode -> Word8
channelModeToTag = fromIntegral . fromEnum

-- | Decode a 'ChannelMode' from its ABI tag value.
channelModeFromTag :: Word8 -> Maybe ChannelMode
channelModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ChannelMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this mode requires a parameter when set.
requiresParameter :: ChannelMode -> Bool
requiresParameter Op = True
requiresParameter Voice = True
requiresParameter Ban = True
requiresParameter Limit = True
requiresParameter _ = False

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------

-- | IRC client connection lifecycle states.
--
-- Tags 0-4 (5 constructors).
data State
  = Disconnected  -- ^ Not connected (tag 0).
  | Connecting  -- ^ TCP connection in progress (tag 1).
  | Registered  -- ^ NICK/USER sent and accepted (tag 2).
  | InChannel  -- ^ Joined at least one channel (tag 3).
  | Quitting  -- ^ QUIT sent, awaiting disconnect (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'State' to its ABI tag value.
stateToTag :: State -> Word8
stateToTag = fromIntegral . fromEnum

-- | Decode a 'State' from its ABI tag value.
stateFromTag :: Word8 -> Maybe State
stateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: State)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Validate whether a state transition is allowed.
stateCanTransitionTo :: State -> State -> Bool
stateCanTransitionTo Disconnected Connecting = True
stateCanTransitionTo Connecting Registered = True
stateCanTransitionTo Registered InChannel = True
stateCanTransitionTo InChannel Registered = True
stateCanTransitionTo Registered Quitting = True
stateCanTransitionTo InChannel Quitting = True
stateCanTransitionTo Quitting Disconnected = True
stateCanTransitionTo _ _ = False

-- ---------------------------------------------------------------------------
-- IrcError
-- ---------------------------------------------------------------------------

-- | IRC server error categories.
--
-- Tags 0-5 (6 constructors).
data IrcError
  = None  -- ^ No error (tag 0).
  | NickInUse  -- ^ Nickname already in use (tag 1).
  | ChannelFull  -- ^ Channel is full (tag 2).
  | InviteOnly  -- ^ Channel is invite-only (tag 3).
  | Banned  -- ^ Banned from channel (tag 4).
  | NotRegistered  -- ^ Not registered (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'IrcError' to its ABI tag value.
ircErrorToTag :: IrcError -> Word8
ircErrorToTag = fromIntegral . fromEnum

-- | Decode a 'IrcError' from its ABI tag value.
ircErrorFromTag :: Word8 -> Maybe IrcError
ircErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: IrcError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this error code indicates success.
isSuccess :: IrcError -> Bool
isSuccess None = True
isSuccess _ = False

-- | Whether this error relates to channel access.
isChannelError :: IrcError -> Bool
isChannelError ChannelFull = True
isChannelError InviteOnly = True
isChannelError Banned = True
isChannelError _ = False
