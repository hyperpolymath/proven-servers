-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Air Gap protocol types for proven-servers.
--
-- Air-gapped transfer types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Airgap
  ( -- * ADT types matching Idris2 ABI
      TransferDirection(..)
    , MediaType(..)
    , ScanResult(..)
    , TransferState(..)
    , ValidationCheck(..)
    , transferDirectionToTag
    , transferDirectionFromTag
    , mediaTypeToTag
    , mediaTypeFromTag
    , scanResultToTag
    , scanResultFromTag
    , transferStateToTag
    , transferStateFromTag
    , validationCheckToTag
    , validationCheckFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- TransferDirection
-- ---------------------------------------------------------------------------

-- | TransferDirection type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data TransferDirection
  = Import  -- ^ Tag 0.
  | Export  -- ^ Tag 1.
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

-- | MediaType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data MediaType
  = Usb  -- ^ Tag 0.
  | OpticalDisc  -- ^ Tag 1.
  | TapeCartridge  -- ^ Tag 2.
  | DiodeLink  -- ^ Tag 3.
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

-- | ScanResult type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ScanResult
  = Clean  -- ^ Tag 0.
  | Suspicious  -- ^ Tag 1.
  | Malicious  -- ^ Tag 2.
  | Unscannable  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ScanResult' to its ABI tag value.
scanResultToTag :: ScanResult -> Word8
scanResultToTag = fromIntegral . fromEnum

-- | Decode a 'ScanResult' from its ABI tag value.
scanResultFromTag :: Word8 -> Maybe ScanResult
scanResultFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ScanResult)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TransferState
-- ---------------------------------------------------------------------------

-- | TransferState type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data TransferState
  = Pending  -- ^ Tag 0.
  | Scanning  -- ^ Tag 1.
  | Approved  -- ^ Tag 2.
  | Rejected  -- ^ Tag 3.
  | InProgress  -- ^ Tag 4.
  | Complete  -- ^ Tag 5.
  | Failed  -- ^ Tag 6.
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

-- | ValidationCheck type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ValidationCheck
  = HashVerify  -- ^ Tag 0.
  | SignatureVerify  -- ^ Tag 1.
  | FormatCheck  -- ^ Tag 2.
  | ContentInspection  -- ^ Tag 3.
  | MalwareScan  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ValidationCheck' to its ABI tag value.
validationCheckToTag :: ValidationCheck -> Word8
validationCheckToTag = fromIntegral . fromEnum

-- | Decode a 'ValidationCheck' from its ABI tag value.
validationCheckFromTag :: Word8 -> Maybe ValidationCheck
validationCheckFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ValidationCheck)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
