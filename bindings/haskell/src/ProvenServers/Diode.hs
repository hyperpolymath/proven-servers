-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | Data Diode protocol types for proven-servers.
--
-- Data diode (unidirectional network) types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Diode
  ( -- * ADT types matching Idris2 ABI
      Direction(..)
    , DiodeProtocol(..)
    , TransferState(..)
    , ValidationResult(..)
    , IntegrityCheck(..)
    , GatewayState(..)
    , directionToTag
    , directionFromTag
    , diodeProtocolToTag
    , diodeProtocolFromTag
    , transferStateToTag
    , transferStateFromTag
    , validationResultToTag
    , validationResultFromTag
    , integrityCheckToTag
    , integrityCheckFromTag
    , gatewayStateToTag
    , gatewayStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Direction
-- ---------------------------------------------------------------------------

-- | Direction type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data Direction
  = HighToLow  -- ^ Tag 0.
  | LowToHigh  -- ^ Tag 1.
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

-- | DiodeProtocol type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data DiodeProtocol
  = Udp  -- ^ Tag 0.
  | Tcp  -- ^ Tag 1.
  | FileTransfer  -- ^ Tag 2.
  | Syslog  -- ^ Tag 3.
  | Snmp  -- ^ Tag 4.
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

-- | TransferState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data TransferState
  = Queued  -- ^ Tag 0.
  | Sending  -- ^ Tag 1.
  | Confirming  -- ^ Tag 2.
  | Complete  -- ^ Tag 3.
  | Failed  -- ^ Tag 4.
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

-- | ValidationResult type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ValidationResult
  = Passed  -- ^ Tag 0.
  | FormatError  -- ^ Tag 1.
  | SizeExceeded  -- ^ Tag 2.
  | PolicyBlocked  -- ^ Tag 3.
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

-- | IntegrityCheck type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data IntegrityCheck
  = Crc32  -- ^ Tag 0.
  | Sha256  -- ^ Tag 1.
  | Hmac  -- ^ Tag 2.
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

-- | GatewayState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data GatewayState
  = Idle  -- ^ Tag 0.
  | Configured  -- ^ Tag 1.
  | Transferring  -- ^ Tag 2.
  | Validating  -- ^ Tag 3.
  | Shutdown  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'GatewayState' to its ABI tag value.
gatewayStateToTag :: GatewayState -> Word8
gatewayStateToTag = fromIntegral . fromEnum

-- | Decode a 'GatewayState' from its ABI tag value.
gatewayStateFromTag :: Word8 -> Maybe GatewayState
gatewayStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: GatewayState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
