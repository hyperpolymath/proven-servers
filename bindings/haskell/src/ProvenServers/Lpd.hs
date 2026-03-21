-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | LPD protocol types for proven-servers.
--
-- Line Printer Daemon types (RFC 1179), mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Lpd
  ( -- * ADT types matching Idris2 ABI
      CommandCode(..)
    , SubCommandCode(..)
    , JobStatus(..)
    , commandCodeToTag
    , commandCodeFromTag
    , subCommandCodeToTag
    , subCommandCodeFromTag
    , jobStatusToTag
    , jobStatusFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- CommandCode
-- ---------------------------------------------------------------------------

-- | CommandCode type matching the Idris2 ABI.
--
-- Tags 1-5 (5 constructors).
data CommandCode
  = PrintJob  -- ^ Tag 1.
  | ReceiveJob  -- ^ Tag 2.
  | ShortQueue  -- ^ Tag 3.
  | LongQueue  -- ^ Tag 4.
  | RemoveJobs  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'CommandCode' to its ABI tag value.
commandCodeToTag :: CommandCode -> Word8
commandCodeToTag = fromIntegral . fromEnum

-- | Decode a 'CommandCode' from its ABI tag value.
commandCodeFromTag :: Word8 -> Maybe CommandCode
commandCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: CommandCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SubCommandCode
-- ---------------------------------------------------------------------------

-- | SubCommandCode type matching the Idris2 ABI.
--
-- Tags 1-3 (3 constructors).
data SubCommandCode
  = AbortJob  -- ^ Tag 1.
  | ControlFile  -- ^ Tag 2.
  | DataFile  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SubCommandCode' to its ABI tag value.
subCommandCodeToTag :: SubCommandCode -> Word8
subCommandCodeToTag = fromIntegral . fromEnum

-- | Decode a 'SubCommandCode' from its ABI tag value.
subCommandCodeFromTag :: Word8 -> Maybe SubCommandCode
subCommandCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SubCommandCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- JobStatus
-- ---------------------------------------------------------------------------

-- | JobStatus type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data JobStatus
  = Pending  -- ^ Tag 0.
  | Printing  -- ^ Tag 1.
  | Complete  -- ^ Tag 2.
  | Failed  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'JobStatus' to its ABI tag value.
jobStatusToTag :: JobStatus -> Word8
jobStatusToTag = fromIntegral . fromEnum

-- | Decode a 'JobStatus' from its ABI tag value.
jobStatusFromTag :: Word8 -> Maybe JobStatus
jobStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: JobStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
