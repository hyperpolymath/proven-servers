-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | LPD types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Lpd
  (
    lpdPort
  , CommandCode(..)
  , commandCodeToTag
  , commandCodeFromTag
  , SubCommandCode(..)
  , subCommandCodeToTag
  , subCommandCodeFromTag
  , JobStatus(..)
  , jobStatusToTag
  , jobStatusFromTag
  ) where

import Data.Word (Word16, Word8)

-- | Standard LPD port.
lpdPort :: Word16
lpdPort = 515

-- ---------------------------------------------------------------------------
-- CommandCode
-- ---------------------------------------------------------------------------

-- | Standard LPD port.
--
-- Tags 0-5 (5 constructors).
data CommandCode
  = PrintJob  -- ^ Print any waiting jobs  (tag 1).
  | ReceiveJob  -- ^ Receive a print job  (tag 2).
  | ShortQueue  -- ^ Short queue listing  (tag 3).
  | LongQueue  -- ^ Long queue listing  (tag 4).
  | RemoveJobs  -- ^ Remove jobs  (tag 5).
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

-- | LPD sub-command codes.
--
-- Tags 0-3 (3 constructors).
data SubCommandCode
  = AbortJob  -- ^ Abort job  (tag 1).
  | ControlFile  -- ^ Receive control file  (tag 2).
  | DataFile  -- ^ Receive data file  (tag 3).
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

-- | Print job status.
--
-- Tags 0-3 (4 constructors).
data JobStatus
  = Pending  -- ^ Pending (tag 0).
  | Printing  -- ^ Printing (tag 1).
  | Complete  -- ^ Complete (tag 2).
  | Failed  -- ^ Failed (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'JobStatus' to its ABI tag value.
jobStatusToTag :: JobStatus -> Word8
jobStatusToTag = fromIntegral . fromEnum

-- | Decode a 'JobStatus' from its ABI tag value.
jobStatusFromTag :: Word8 -> Maybe JobStatus
jobStatusFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: JobStatus)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
