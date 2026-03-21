-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | MQTT protocol types for proven-servers.
--
-- MQTT protocol types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.MqttTypes
  ( -- * ADT types matching Idris2 ABI
      QoS(..)
    , SubAckCode(..)
    , PacketType(..)
    , PacketDirection(..)
    , qoSToTag
    , qoSFromTag
    , subAckCodeToTag
    , subAckCodeFromTag
    , packetTypeToTag
    , packetTypeFromTag
    , packetDirectionToTag
    , packetDirectionFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- QoS
-- ---------------------------------------------------------------------------

-- | QoS type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data QoS
  = AtMostOnce  -- ^ Tag 0.
  | AtLeastOnce  -- ^ Tag 1.
  | ExactlyOnce  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'QoS' to its ABI tag value.
qoSToTag :: QoS -> Word8
qoSToTag = fromIntegral . fromEnum

-- | Decode a 'QoS' from its ABI tag value.
qoSFromTag :: Word8 -> Maybe QoS
qoSFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: QoS)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- SubAckCode
-- ---------------------------------------------------------------------------

-- | SubAckCode type matching the Idris2 ABI.
--
-- Tags 0-0 (4 constructors).
data SubAckCode
  = GrantedQoS0  -- ^ Tag 0.
  | GrantedQoS1  -- ^ Tag 0.
  | GrantedQoS2  -- ^ Tag 0.
  | Failure  -- ^ Tag 0.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'SubAckCode' to its ABI tag value.
subAckCodeToTag :: SubAckCode -> Word8
subAckCodeToTag = fromIntegral . fromEnum

-- | Decode a 'SubAckCode' from its ABI tag value.
subAckCodeFromTag :: Word8 -> Maybe SubAckCode
subAckCodeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: SubAckCode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- PacketType
-- ---------------------------------------------------------------------------

-- | PacketType type matching the Idris2 ABI.
--
-- Tags 1-15 (15 constructors).
data PacketType
  = Connect  -- ^ Tag 1.
  | Connack  -- ^ Tag 2.
  | Publish  -- ^ Tag 3.
  | Puback  -- ^ Tag 4.
  | Pubrec  -- ^ Tag 5.
  | Pubrel  -- ^ Tag 6.
  | Pubcomp  -- ^ Tag 7.
  | Subscribe  -- ^ Tag 8.
  | Suback  -- ^ Tag 9.
  | Unsubscribe  -- ^ Tag 10.
  | Unsuback  -- ^ Tag 11.
  | Pingreq  -- ^ Tag 12.
  | Pingresp  -- ^ Tag 13.
  | Disconnect  -- ^ Tag 14.
  | Auth  -- ^ Tag 15.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PacketType' to its ABI tag value.
packetTypeToTag :: PacketType -> Word8
packetTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PacketType' from its ABI tag value.
packetTypeFromTag :: Word8 -> Maybe PacketType
packetTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PacketType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- PacketDirection
-- ---------------------------------------------------------------------------

-- | PacketDirection type matching the Idris2 ABI.
--
-- Tags 0-2 (3 constructors).
data PacketDirection
  = ClientToServer  -- ^ Tag 0.
  | ServerToClient  -- ^ Tag 1.
  | Bidirectional  -- ^ Tag 2.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PacketDirection' to its ABI tag value.
packetDirectionToTag :: PacketDirection -> Word8
packetDirectionToTag = fromIntegral . fromEnum

-- | Decode a 'PacketDirection' from its ABI tag value.
packetDirectionFromTag :: Word8 -> Maybe PacketDirection
packetDirectionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PacketDirection)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
