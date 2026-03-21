-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Game Server protocol types for proven-servers.
--
-- Game server types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Gameserver
  ( -- * ADT types matching Idris2 ABI
      SessionType(..)
    , PlayerState(..)
    , MatchState(..)
    , sessionTypeToTag
    , sessionTypeFromTag
    , playerStateToTag
    , playerStateFromTag
    , matchStateToTag
    , matchStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- SessionType
-- ---------------------------------------------------------------------------

-- | SessionType type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SessionType
  = Lobby  -- ^ Tag 0.
  | Match  -- ^ Tag 1.
  | Practice  -- ^ Tag 2.
  | Spectator  -- ^ Tag 3.
  | Tournament  -- ^ Tag 4.
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

-- | PlayerState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data PlayerState
  = Idle  -- ^ Tag 0.
  | Queuing  -- ^ Tag 1.
  | Loading  -- ^ Tag 2.
  | Playing  -- ^ Tag 3.
  | Spectating  -- ^ Tag 4.
  | Disconnected  -- ^ Tag 5.
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

-- | MatchState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data MatchState
  = Waiting  -- ^ Tag 0.
  | Starting  -- ^ Tag 1.
  | InProgress  -- ^ Tag 2.
  | Paused  -- ^ Tag 3.
  | Ending  -- ^ Tag 4.
  | Complete  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MatchState' to its ABI tag value.
matchStateToTag :: MatchState -> Word8
matchStateToTag = fromIntegral . fromEnum

-- | Decode a 'MatchState' from its ABI tag value.
matchStateFromTag :: Word8 -> Maybe MatchState
matchStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MatchState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
