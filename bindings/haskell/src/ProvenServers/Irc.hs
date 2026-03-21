-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | IRC protocol types for proven-servers.
--
-- IRC (Internet Relay Chat) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Irc
  ( -- * ADT types matching Idris2 ABI
      Command(..)
    , NumericReply(..)
    , ChannelMode(..)
    , State(..)
    , IrcError(..)
    , commandToTag
    , commandFromTag
    , numericReplyToTag
    , numericReplyFromTag
    , channelModeToTag
    , channelModeFromTag
    , stateToTag
    , stateFromTag
    , ircErrorToTag
    , ircErrorFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------

-- | Command type matching the Idris2 ABI.
--
-- Tags 0-16 (17 constructors).
data Command
  = Nick  -- ^ Tag 0.
  | User  -- ^ Tag 1.
  | Join  -- ^ Tag 2.
  | Part  -- ^ Tag 3.
  | Privmsg  -- ^ Tag 4.
  | Notice  -- ^ Tag 5.
  | Quit  -- ^ Tag 6.
  | Ping  -- ^ Tag 7.
  | Pong  -- ^ Tag 8.
  | Mode  -- ^ Tag 9.
  | Kick  -- ^ Tag 10.
  | Topic  -- ^ Tag 11.
  | Invite  -- ^ Tag 12.
  | Names  -- ^ Tag 13.
  | List  -- ^ Tag 14.
  | Who  -- ^ Tag 15.
  | Whois  -- ^ Tag 16.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Command' to its ABI tag value.
commandToTag :: Command -> Word8
commandToTag = fromIntegral . fromEnum

-- | Decode a 'Command' from its ABI tag value.
commandFromTag :: Word8 -> Maybe Command
commandFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Command)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- NumericReply
-- ---------------------------------------------------------------------------

-- | NumericReply type matching the Idris2 ABI.
--
-- Tags 0-10 (11 constructors).
data NumericReply
  = Welcome  -- ^ Tag 0.
  | YourHost  -- ^ Tag 1.
  | Created  -- ^ Tag 2.
  | MyInfo  -- ^ Tag 3.
  | Bounce  -- ^ Tag 4.
  | NumericReply_NickInUse  -- ^ Tag 5.
  | NoSuchNick  -- ^ Tag 6.
  | NoSuchChannel  -- ^ Tag 7.
  | ChannelIsFull  -- ^ Tag 8.
  | InviteOnlyChan  -- ^ Tag 9.
  | BannedFromChan  -- ^ Tag 10.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'NumericReply' to its ABI tag value.
numericReplyToTag :: NumericReply -> Word8
numericReplyToTag = fromIntegral . fromEnum

-- | Decode a 'NumericReply' from its ABI tag value.
numericReplyFromTag :: Word8 -> Maybe NumericReply
numericReplyFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: NumericReply)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ChannelMode
-- ---------------------------------------------------------------------------

-- | ChannelMode type matching the Idris2 ABI.
--
-- Tags 0-9 (10 constructors).
data ChannelMode
  = Op  -- ^ Tag 0.
  | Voice  -- ^ Tag 1.
  | Ban  -- ^ Tag 2.
  | Limit  -- ^ Tag 3.
  | ChannelMode_InviteOnly  -- ^ Tag 4.
  | Moderated  -- ^ Tag 5.
  | NoExternalMsgs  -- ^ Tag 6.
  | TopicLock  -- ^ Tag 7.
  | Secret  -- ^ Tag 8.
  | Private  -- ^ Tag 9.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ChannelMode' to its ABI tag value.
channelModeToTag :: ChannelMode -> Word8
channelModeToTag = fromIntegral . fromEnum

-- | Decode a 'ChannelMode' from its ABI tag value.
channelModeFromTag :: Word8 -> Maybe ChannelMode
channelModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ChannelMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------

-- | State type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data State
  = Disconnected  -- ^ Tag 0.
  | Connecting  -- ^ Tag 1.
  | Registered  -- ^ Tag 2.
  | InChannel  -- ^ Tag 3.
  | Quitting  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'State' to its ABI tag value.
stateToTag :: State -> Word8
stateToTag = fromIntegral . fromEnum

-- | Decode a 'State' from its ABI tag value.
stateFromTag :: Word8 -> Maybe State
stateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: State)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- IrcError
-- ---------------------------------------------------------------------------

-- | IrcError type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data IrcError
  = None  -- ^ Tag 0.
  | IrcError_NickInUse  -- ^ Tag 1.
  | ChannelFull  -- ^ Tag 2.
  | IrcError_InviteOnly  -- ^ Tag 3.
  | Banned  -- ^ Tag 4.
  | NotRegistered  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'IrcError' to its ABI tag value.
ircErrorToTag :: IrcError -> Word8
ircErrorToTag = fromIntegral . fromEnum

-- | Decode a 'IrcError' from its ABI tag value.
ircErrorFromTag :: Word8 -> Maybe IrcError
ircErrorFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: IrcError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
