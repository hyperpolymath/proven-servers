-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Air Gap types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Airgap
  (
    TransferDirection(..)
  , transferDirectionToTag
  , transferDirectionFromTag
  , MediaType(..)
  , mediaTypeToTag
  , mediaTypeFromTag
  , ScanResult(..)
  , scanResultToTag
  , scanResultFromTag
  , isSafe
  , TransferState(..)
  , transferStateToTag
  , transferStateFromTag
  , ValidationCheck(..)
  , validationCheckToTag
  , validationCheckFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- TransferDirection
-- ---------------------------------------------------------------------------

-- | Air gap transfer direction.
--
-- Tags 0-1 (2 constructors).
data TransferDirection
  = Import  -- ^ Import (tag 0).
  | Export  -- ^ Export (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TransferDirection' to its ABI tag value.
transferDirectionToTag :: TransferDirection -> Word8
transferDirectionToTag = fromIntegral . fromEnum

-- | Decode a 'TransferDirection' from its ABI tag value.
transferDirectionFromTag :: Word8 -> Maybe TransferDirection
transferDirectionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TransferDirection)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- MediaType
-- ---------------------------------------------------------------------------

-- | Physical transfer media types.
--
-- Tags 0-3 (4 constructors).
data MediaType
  = Usb  -- ^ USB (tag 0).
  | OpticalDisc  -- ^ OpticalDisc (tag 1).
  | TapeCartridge  -- ^ TapeCartridge (tag 2).
  | DiodeLink  -- ^ DiodeLink (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MediaType' to its ABI tag value.
mediaTypeToTag :: MediaType -> Word8
mediaTypeToTag = fromIntegral . fromEnum

-- | Decode a 'MediaType' from its ABI tag value.
mediaTypeFromTag :: Word8 -> Maybe MediaType
mediaTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MediaType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ScanResult
-- ---------------------------------------------------------------------------

-- | Content scan results.
--
-- Tags 0-3 (4 constructors).
data ScanResult
  = Clean  -- ^ Clean (tag 0).
  | Suspicious  -- ^ Suspicious (tag 1).
  | Malicious  -- ^ Malicious (tag 2).
  | Unscannable  -- ^ Unscannable (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ScanResult' to its ABI tag value.
scanResultToTag :: ScanResult -> Word8
scanResultToTag = fromIntegral . fromEnum

-- | Decode a 'ScanResult' from its ABI tag value.
scanResultFromTag :: Word8 -> Maybe ScanResult
scanResultFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ScanResult)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether the content is safe to transfer.
isSafe :: ScanResult -> Bool
isSafe Clean = True
isSafe _ = False

-- ---------------------------------------------------------------------------
-- TransferState
-- ---------------------------------------------------------------------------

-- | Air gap transfer lifecycle.
--
-- Tags 0-6 (7 constructors).
data TransferState
  = Pending  -- ^ Pending (tag 0).
  | Scanning  -- ^ Scanning (tag 1).
  | Approved  -- ^ Approved (tag 2).
  | Rejected  -- ^ Rejected (tag 3).
  | InProgress  -- ^ InProgress (tag 4).
  | Complete  -- ^ Complete (tag 5).
  | Failed  -- ^ Failed (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'TransferState' to its ABI tag value.
transferStateToTag :: TransferState -> Word8
transferStateToTag = fromIntegral . fromEnum

-- | Decode a 'TransferState' from its ABI tag value.
transferStateFromTag :: Word8 -> Maybe TransferState
transferStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: TransferState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ValidationCheck
-- ---------------------------------------------------------------------------

-- | Validation check types.
--
-- Tags 0-4 (5 constructors).
data ValidationCheck
  = HashVerify  -- ^ HashVerify (tag 0).
  | SignatureVerify  -- ^ SignatureVerify (tag 1).
  | FormatCheck  -- ^ FormatCheck (tag 2).
  | ContentInspection  -- ^ ContentInspection (tag 3).
  | MalwareScan  -- ^ MalwareScan (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ValidationCheck' to its ABI tag value.
validationCheckToTag :: ValidationCheck -> Word8
validationCheckToTag = fromIntegral . fromEnum

-- | Decode a 'ValidationCheck' from its ABI tag value.
validationCheckFromTag :: Word8 -> Maybe ValidationCheck
validationCheckFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ValidationCheck)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
