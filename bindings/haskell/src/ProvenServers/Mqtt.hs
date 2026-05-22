-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | MQTT protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Mqtt
  (
    QoS(..)
  , qoSToTag
  , qoSFromTag
  , requiresAck
  , SubAckCode(..)
  , subAckCodeToTag
  , subAckCodeFromTag
  , PacketType(..)
  , packetTypeToTag
  , packetTypeFromTag
  , requiresPacketId
  , PacketDirection(..)
  , packetDirectionToTag
  , packetDirectionFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- QoS
-- ---------------------------------------------------------------------------

-- | MQTT Quality of Service levels.
--
-- Tags 0-2 (3 constructors).
data QoS
  = AtMostOnce  -- ^ QoS 0: At most once delivery (fire and forget).
  | AtLeastOnce  -- ^ QoS 1: At least once delivery (PUBACK required).
  | ExactlyOnce  -- ^ QoS 2: Exactly once delivery (PUBREC/PUBREL/PUBCOMP handshake).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'QoS' to its ABI tag value.
qoSToTag :: QoS -> Word8
qoSToTag = fromIntegral . fromEnum

-- | Decode a 'QoS' from its ABI tag value.
qoSFromTag :: Word8 -> Maybe QoS
qoSFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: QoS)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Matches `requiresAck` in `MQTT.QoS`.
requiresAck :: QoS -> Bool
requiresAck AtMostOnce = False
requiresAck _ = True

-- ---------------------------------------------------------------------------
-- SubAckCode
-- ---------------------------------------------------------------------------

-- | SUBACK return code for a single topic subscription.
--
-- Tags 0-0 (4 constructors).
data SubAckCode
  = GrantedQoS0  -- ^ Subscription accepted with maximum QoS 0.
  | GrantedQoS1  -- ^ Subscription accepted with maximum QoS 1.
  | GrantedQoS2  -- ^ Subscription accepted with maximum QoS 2.
  | Failure  -- ^ Subscription rejected by the server.
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

-- | MQTT control packet types (MQTT 3.1.1 Section 2.2.1).
--
-- Tags 0-15 (15 constructors).
data PacketType
  = Connect  -- ^ Client request to connect to server (type 1).
  | Connack  -- ^ Server acknowledgement of connection (type 2).
  | Publish  -- ^ Publish message (type 3).
  | Puback  -- ^ Publish acknowledgement for QoS 1 (type 4).
  | Pubrec  -- ^ Publish received for QoS 2, step 1 (type 5).
  | Pubrel  -- ^ Publish release for QoS 2, step 2 (type 6).
  | Pubcomp  -- ^ Publish complete for QoS 2, step 3 (type 7).
  | Subscribe  -- ^ Client subscribe request (type 8).
  | Suback  -- ^ Server subscribe acknowledgement (type 9).
  | Unsubscribe  -- ^ Client unsubscribe request (type 10).
  | Unsuback  -- ^ Server unsubscribe acknowledgement (type 11).
  | Pingreq  -- ^ Client ping request (type 12).
  | Pingresp  -- ^ Server ping response (type 13).
  | Disconnect  -- ^ Client disconnect notification (type 14).
  | Auth  -- ^ Authentication exchange (MQTTv5, type 15).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PacketType' to its ABI tag value.
packetTypeToTag :: PacketType -> Word8
packetTypeToTag = fromIntegral . fromEnum

-- | Decode a 'PacketType' from its ABI tag value.
packetTypeFromTag :: Word8 -> Maybe PacketType
packetTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PacketType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | /// Matches `requiresPacketId` in `MQTT.PacketType`.
requiresPacketId :: PacketType -> Bool
requiresPacketId Puback = True
requiresPacketId Pubrec = True
requiresPacketId Pubrel = True
requiresPacketId Pubcomp = True
requiresPacketId Subscribe = True
requiresPacketId Suback = True
requiresPacketId Unsubscribe = True
requiresPacketId Unsuback = True
requiresPacketId _ = False

-- ---------------------------------------------------------------------------
-- PacketDirection
-- ---------------------------------------------------------------------------

-- | Direction of an MQTT packet: client-to-server, server-to-client, or both.
--
-- Tags 0-2 (3 constructors).
data PacketDirection
  = ClientToServer  -- ^ Sent from client to server only.
  | ServerToClient  -- ^ Sent from server to client only.
  | Bidirectional  -- ^ Can be sent in either direction.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'PacketDirection' to its ABI tag value.
packetDirectionToTag :: PacketDirection -> Word8
packetDirectionToTag = fromIntegral . fromEnum

-- | Decode a 'PacketDirection' from its ABI tag value.
packetDirectionFromTag :: Word8 -> Maybe PacketDirection
packetDirectionFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: PacketDirection)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
