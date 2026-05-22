-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | AMQP 0-9-1 protocol types for the proven-servers ABI.
--
-- All tag values match the Idris2 ABI discriminants exactly.

module ProvenServers.Amqp
  (
    amqpPort
  , amqpsPort
  , FrameType(..)
  , frameTypeToTag
  , frameTypeFromTag
  , isContent
  , MethodClass(..)
  , methodClassToTag
  , methodClassFromTag
  , isConnectionLevel
  , ExchangeType(..)
  , exchangeTypeToTag
  , exchangeTypeFromTag
  , usesRoutingKey
  , DeliveryMode(..)
  , deliveryModeToTag
  , deliveryModeFromTag
  , ErrorSeverity(..)
  , errorSeverityToTag
  , errorSeverityFromTag
  , ConnectionState(..)
  , connectionStateToTag
  , connectionStateFromTag
  , connectionStateCanTransitionTo
  , ChannelState(..)
  , channelStateToTag
  , channelStateFromTag
  , channelStateCanTransitionTo
  , BrokerState(..)
  , brokerStateToTag
  , brokerStateFromTag
  , brokerStateCanTransitionTo
  ) where

import Data.Word (Word16, Word8)

-- | Standard AMQP port (non-TLS).
amqpPort :: Word16
amqpPort = 5672

-- | Standard AMQPS port (TLS).
amqpsPort :: Word16
amqpsPort = 5671

-- ---------------------------------------------------------------------------
-- FrameType
-- ---------------------------------------------------------------------------

-- | Standard AMQP port (non-TLS).
--
-- Tags 0-3 (4 constructors).
data FrameType
  = Method  -- ^ Method frame carrying AMQP commands (tag 0).
  | Header  -- ^ Content header frame with message properties (tag 1).
  | Body  -- ^ Content body frame with message payload (tag 2).
  | Heartbeat  -- ^ Heartbeat frame for keepalive (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'FrameType' to its ABI tag value.
frameTypeToTag :: FrameType -> Word8
frameTypeToTag = fromIntegral . fromEnum

-- | Decode a 'FrameType' from its ABI tag value.
frameTypeFromTag :: Word8 -> Maybe FrameType
frameTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: FrameType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this frame type carries message content.
isContent :: FrameType -> Bool
isContent Header = True
isContent Body = True
isContent _ = False

-- ---------------------------------------------------------------------------
-- MethodClass
-- ---------------------------------------------------------------------------

-- | AMQP 0-9-1 method classes.
--
-- Tags 0-6 (7 constructors).
data MethodClass
  = Connection  -- ^ Connection-level methods (tag 0).
  | Channel  -- ^ Channel-level methods (tag 1).
  | Exchange  -- ^ Exchange declaration and management (tag 2).
  | Queue  -- ^ Queue declaration and management (tag 3).
  | Basic  -- ^ Basic publish/consume/ack operations (tag 4).
  | Tx  -- ^ Transaction support (tag 5).
  | Confirm  -- ^ Publisher confirms (tag 6).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'MethodClass' to its ABI tag value.
methodClassToTag :: MethodClass -> Word8
methodClassToTag = fromIntegral . fromEnum

-- | Decode a 'MethodClass' from its ABI tag value.
methodClassFromTag :: Word8 -> Maybe MethodClass
methodClassFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MethodClass)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this class operates at the connection level (vs channel level).
isConnectionLevel :: MethodClass -> Bool
isConnectionLevel Connection = True
isConnectionLevel _ = False

-- ---------------------------------------------------------------------------
-- ExchangeType
-- ---------------------------------------------------------------------------

