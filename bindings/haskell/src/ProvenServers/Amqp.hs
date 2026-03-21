-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | AMQP protocol types for proven-servers.
--
-- AMQP 0-9-1 protocol types, mirroring the Idris2 ABI.
-- All tag values match the Idris2 ABI discriminants exactly.
--
-- This is a pure type-definition module with no FFI dependencies.

module ProvenServers.Amqp
  ( -- * ADT types matching Idris2 ABI
      FrameType(..)
    , MethodClass(..)
    , ExchangeType(..)
    , DeliveryMode(..)
    , ErrorSeverity(..)
    , ConnectionState(..)
    , ChannelState(..)
    , BrokerState(..)
    , frameTypeToTag
    , frameTypeFromTag
    , methodClassToTag
    , methodClassFromTag
    , exchangeTypeToTag
    , exchangeTypeFromTag
    , deliveryModeToTag
    , deliveryModeFromTag
    , errorSeverityToTag
    , errorSeverityFromTag
    , connectionStateToTag
    , connectionStateFromTag
    , channelStateToTag
    , channelStateFromTag
    , brokerStateToTag
    , brokerStateFromTag
  ) where

import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- FrameType
-- ---------------------------------------------------------------------------

-- | FrameType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data FrameType
  = Method  -- ^ Tag 0.
  | Header  -- ^ Tag 1.
  | Body  -- ^ Tag 2.
  | Heartbeat  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'FrameType' to its ABI tag value.
frameTypeToTag :: FrameType -> Word8
frameTypeToTag = fromIntegral . fromEnum

-- | Decode a 'FrameType' from its ABI tag value.
frameTypeFromTag :: Word8 -> Maybe FrameType
frameTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: FrameType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- MethodClass
-- ---------------------------------------------------------------------------

-- | MethodClass type matching the Idris2 ABI.
--
-- Tags 0-6 (7 constructors).
data MethodClass
  = Connection  -- ^ Tag 0.
  | Channel  -- ^ Tag 1.
  | Exchange  -- ^ Tag 2.
  | Queue  -- ^ Tag 3.
  | Basic  -- ^ Tag 4.
  | Tx  -- ^ Tag 5.
  | Confirm  -- ^ Tag 6.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MethodClass' to its ABI tag value.
methodClassToTag :: MethodClass -> Word8
methodClassToTag = fromIntegral . fromEnum

-- | Decode a 'MethodClass' from its ABI tag value.
methodClassFromTag :: Word8 -> Maybe MethodClass
methodClassFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MethodClass)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ExchangeType
-- ---------------------------------------------------------------------------

-- | ExchangeType type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ExchangeType
  = Direct  -- ^ Tag 0.
  | Fanout  -- ^ Tag 1.
  | Topic  -- ^ Tag 2.
  | Headers  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ExchangeType' to its ABI tag value.
exchangeTypeToTag :: ExchangeType -> Word8
exchangeTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ExchangeType' from its ABI tag value.
exchangeTypeFromTag :: Word8 -> Maybe ExchangeType
exchangeTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ExchangeType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- DeliveryMode
-- ---------------------------------------------------------------------------

-- | DeliveryMode type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data DeliveryMode
  = NonPersistent  -- ^ Tag 0.
  | Persistent  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'DeliveryMode' to its ABI tag value.
deliveryModeToTag :: DeliveryMode -> Word8
deliveryModeToTag = fromIntegral . fromEnum

-- | Decode a 'DeliveryMode' from its ABI tag value.
deliveryModeFromTag :: Word8 -> Maybe DeliveryMode
deliveryModeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: DeliveryMode)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ErrorSeverity
-- ---------------------------------------------------------------------------

-- | ErrorSeverity type matching the Idris2 ABI.
--
-- Tags 0-1 (2 constructors).
data ErrorSeverity
  = ChannelLevel  -- ^ Tag 0.
  | ConnectionLevel  -- ^ Tag 1.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ErrorSeverity' to its ABI tag value.
errorSeverityToTag :: ErrorSeverity -> Word8
errorSeverityToTag = fromIntegral . fromEnum

-- | Decode a 'ErrorSeverity' from its ABI tag value.
errorSeverityFromTag :: Word8 -> Maybe ErrorSeverity
errorSeverityFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ErrorSeverity)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ConnectionState
-- ---------------------------------------------------------------------------

-- | ConnectionState type matching the Idris2 ABI.
--
-- Tags 0-4 (5 constructors).
data ConnectionState
  = ConnectionState_Idle  -- ^ Tag 0.
  | Negotiating  -- ^ Tag 1.
  | TuningOk  -- ^ Tag 2.
  | Open  -- ^ Tag 3.
  | Closing  -- ^ Tag 4.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ConnectionState' to its ABI tag value.
connectionStateToTag :: ConnectionState -> Word8
connectionStateToTag = fromIntegral . fromEnum

-- | Decode a 'ConnectionState' from its ABI tag value.
connectionStateFromTag :: Word8 -> Maybe ConnectionState
connectionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ConnectionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- ChannelState
-- ---------------------------------------------------------------------------

-- | ChannelState type matching the Idris2 ABI.
--
-- Tags 0-3 (4 constructors).
data ChannelState
  = Closed  -- ^ Tag 0.
  | Opening  -- ^ Tag 1.
  | ChOpen  -- ^ Tag 2.
  | ChClosing  -- ^ Tag 3.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ChannelState' to its ABI tag value.
channelStateToTag :: ChannelState -> Word8
channelStateToTag = fromIntegral . fromEnum

-- | Decode a 'ChannelState' from its ABI tag value.
channelStateFromTag :: Word8 -> Maybe ChannelState
channelStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ChannelState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- ---------------------------------------------------------------------------
-- BrokerState
-- ---------------------------------------------------------------------------

-- | BrokerState type matching the Idris2 ABI.
--
-- Tags 0-5 (6 constructors).
data BrokerState
  = BrokerState_Idle  -- ^ Tag 0.
  | Connected  -- ^ Tag 1.
  | ChannelOpen  -- ^ Tag 2.
  | Consuming  -- ^ Tag 3.
  | Publishing  -- ^ Tag 4.
  | Disconnecting  -- ^ Tag 5.
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'BrokerState' to its ABI tag value.
brokerStateToTag :: BrokerState -> Word8
brokerStateToTag = fromIntegral . fromEnum

-- | Decode a 'BrokerState' from its ABI tag value.
brokerStateFromTag :: Word8 -> Maybe BrokerState
brokerStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: BrokerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing
