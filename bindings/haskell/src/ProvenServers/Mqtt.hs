-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- | MQTT protocol bindings for proven-servers.
--
-- Wraps the C-ABI functions from @protocols\/proven-mqtt\/ffi\/zig\/src\/mqtt.zig@.
-- Provides Haskell ADTs for MQTT session states and QoS levels.

{-# LANGUAGE ForeignFunctionInterface #-}

module ProvenServers.Mqtt
  ( -- * ADTs matching Idris2 ABI
    MqttSessionState(..)
  , QoS(..)
    -- * Context lifecycle
  , abiVersion
  , create
  , destroy
    -- * State queries
  , getState
  , version
  , canPublish
  , canSubscribe
  , subscriptionCount
    -- * Pub/Sub operations
  , subscribe
  , unsubscribe
  , publish
    -- * QoS handshake
  , puback
  , pubrec
  , pubrel
  , pubcomp
  , qosState
    -- * Session management
  , mqttDisconnect
  , cleanup
  , retainedCount
    -- * Transition queries
  , canTransition
  , qosCanTransition
  , topicMatches
  ) where

import Data.Word (Word8, Word16, Word32)
import Foreign.C.Types (CInt(..))
import Foreign.Ptr (Ptr)
import ProvenServers.Error (ProvenError, fromSlot, fromStatus)

-- ---------------------------------------------------------------------------
-- ADTs matching Idris2 ABI enums
-- ---------------------------------------------------------------------------

-- | MQTT broker session states matching the Zig FFI.
data MqttSessionState
  = MqttIdle         -- ^ Client connected, CONNECT not yet received.
  | MqttConnected    -- ^ CONNECT received, session active.
  | MqttDisconnected -- ^ Client disconnected cleanly.
  deriving (Show, Eq, Ord, Enum, Bounded)

mqttStateToTag :: MqttSessionState -> Word8
mqttStateToTag = fromIntegral . fromEnum

mqttStateFromTag :: Word8 -> Maybe MqttSessionState
mqttStateFromTag n
  | n <= fromIntegral (fromEnum (maxBound :: MqttSessionState)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | MQTT Quality of Service levels.
data QoS
  = QoS0 -- ^ At most once (fire and forget).
  | QoS1 -- ^ At least once (acknowledged delivery).
  | QoS2 -- ^ Exactly once (four-part handshake).
  deriving (Show, Eq, Ord, Enum, Bounded)

qosToCode :: QoS -> Word8
qosToCode = fromIntegral . fromEnum

-- ---------------------------------------------------------------------------
-- Foreign imports
-- ---------------------------------------------------------------------------

foreign import ccall unsafe "mqtt_abi_version"        c_mqtt_abi_version        :: IO Word32
foreign import ccall unsafe "mqtt_create"             c_mqtt_create             :: Word8 -> Word8 -> Word16 -> IO CInt
foreign import ccall unsafe "mqtt_destroy"            c_mqtt_destroy            :: CInt -> IO ()
foreign import ccall unsafe "mqtt_state"              c_mqtt_state              :: CInt -> IO Word8
foreign import ccall unsafe "mqtt_version"            c_mqtt_version            :: CInt -> IO Word8
foreign import ccall unsafe "mqtt_can_publish"        c_mqtt_can_publish        :: CInt -> IO Word8
foreign import ccall unsafe "mqtt_can_subscribe"      c_mqtt_can_subscribe      :: CInt -> IO Word8
foreign import ccall unsafe "mqtt_subscription_count" c_mqtt_subscription_count :: CInt -> IO Word32
foreign import ccall unsafe "mqtt_subscribe"          c_mqtt_subscribe          :: CInt -> Ptr Word8 -> Word32 -> Word8 -> IO Word8
foreign import ccall unsafe "mqtt_unsubscribe"        c_mqtt_unsubscribe        :: CInt -> Ptr Word8 -> Word32 -> IO Word8
foreign import ccall unsafe "mqtt_publish"            c_mqtt_publish            :: CInt -> Ptr Word8 -> Word32 -> Ptr Word8 -> Word32 -> Word8 -> Word8 -> Word16 -> IO Word8
foreign import ccall unsafe "mqtt_puback"             c_mqtt_puback             :: CInt -> Word16 -> IO Word8
foreign import ccall unsafe "mqtt_pubrec"             c_mqtt_pubrec             :: CInt -> Word16 -> IO Word8
foreign import ccall unsafe "mqtt_pubrel"             c_mqtt_pubrel             :: CInt -> Word16 -> IO Word8
foreign import ccall unsafe "mqtt_pubcomp"            c_mqtt_pubcomp            :: CInt -> Word16 -> IO Word8
foreign import ccall unsafe "mqtt_qos_state"          c_mqtt_qos_state          :: CInt -> Word16 -> IO Word8
foreign import ccall unsafe "mqtt_disconnect"         c_mqtt_disconnect         :: CInt -> IO Word8
foreign import ccall unsafe "mqtt_cleanup"            c_mqtt_cleanup            :: CInt -> IO Word8
foreign import ccall unsafe "mqtt_retained_count"     c_mqtt_retained_count     :: IO Word32
foreign import ccall unsafe "mqtt_can_transition"     c_mqtt_can_transition     :: Word8 -> Word8 -> IO Word8
foreign import ccall unsafe "mqtt_qos_can_transition" c_mqtt_qos_can_transition :: Word8 -> Word8 -> Word8 -> IO Word8
foreign import ccall unsafe "mqtt_topic_matches"      c_mqtt_topic_matches      :: Ptr Word8 -> Word32 -> Ptr Word8 -> Word32 -> IO Word8

-- ---------------------------------------------------------------------------
-- Safe wrappers
-- ---------------------------------------------------------------------------

-- | Return the ABI version.
abiVersion :: IO Word32
abiVersion = c_mqtt_abi_version

-- | Create a new MQTT session.
-- @ver@: 0 = MQTT 3.1.1, 1 = MQTT 5.0.
-- @cleanSession@: whether to start a clean session.
-- @keepAlive@: keep-alive interval in seconds.
create :: Word8 -> Bool -> Word16 -> IO (Either ProvenError CInt)
create ver cleanSession keepAlive =
  fromSlot . fromIntegral <$> c_mqtt_create ver (if cleanSession then 1 else 0) keepAlive

-- | Destroy an MQTT context.
destroy :: CInt -> IO ()
destroy = c_mqtt_destroy

-- | Get the current session state.
getState :: CInt -> IO (Maybe MqttSessionState)
getState slot = mqttStateFromTag <$> c_mqtt_state slot

-- | Get the MQTT protocol version tag.
version :: CInt -> IO Word8
version = c_mqtt_version

-- | Check if the session can publish messages.
canPublish :: CInt -> IO Bool
canPublish slot = (== 1) <$> c_mqtt_can_publish slot

-- | Check if the session can subscribe to topics.
canSubscribe :: CInt -> IO Bool
canSubscribe slot = (== 1) <$> c_mqtt_can_subscribe slot

-- | Get the number of active subscriptions.
subscriptionCount :: CInt -> IO Word32
subscriptionCount = c_mqtt_subscription_count

-- | Subscribe to a topic with the given QoS level.
subscribe :: CInt -> Ptr Word8 -> Word32 -> QoS -> IO (Either ProvenError ())
subscribe slot topicPtr topicLen qos =
  fromStatus <$> c_mqtt_subscribe slot topicPtr topicLen (qosToCode qos)

-- | Unsubscribe from a topic.
unsubscribe :: CInt -> Ptr Word8 -> Word32 -> IO (Either ProvenError ())
unsubscribe slot topicPtr topicLen =
  fromStatus <$> c_mqtt_unsubscribe slot topicPtr topicLen

-- | Publish a message to a topic.
publish :: CInt -> Ptr Word8 -> Word32 -> Ptr Word8 -> Word32 -> QoS -> Bool -> Word16 -> IO (Either ProvenError ())
publish slot topicPtr topicLen payloadPtr payloadLen qos retain packetId =
  fromStatus <$> c_mqtt_publish slot topicPtr topicLen payloadPtr payloadLen (qosToCode qos) (if retain then 1 else 0) packetId

-- | Acknowledge a QoS 1 publish (PUBACK).
puback :: CInt -> Word16 -> IO (Either ProvenError ())
puback slot packetId = fromStatus <$> c_mqtt_puback slot packetId

-- | QoS 2 step 1: publish received (PUBREC).
pubrec :: CInt -> Word16 -> IO (Either ProvenError ())
pubrec slot packetId = fromStatus <$> c_mqtt_pubrec slot packetId

-- | QoS 2 step 2: publish release (PUBREL).
pubrel :: CInt -> Word16 -> IO (Either ProvenError ())
pubrel slot packetId = fromStatus <$> c_mqtt_pubrel slot packetId

-- | QoS 2 step 3: publish complete (PUBCOMP).
pubcomp :: CInt -> Word16 -> IO (Either ProvenError ())
pubcomp slot packetId = fromStatus <$> c_mqtt_pubcomp slot packetId

-- | Get the QoS delivery state for a packet ID (ABI tag).
qosState :: CInt -> Word16 -> IO Word8
qosState = c_mqtt_qos_state

-- | Disconnect the session cleanly.
mqttDisconnect :: CInt -> IO (Either ProvenError ())
mqttDisconnect slot = fromStatus <$> c_mqtt_disconnect slot

-- | Clean up session resources.
cleanup :: CInt -> IO (Either ProvenError ())
cleanup slot = fromStatus <$> c_mqtt_cleanup slot

-- | Get the global retained message count.
retainedCount :: IO Word32
retainedCount = c_mqtt_retained_count

-- | Stateless query: check whether a session state transition is valid.
canTransition :: MqttSessionState -> MqttSessionState -> IO Bool
canTransition from to =
  (== 1) <$> c_mqtt_can_transition (mqttStateToTag from) (mqttStateToTag to)

-- | Stateless query: check whether a QoS delivery state transition is valid.
qosCanTransition :: QoS -> Word8 -> Word8 -> IO Bool
qosCanTransition qos from to =
  (== 1) <$> c_mqtt_qos_can_transition (qosToCode qos) from to

-- | Stateless query: check if a topic matches a subscription filter.
topicMatches :: Ptr Word8 -> Word32 -> Ptr Word8 -> Word32 -> IO Bool
topicMatches filterPtr filterLen topicPtr topicLen =
  (== 1) <$> c_mqtt_topic_matches filterPtr filterLen topicPtr topicLen
