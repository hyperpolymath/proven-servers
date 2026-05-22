-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Data Diode types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Diode
  (
    Direction(..)
  , directionToTag
  , directionFromTag
  , DiodeProtocol(..)
  , diodeProtocolToTag
  , diodeProtocolFromTag
  , TransferState(..)
  , transferStateToTag
  , transferStateFromTag
  , ValidationResult(..)
  , validationResultToTag
  , validationResultFromTag
  , IntegrityCheck(..)
  , integrityCheckToTag
  , integrityCheckFromTag
  , GatewayState(..)
  , gatewayStateToTag
  , gatewayStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Direction
-- ---------------------------------------------------------------------------

-- | Diode data flow direction.
--
-- Tags 0-1 (2 constructors).
data Direction
  = HighToLow  -- ^ HighToLow (tag 0).
  | LowToHigh  -- ^ LowToHigh (tag 1).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Direction' to its ABI tag value.
directionToTag :: Direction -> Word8
directionToTag = fromIntegral . fromEnum

-- | Decode a 'Direction' from its ABI tag value.
directionFromTag :: Word8 -> Maybe Direction
directionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Direction)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DiodeProtocol
-- ---------------------------------------------------------------------------

-- | Diode transfer protocols.
--
-- Tags 0-4 (5 constructors).
data DiodeProtocol
  = Udp  -- ^ UDP (tag 0).
  | Tcp  -- ^ TCP (tag 1).
  | FileTransfer  -- ^ FileTransfer (tag 2).
  | Syslog  -- ^ Syslog (tag 3).
  | Snmp  -- ^ SNMP (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DiodeProtocol' to its ABI tag value.
diodeProtocolToTag :: DiodeProtocol -> Word8
diodeProtocolToTag = fromIntegral . fromEnum

-- | Decode a 'DiodeProtocol' from its ABI tag value.
diodeProtocolFromTag :: Word8 -> Maybe DiodeProtocol
diodeProtocolFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DiodeProtocol)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- TransferState
-- ---------------------------------------------------------------------------

-- | Diode transfer states.
--
-- Tags 0-4 (5 constructors).
data TransferState
  = Queued  -- ^ Queued (tag 0).
  | Sending  -- ^ Sending (tag 1).
  | Confirming  -- ^ Confirming (tag 2).
  | Complete  -- ^ Complete (tag 3).
  | Failed  -- ^ Failed (tag 4).
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
-- ValidationResult
-- ---------------------------------------------------------------------------

-- | Data validation results.
--
-- Tags 0-3 (4 constructors).
data ValidationResult
  = Passed  -- ^ Passed (tag 0).
  | FormatError  -- ^ FormatError (tag 1).
  | SizeExceeded  -- ^ SizeExceeded (tag 2).
  | PolicyBlocked  -- ^ PolicyBlocked (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ValidationResult' to its ABI tag value.
validationResultToTag :: ValidationResult -> Word8
validationResultToTag = fromIntegral . fromEnum

-- | Decode a 'ValidationResult' from its ABI tag value.
validationResultFromTag :: Word8 -> Maybe ValidationResult
validationResultFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ValidationResult)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- IntegrityCheck
-- ---------------------------------------------------------------------------

-- | Integrity verification methods.
--
-- Tags 0-2 (3 constructors).
data IntegrityCheck
  = Crc32  -- ^ CRC-32 (tag 0).
  | Sha256  -- ^ SHA-256 (tag 1).
  | Hmac  -- ^ HMAC (tag 2).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'IntegrityCheck' to its ABI tag value.
integrityCheckToTag :: IntegrityCheck -> Word8
integrityCheckToTag = fromIntegral . fromEnum

-- | Decode a 'IntegrityCheck' from its ABI tag value.
integrityCheckFromTag :: Word8 -> Maybe IntegrityCheck
integrityCheckFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: IntegrityCheck)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- GatewayState
-- ---------------------------------------------------------------------------

-- | Diode gateway states.
--
-- Tags 0-4 (5 constructors).
data GatewayState
  = Idle  -- ^ Idle (tag 0).
  | Configured  -- ^ Configured (tag 1).
  | Transferring  -- ^ Transferring (tag 2).
  | Validating  -- ^ Validating (tag 3).
  | Shutdown  -- ^ Shutdown (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'GatewayState' to its ABI tag value.
gatewayStateToTag :: GatewayState -> Word8
gatewayStateToTag = fromIntegral . fromEnum

-- | Decode a 'GatewayState' from its ABI tag value.
gatewayStateFromTag :: Word8 -> Maybe GatewayState
gatewayStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: GatewayState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