-- | AMQP exchange routing types.
--
-- Tags 0-3 (4 constructors).
data ExchangeType
  = Direct  -- ^ Direct routing by exact routing key match (tag 0).
  | Fanout  -- ^ Fanout to all bound queues (tag 1).
  | Topic  -- ^ Topic-based pattern matching on routing keys (tag 2).
  | Headers  -- ^ Headers-based matching on message properties (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ExchangeType' to its ABI tag value.
exchangeTypeToTag :: ExchangeType -> Word8
exchangeTypeToTag = fromIntegral . fromEnum

-- | Decode a 'ExchangeType' from its ABI tag value.
exchangeTypeFromTag :: Word8 -> Maybe ExchangeType
exchangeTypeFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ExchangeType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Whether this exchange type uses routing keys for message delivery.
usesRoutingKey :: ExchangeType -> Bool
usesRoutingKey Direct = True
usesRoutingKey Topic = True
usesRoutingKey _ = False

-- ---------------------------------------------------------------------------
-- DeliveryMode
-- ---------------------------------------------------------------------------

-- | AMQP message delivery/persistence mode.
--
-- Tags 0-1 (2 constructors).
data DeliveryMode
  = NonPersistent  -- ^ Non-persistent: message may be lost on broker restart (tag 0).
  | Persistent  -- ^ Persistent: message survives broker restart (tag 1).
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

-- | AMQP error severity levels.
--
-- Tags 0-1 (2 constructors).
data ErrorSeverity
  = ChannelLevel  -- ^ Channel-level error: only the affected channel is closed (tag 0).
  | ConnectionLevel  -- ^ Connection-level error: the entire connection is closed (tag 1).
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

-- | AMQP connection state machine.
--
-- Tags 0-4 (5 constructors).
data ConnectionState
  = Idle  -- ^ Initial idle state, no connection yet (tag 0).
  | Negotiating  -- ^ Protocol negotiation in progress (tag 1).
  | TuningOk  -- ^ Connection tuning parameters accepted (tag 2).
  | Open  -- ^ Connection is open and ready (tag 3).
  | Closing  -- ^ Connection close in progress (tag 4).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ConnectionState' to its ABI tag value.
connectionStateToTag :: ConnectionState -> Word8
connectionStateToTag = fromIntegral . fromEnum

-- | Decode a 'ConnectionState' from its ABI tag value.
connectionStateFromTag :: Word8 -> Maybe ConnectionState
connectionStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ConnectionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Validate whether a state transition is allowed.
connectionStateCanTransitionTo :: ConnectionState -> ConnectionState -> Bool
connectionStateCanTransitionTo Idle Negotiating = True
connectionStateCanTransitionTo Negotiating TuningOk = True
connectionStateCanTransitionTo TuningOk Open = True
connectionStateCanTransitionTo Open Closing = True
connectionStateCanTransitionTo _ Closing = True
connectionStateCanTransitionTo _ _ = False

-- ---------------------------------------------------------------------------
-- ChannelState
-- ---------------------------------------------------------------------------

-- | AMQP channel state machine.
--
-- Tags 0-3 (4 constructors).
data ChannelState
  = Closed  -- ^ Channel is closed (tag 0).
  | Opening  -- ^ Channel open request sent (tag 1).
  | ChOpen  -- ^ Channel is open and ready (tag 2).
  | ChClosing  -- ^ Channel close in progress (tag 3).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'ChannelState' to its ABI tag value.
channelStateToTag :: ChannelState -> Word8
channelStateToTag = fromIntegral . fromEnum

-- | Decode a 'ChannelState' from its ABI tag value.
channelStateFromTag :: Word8 -> Maybe ChannelState
channelStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: ChannelState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Validate whether a state transition is allowed.
channelStateCanTransitionTo :: ChannelState -> ChannelState -> Bool
channelStateCanTransitionTo Closed Opening = True
channelStateCanTransitionTo Opening ChOpen = True
channelStateCanTransitionTo Opening Closed = True
channelStateCanTransitionTo ChOpen ChClosing = True
channelStateCanTransitionTo ChClosing Closed = True
channelStateCanTransitionTo _ _ = False

-- ---------------------------------------------------------------------------
-- BrokerState
-- ---------------------------------------------------------------------------

-- | AMQP broker lifecycle state machine.
--
-- Tags 0-5 (6 constructors).
data BrokerState
  = Idle  -- ^ Broker is idle, not connected (tag 0).
  | Connected  -- ^ Connected to broker (tag 1).
  | ChannelOpen  -- ^ Channel is open on the broker connection (tag 2).
  | Consuming  -- ^ Actively consuming messages (tag 3).
  | Publishing  -- ^ Actively publishing messages (tag 4).
  | Disconnecting  -- ^ Disconnecting from broker (tag 5).
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Convert a 'BrokerState' to its ABI tag value.
brokerStateToTag :: BrokerState -> Word8
brokerStateToTag = fromIntegral . fromEnum

-- | Decode a 'BrokerState' from its ABI tag value.
brokerStateFromTag :: Word8 -> Maybe BrokerState
brokerStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: BrokerState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Validate whether a state transition is allowed.
brokerStateCanTransitionTo :: BrokerState -> BrokerState -> Bool
brokerStateCanTransitionTo Idle Connected = True
brokerStateCanTransitionTo Connected ChannelOpen = True
brokerStateCanTransitionTo ChannelOpen Consuming = True
brokerStateCanTransitionTo ChannelOpen Publishing = True
brokerStateCanTransitionTo Consuming Disconnecting = True
brokerStateCanTransitionTo Publishing Disconnecting = True
brokerStateCanTransitionTo _ Disconnecting = True
brokerStateCanTransitionTo _ _ = False
