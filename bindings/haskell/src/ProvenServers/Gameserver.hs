-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Game Server types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Gameserver
  (
    SessionType(..)
  , sessionTypeToTag
  , sessionTypeFromTag
  , PlayerState(..)
  , playerStateToTag
  , playerStateFromTag
  , MatchState(..)
  , matchStateToTag
  , matchStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- SessionType
-- ---------------------------------------------------------------------------

-- | Game session types.
--
-- Tags 0-4 (5 constructors).
data SessionType
  = Lobby  -- ^ Lobby (tag 0).
  | Match  -- ^ Match (tag 1).
  | Practice  -- ^ Practice (tag 2).
  | Spectator  -- ^ Spectator (tag 3).
  | Tournament  -- ^ Tournament (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionType' to its ABI tag value.
sessionTypeToTag :: SessionType -> Word8
sessionTypeToTag = fromIntegral . fromEnum

-- | Decode a 'SessionType' from its ABI tag value.
sessionTypeFromTag :: Word8 -> Maybe SessionType
sessionTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- PlayerState
-- ---------------------------------------------------------------------------

-- | Game player states.
--
-- Tags 0-5 (6 constructors).
data PlayerState
  = Idle  -- ^ Idle (tag 0).
  | Queuing  -- ^ Queuing (tag 1).
  | Loading  -- ^ Loading (tag 2).
  | Playing  -- ^ Playing (tag 3).
  | Spectating  -- ^ Spectating (tag 4).
  | Disconnected  -- ^ Disconnected (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PlayerState' to its ABI tag value.
playerStateToTag :: PlayerState -> Word8
playerStateToTag = fromIntegral . fromEnum

-- | Decode a 'PlayerState' from its ABI tag value.
playerStateFromTag :: Word8 -> Maybe PlayerState
playerStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PlayerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- MatchState
-- ---------------------------------------------------------------------------

-- | Game match states.
--
-- Tags 0-5 (6 constructors).
data MatchState
  = Waiting  -- ^ Waiting (tag 0).
  | Starting  -- ^ Starting (tag 1).
  | InProgress  -- ^ InProgress (tag 2).
  | Paused  -- ^ Paused (tag 3).
  | Ending  -- ^ Ending (tag 4).
  | Complete  -- ^ Complete (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MatchState' to its ABI tag value.
matchStateToTag :: MatchState -> Word8
matchStateToTag = fromIntegral . fromEnum

-- | Decode a 'MatchState' from its ABI tag value.
matchStateFromTag :: Word8 -> Maybe MatchState
matchStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MatchState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
