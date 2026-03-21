-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | IMAP protocol types for proven-servers.
--
-- IMAP protocol types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Imap
  ( -- * ADT types matching Idris2 ABI
      Command(..)
    , State(..)
    , Flag(..)
    , commandToTag
    , commandFromTag
    , stateToTag
    , stateFromTag
    , flagToTag
    , flagFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------------

-- | Command type matching the Idris2 ABI.
--
-- Tags 0-13 (14 constructors).
data Command
  = Login  -- ^ Tag 0.
  | Command_Logout  -- ^ Tag 1.
  | Select  -- ^ Tag 2.
  | Examine  -- ^ Tag 3.
  | Create  -- ^ Tag 4.
  | Delete  -- ^ Tag 5.
  | Rename  -- ^ Tag 6.
  | List  -- ^ Tag 7.
  | Fetch  -- ^ Tag 8.
  | Store  -- ^ Tag 9.
  | Search  -- ^ Tag 10.
  | Copy  -- ^ Tag 11.
  | Noop  -- ^ Tag 12.
  | Capability  -- ^ Tag 13.
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
-- State
-- ---------------------------------------------------------------------------

-- | State type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data State
  = NotAuthenticated  -- ^ Tag 0.
  | Authenticated  -- ^ Tag 1.
  | Selected  -- ^ Tag 2.
  | State_Logout  -- ^ Tag 3.
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
-- Flag
-- ---------------------------------------------------------------------------

-- | Flag type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data Flag
  = Seen  -- ^ Tag 0.
  | Answered  -- ^ Tag 1.
  | Flagged  -- ^ Tag 2.
  | Deleted  -- ^ Tag 3.
  | Draft  -- ^ Tag 4.
  | Recent  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Flag' to its ABI tag value.
flagToTag :: Flag -> Word8
flagToTag = fromIntegral . fromEnum

-- | Decode a 'Flag' from its ABI tag value.
flagFromTag :: Word8 -> Maybe Flag
flagFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Flag)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
