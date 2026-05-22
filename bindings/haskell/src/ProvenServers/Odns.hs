-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | ODNS types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Odns
  (
    Role(..)
  , roleToTag
  , roleFromTag
  , OdnsMessageType(..)
  , odnsMessageTypeToTag
  , odnsMessageTypeFromTag
  , OdnsErrorReason(..)
  , odnsErrorReasonToTag
  , odnsErrorReasonFromTag
  , EncapsulationFormat(..)
  , encapsulationFormatToTag
  , encapsulationFormatFromTag
  , SessionState(..)
  , sessionStateToTag
  , sessionStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Role
-- ---------------------------------------------------------------------------

-- | ODNS participant roles.
--
-- Tags 0-2 (3 constructors).
data Role
  = Client  -- ^ Client (tag 0).
  | Proxy  -- ^ Proxy (tag 1).
  | Target  -- ^ Target (tag 2).
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

-- | ODNS message types.
--
-- Tags 0-1 (2 constructors).
data OdnsMessageType
  = Query  -- ^ Query (tag 0).
  | Response  -- ^ Response (tag 1).
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

-- | ODNS error reasons.
--
-- Tags 0-4 (5 constructors).
data OdnsErrorReason
  = ProxyError  -- ^ ProxyError (tag 0).
  | TargetError  -- ^ TargetError (tag 1).
  | DecryptionFailed  -- ^ DecryptionFailed (tag 2).
  | InvalidConfig  -- ^ InvalidConfig (tag 3).
  | PayloadTooLarge  -- ^ PayloadTooLarge (tag 4).
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

-- | ODNS encapsulation formats.
--
-- Tags 0-0 (1 constructors).
data EncapsulationFormat
  = Hpke  -- ^ HPKE (tag 0).
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

-- | ODNS session states.
--
-- Tags 0-4 (5 constructors).
data SessionState
  = Idle  -- ^ Idle (tag 0).
  | KeyExchange  -- ^ KeyExchange (tag 1).
  | Ready  -- ^ Ready (tag 2).
  | Processing  -- ^ Processing (tag 3).
  | Closing  -- ^ Closing (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SessionState' to its ABI tag value.
sessionStateToTag :: SessionState -> Word8
sessionStateToTag = fromIntegral . fromEnum

-- | Decode a 'SessionState' from its ABI tag value.
sessionStateFromTag :: Word8 -> Maybe SessionState
sessionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
