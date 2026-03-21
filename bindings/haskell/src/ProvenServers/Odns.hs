-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | ODNS protocol types for proven-servers.
--
-- Oblivious DNS types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Odns
  ( -- * ADT types matching Idris2 ABI
      Role(..)
    , OdnsMessageType(..)
    , OdnsErrorReason(..)
    , EncapsulationFormat(..)
    , SessionState(..)
    , roleToTag
    , roleFromTag
    , odnsMessageTypeToTag
    , odnsMessageTypeFromTag
    , odnsErrorReasonToTag
    , odnsErrorReasonFromTag
    , encapsulationFormatToTag
    , encapsulationFormatFromTag
    , sessionStateToTag
    , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Role
-- ---------------------------------------------------------------------------

-- | Role type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data Role
  = Client  -- ^ Tag 0.
  | Proxy  -- ^ Tag 1.
  | Target  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'Role' to its ABI tag value.
roleToTag :: Role -> Word8
roleToTag = fromIntegral . fromEnum

-- | Decode a 'Role' from its ABI tag value.
roleFromTag :: Word8 -> Maybe Role
roleFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: Role)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- OdnsMessageType
-- ---------------------------------------------------------------------------

-- | OdnsMessageType type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data OdnsMessageType
  = Query  -- ^ Tag 0.
  | Response  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'OdnsMessageType' to its ABI tag value.
odnsMessageTypeToTag :: OdnsMessageType -> Word8
odnsMessageTypeToTag = fromIntegral . fromEnum

-- | Decode a 'OdnsMessageType' from its ABI tag value.
odnsMessageTypeFromTag :: Word8 -> Maybe OdnsMessageType
odnsMessageTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: OdnsMessageType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- OdnsErrorReason
-- ---------------------------------------------------------------------------

-- | OdnsErrorReason type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data OdnsErrorReason
  = ProxyError  -- ^ Tag 0.
  | TargetError  -- ^ Tag 1.
  | DecryptionFailed  -- ^ Tag 2.
  | InvalidConfig  -- ^ Tag 3.
  | PayloadTooLarge  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'OdnsErrorReason' to its ABI tag value.
odnsErrorReasonToTag :: OdnsErrorReason -> Word8
odnsErrorReasonToTag = fromIntegral . fromEnum

-- | Decode a 'OdnsErrorReason' from its ABI tag value.
odnsErrorReasonFromTag :: Word8 -> Maybe OdnsErrorReason
odnsErrorReasonFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: OdnsErrorReason)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- EncapsulationFormat
-- ---------------------------------------------------------------------------

-- | EncapsulationFormat type matching the Idris2 ABI.
--
-- Tags 0-0 (1 constructors).
data EncapsulationFormat
  = Hpke  -- ^ Tag 0.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'EncapsulationFormat' to its ABI tag value.
encapsulationFormatToTag :: EncapsulationFormat -> Word8
encapsulationFormatToTag = fromIntegral . fromEnum

-- | Decode a 'EncapsulationFormat' from its ABI tag value.
encapsulationFormatFromTag :: Word8 -> Maybe EncapsulationFormat
encapsulationFormatFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: EncapsulationFormat)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SessionState
-- ---------------------------------------------------------------------------

-- | SessionState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Tag 0.
  | KeyExchange  -- ^ Tag 1.
  | Ready  -- ^ Tag 2.
  | Processing  -- ^ Tag 3.
  | Closing  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
