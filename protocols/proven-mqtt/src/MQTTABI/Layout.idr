-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- MQTTABI.Layout: C-ABI-compatible numeric representations of MQTT types.
--
-- Maps every constructor of the core MQTT sum types to fixed Bits8 values
-- for C interop.  Each type gets a total encoder, partial decoder, and
-- roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/mqtt.h) and the
-- Zig FFI enums (ffi/zig/src/mqtt.zig) exactly.
--
-- Types covered:
--   PacketType       (15 constructors, tags 0-14)
--   QoS              (3 constructors, tags 0-2)
--   ConnAckCode      (6 constructors, tags 0-5)
--   MQTTVersion      (2 constructors, tags 0-1)
--   BrokerState      (5 constructors, tags 0-4)
--   QoSDeliveryState (7 constructors, tags 0-6)
--   PropertyType     (10 constructors, tags 0-9)
--   PacketDirection  (3 constructors, tags 0-2)
--   SubAckCode       (4 constructors, tags 0-3)

module MQTTABI.Layout

import MQTT.PacketType
import MQTT.QoS
import MQTT.Session

%default total

---------------------------------------------------------------------------
-- PacketType (15 constructors, tags 0-14)
---------------------------------------------------------------------------

public export
packetTypeSize : Nat
packetTypeSize = 1

||| Encode a PacketType to its ABI tag value.
||| Note: these are sequential 0-14, distinct from the MQTT wire codes (1-14).
public export
packetTypeToTag : PacketType -> Bits8
packetTypeToTag CONNECT     = 0
packetTypeToTag CONNACK     = 1
packetTypeToTag PUBLISH     = 2
packetTypeToTag PUBACK      = 3
packetTypeToTag PUBREC      = 4
packetTypeToTag PUBREL      = 5
packetTypeToTag PUBCOMP     = 6
packetTypeToTag SUBSCRIBE   = 7
packetTypeToTag SUBACK      = 8
packetTypeToTag UNSUBSCRIBE = 9
packetTypeToTag UNSUBACK    = 10
packetTypeToTag PINGREQ     = 11
packetTypeToTag PINGRESP    = 12
packetTypeToTag DISCONNECT  = 13
packetTypeToTag AUTH        = 14

public export
tagToPacketType : Bits8 -> Maybe PacketType
tagToPacketType 0  = Just CONNECT
tagToPacketType 1  = Just CONNACK
tagToPacketType 2  = Just PUBLISH
tagToPacketType 3  = Just PUBACK
tagToPacketType 4  = Just PUBREC
tagToPacketType 5  = Just PUBREL
tagToPacketType 6  = Just PUBCOMP
tagToPacketType 7  = Just SUBSCRIBE
tagToPacketType 8  = Just SUBACK
tagToPacketType 9  = Just UNSUBSCRIBE
tagToPacketType 10 = Just UNSUBACK
tagToPacketType 11 = Just PINGREQ
tagToPacketType 12 = Just PINGRESP
tagToPacketType 13 = Just DISCONNECT
tagToPacketType 14 = Just AUTH
tagToPacketType _  = Nothing

public export
packetTypeRoundtrip : (p : PacketType) -> tagToPacketType (packetTypeToTag p) = Just p
packetTypeRoundtrip CONNECT     = Refl
packetTypeRoundtrip CONNACK     = Refl
packetTypeRoundtrip PUBLISH     = Refl
packetTypeRoundtrip PUBACK      = Refl
packetTypeRoundtrip PUBREC      = Refl
packetTypeRoundtrip PUBREL      = Refl
packetTypeRoundtrip PUBCOMP     = Refl
packetTypeRoundtrip SUBSCRIBE   = Refl
packetTypeRoundtrip SUBACK      = Refl
packetTypeRoundtrip UNSUBSCRIBE = Refl
packetTypeRoundtrip UNSUBACK    = Refl
packetTypeRoundtrip PINGREQ     = Refl
packetTypeRoundtrip PINGRESP    = Refl
packetTypeRoundtrip DISCONNECT  = Refl
packetTypeRoundtrip AUTH        = Refl

---------------------------------------------------------------------------
-- QoS (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
qosSize : Nat
qosSize = 1

public export
qosToTag : QoS -> Bits8
qosToTag AtMostOnce  = 0
qosToTag AtLeastOnce = 1
qosToTag ExactlyOnce = 2

public export
tagToQoS : Bits8 -> Maybe QoS
tagToQoS 0 = Just AtMostOnce
tagToQoS 1 = Just AtLeastOnce
tagToQoS 2 = Just ExactlyOnce
tagToQoS _ = Nothing

public export
qosRoundtrip : (q : QoS) -> tagToQoS (qosToTag q) = Just q
qosRoundtrip AtMostOnce  = Refl
qosRoundtrip AtLeastOnce = Refl
qosRoundtrip ExactlyOnce = Refl

---------------------------------------------------------------------------
-- ConnAckCode (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
connAckCodeSize : Nat
connAckCodeSize = 1

public export
connAckCodeToTag : ConnAckCode -> Bits8
connAckCodeToTag ConnectionAccepted   = 0
connAckCodeToTag UnacceptableProtocol = 1
connAckCodeToTag IdentifierRejected   = 2
connAckCodeToTag ServerUnavailable    = 3
connAckCodeToTag BadCredentials       = 4
connAckCodeToTag NotAuthorised        = 5

public export
tagToConnAckCode : Bits8 -> Maybe ConnAckCode
tagToConnAckCode 0 = Just ConnectionAccepted
tagToConnAckCode 1 = Just UnacceptableProtocol
tagToConnAckCode 2 = Just IdentifierRejected
tagToConnAckCode 3 = Just ServerUnavailable
tagToConnAckCode 4 = Just BadCredentials
tagToConnAckCode 5 = Just NotAuthorised
tagToConnAckCode _ = Nothing

public export
connAckCodeRoundtrip : (c : ConnAckCode) -> tagToConnAckCode (connAckCodeToTag c) = Just c
connAckCodeRoundtrip ConnectionAccepted   = Refl
connAckCodeRoundtrip UnacceptableProtocol = Refl
connAckCodeRoundtrip IdentifierRejected   = Refl
connAckCodeRoundtrip ServerUnavailable    = Refl
connAckCodeRoundtrip BadCredentials       = Refl
connAckCodeRoundtrip NotAuthorised        = Refl

---------------------------------------------------------------------------
-- MQTTVersion (2 constructors, tags 0-1)
---------------------------------------------------------------------------

||| MQTT protocol versions supported by the ABI.
public export
data MQTTVersion : Type where
  ||| MQTT 3.1.1 (protocol level 4).
  MQTT311 : MQTTVersion
  ||| MQTT 5.0 (protocol level 5).
  MQTT50  : MQTTVersion

public export
Eq MQTTVersion where
  MQTT311 == MQTT311 = True
  MQTT50  == MQTT50  = True
  _       == _       = False

public export
Show MQTTVersion where
  show MQTT311 = "MQTT 3.1.1"
  show MQTT50  = "MQTT 5.0"

public export
mqttVersionSize : Nat
mqttVersionSize = 1

public export
mqttVersionToTag : MQTTVersion -> Bits8
mqttVersionToTag MQTT311 = 0
mqttVersionToTag MQTT50  = 1

public export
tagToMqttVersion : Bits8 -> Maybe MQTTVersion
tagToMqttVersion 0 = Just MQTT311
tagToMqttVersion 1 = Just MQTT50
tagToMqttVersion _ = Nothing

public export
mqttVersionRoundtrip : (v : MQTTVersion) -> tagToMqttVersion (mqttVersionToTag v) = Just v
mqttVersionRoundtrip MQTT311 = Refl
mqttVersionRoundtrip MQTT50  = Refl

---------------------------------------------------------------------------
-- BrokerState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

||| Broker-side session lifecycle states.
||| The GADT in Transitions.idr uses these as indices.
public export
data BrokerState : Type where
  ||| No client connected. Initial and terminal state.
  Idle          : BrokerState
  ||| Client connected, CONNACK sent, ready for operations.
  Connected     : BrokerState
  ||| Client has active subscriptions and may receive forwarded messages.
  Subscribed    : BrokerState
  ||| Client is actively publishing (in-flight QoS acknowledgement pending).
  Publishing    : BrokerState
  ||| Client sent DISCONNECT or connection dropped, cleaning up.
  Disconnecting : BrokerState

public export
Eq BrokerState where
  Idle          == Idle          = True
  Connected     == Connected     = True
  Subscribed    == Subscribed    = True
  Publishing    == Publishing    = True
  Disconnecting == Disconnecting = True
  _             == _             = False

public export
Show BrokerState where
  show Idle          = "Idle"
  show Connected     = "Connected"
  show Subscribed    = "Subscribed"
  show Publishing    = "Publishing"
  show Disconnecting = "Disconnecting"

public export
brokerStateSize : Nat
brokerStateSize = 1

public export
brokerStateToTag : BrokerState -> Bits8
brokerStateToTag Idle          = 0
brokerStateToTag Connected     = 1
brokerStateToTag Subscribed    = 2
brokerStateToTag Publishing    = 3
brokerStateToTag Disconnecting = 4

public export
tagToBrokerState : Bits8 -> Maybe BrokerState
tagToBrokerState 0 = Just Idle
tagToBrokerState 1 = Just Connected
tagToBrokerState 2 = Just Subscribed
tagToBrokerState 3 = Just Publishing
tagToBrokerState 4 = Just Disconnecting
tagToBrokerState _ = Nothing

public export
brokerStateRoundtrip : (s : BrokerState) -> tagToBrokerState (brokerStateToTag s) = Just s
brokerStateRoundtrip Idle          = Refl
brokerStateRoundtrip Connected     = Refl
brokerStateRoundtrip Subscribed    = Refl
brokerStateRoundtrip Publishing    = Refl
brokerStateRoundtrip Disconnecting = Refl

---------------------------------------------------------------------------
-- QoSDeliveryState (7 constructors, tags 0-6)
---------------------------------------------------------------------------

||| States within a QoS delivery flow.
||| QoS 0: only Idle and Complete are used.
||| QoS 1: Idle -> AwaitingPubAck -> Complete.
||| QoS 2: Idle -> AwaitingPubRec -> AwaitingPubRel -> AwaitingPubComp -> Complete.
||| Failed is reachable from any non-terminal state on timeout or error.
public export
data QoSDeliveryState : Type where
  ||| No delivery in progress.
  QDIdle           : QoSDeliveryState
  ||| PUBLISH sent, awaiting PUBACK (QoS 1).
  AwaitingPubAck   : QoSDeliveryState
  ||| PUBLISH sent, awaiting PUBREC (QoS 2, step 1).
  AwaitingPubRec   : QoSDeliveryState
  ||| PUBREC received, awaiting PUBREL (QoS 2, step 2).
  AwaitingPubRel   : QoSDeliveryState
  ||| PUBREL sent, awaiting PUBCOMP (QoS 2, step 3).
  AwaitingPubComp  : QoSDeliveryState
  ||| Delivery completed successfully.
  QDComplete       : QoSDeliveryState
  ||| Delivery failed (timeout, disconnect, or protocol error).
  QDFailed         : QoSDeliveryState

public export
Eq QoSDeliveryState where
  QDIdle          == QDIdle          = True
  AwaitingPubAck  == AwaitingPubAck  = True
  AwaitingPubRec  == AwaitingPubRec  = True
  AwaitingPubRel  == AwaitingPubRel  = True
  AwaitingPubComp == AwaitingPubComp = True
  QDComplete      == QDComplete      = True
  QDFailed        == QDFailed        = True
  _               == _               = False

public export
Show QoSDeliveryState where
  show QDIdle          = "Idle"
  show AwaitingPubAck  = "AwaitingPubAck"
  show AwaitingPubRec  = "AwaitingPubRec"
  show AwaitingPubRel  = "AwaitingPubRel"
  show AwaitingPubComp = "AwaitingPubComp"
  show QDComplete      = "Complete"
  show QDFailed        = "Failed"

public export
qosDeliveryStateSize : Nat
qosDeliveryStateSize = 1

public export
qosDeliveryStateToTag : QoSDeliveryState -> Bits8
qosDeliveryStateToTag QDIdle          = 0
qosDeliveryStateToTag AwaitingPubAck  = 1
qosDeliveryStateToTag AwaitingPubRec  = 2
qosDeliveryStateToTag AwaitingPubRel  = 3
qosDeliveryStateToTag AwaitingPubComp = 4
qosDeliveryStateToTag QDComplete      = 5
qosDeliveryStateToTag QDFailed        = 6

public export
tagToQoSDeliveryState : Bits8 -> Maybe QoSDeliveryState
tagToQoSDeliveryState 0 = Just QDIdle
tagToQoSDeliveryState 1 = Just AwaitingPubAck
tagToQoSDeliveryState 2 = Just AwaitingPubRec
tagToQoSDeliveryState 3 = Just AwaitingPubRel
tagToQoSDeliveryState 4 = Just AwaitingPubComp
tagToQoSDeliveryState 5 = Just QDComplete
tagToQoSDeliveryState 6 = Just QDFailed
tagToQoSDeliveryState _ = Nothing

public export
qosDeliveryStateRoundtrip : (s : QoSDeliveryState) -> tagToQoSDeliveryState (qosDeliveryStateToTag s) = Just s
qosDeliveryStateRoundtrip QDIdle          = Refl
qosDeliveryStateRoundtrip AwaitingPubAck  = Refl
qosDeliveryStateRoundtrip AwaitingPubRec  = Refl
qosDeliveryStateRoundtrip AwaitingPubRel  = Refl
qosDeliveryStateRoundtrip AwaitingPubComp = Refl
qosDeliveryStateRoundtrip QDComplete      = Refl
qosDeliveryStateRoundtrip QDFailed        = Refl

---------------------------------------------------------------------------
-- PropertyType (MQTTv5 property identifiers, 10 constructors, tags 0-9)
---------------------------------------------------------------------------

||| MQTTv5 property types used in variable headers and payloads.
||| These are the ABI tags, not the MQTT wire property identifiers.
public export
data PropertyType : Type where
  ||| Session Expiry Interval (MQTTv5 0x11).
  SessionExpiryInterval   : PropertyType
  ||| Receive Maximum (MQTTv5 0x21).
  ReceiveMaximum          : PropertyType
  ||| Maximum QoS (MQTTv5 0x24).
  MaximumQoS              : PropertyType
  ||| Retain Available (MQTTv5 0x25).
  RetainAvailable         : PropertyType
  ||| Maximum Packet Size (MQTTv5 0x27).
  MaximumPacketSize       : PropertyType
  ||| Topic Alias Maximum (MQTTv5 0x22).
  TopicAliasMaximum       : PropertyType
  ||| Wildcard Subscription Available (MQTTv5 0x28).
  WildcardSubAvailable    : PropertyType
  ||| Subscription Identifiers Available (MQTTv5 0x29).
  SubIdAvailable          : PropertyType
  ||| Shared Subscription Available (MQTTv5 0x2A).
  SharedSubAvailable      : PropertyType
  ||| Keep Alive Server (MQTTv5 0x13).
  ServerKeepAlive         : PropertyType

public export
Eq PropertyType where
  SessionExpiryInterval == SessionExpiryInterval = True
  ReceiveMaximum        == ReceiveMaximum        = True
  MaximumQoS            == MaximumQoS            = True
  RetainAvailable       == RetainAvailable       = True
  MaximumPacketSize     == MaximumPacketSize     = True
  TopicAliasMaximum     == TopicAliasMaximum     = True
  WildcardSubAvailable  == WildcardSubAvailable  = True
  SubIdAvailable        == SubIdAvailable        = True
  SharedSubAvailable    == SharedSubAvailable    = True
  ServerKeepAlive       == ServerKeepAlive       = True
  _                     == _                     = False

public export
Show PropertyType where
  show SessionExpiryInterval = "SessionExpiryInterval"
  show ReceiveMaximum        = "ReceiveMaximum"
  show MaximumQoS            = "MaximumQoS"
  show RetainAvailable       = "RetainAvailable"
  show MaximumPacketSize     = "MaximumPacketSize"
  show TopicAliasMaximum     = "TopicAliasMaximum"
  show WildcardSubAvailable  = "WildcardSubAvailable"
  show SubIdAvailable        = "SubIdAvailable"
  show SharedSubAvailable    = "SharedSubAvailable"
  show ServerKeepAlive       = "ServerKeepAlive"

public export
propertyTypeSize : Nat
propertyTypeSize = 1

public export
propertyTypeToTag : PropertyType -> Bits8
propertyTypeToTag SessionExpiryInterval = 0
propertyTypeToTag ReceiveMaximum        = 1
propertyTypeToTag MaximumQoS            = 2
propertyTypeToTag RetainAvailable       = 3
propertyTypeToTag MaximumPacketSize     = 4
propertyTypeToTag TopicAliasMaximum     = 5
propertyTypeToTag WildcardSubAvailable  = 6
propertyTypeToTag SubIdAvailable        = 7
propertyTypeToTag SharedSubAvailable    = 8
propertyTypeToTag ServerKeepAlive       = 9

public export
tagToPropertyType : Bits8 -> Maybe PropertyType
tagToPropertyType 0 = Just SessionExpiryInterval
tagToPropertyType 1 = Just ReceiveMaximum
tagToPropertyType 2 = Just MaximumQoS
tagToPropertyType 3 = Just RetainAvailable
tagToPropertyType 4 = Just MaximumPacketSize
tagToPropertyType 5 = Just TopicAliasMaximum
tagToPropertyType 6 = Just WildcardSubAvailable
tagToPropertyType 7 = Just SubIdAvailable
tagToPropertyType 8 = Just SharedSubAvailable
tagToPropertyType 9 = Just ServerKeepAlive
tagToPropertyType _ = Nothing

public export
propertyTypeRoundtrip : (p : PropertyType) -> tagToPropertyType (propertyTypeToTag p) = Just p
propertyTypeRoundtrip SessionExpiryInterval = Refl
propertyTypeRoundtrip ReceiveMaximum        = Refl
propertyTypeRoundtrip MaximumQoS            = Refl
propertyTypeRoundtrip RetainAvailable       = Refl
propertyTypeRoundtrip MaximumPacketSize     = Refl
propertyTypeRoundtrip TopicAliasMaximum     = Refl
propertyTypeRoundtrip WildcardSubAvailable  = Refl
propertyTypeRoundtrip SubIdAvailable        = Refl
propertyTypeRoundtrip SharedSubAvailable    = Refl
propertyTypeRoundtrip ServerKeepAlive       = Refl

---------------------------------------------------------------------------
-- PacketDirection (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
packetDirectionSize : Nat
packetDirectionSize = 1

public export
packetDirectionToTag : PacketDirection -> Bits8
packetDirectionToTag ClientToServer = 0
packetDirectionToTag ServerToClient = 1
packetDirectionToTag Bidirectional  = 2

public export
tagToPacketDirection : Bits8 -> Maybe PacketDirection
tagToPacketDirection 0 = Just ClientToServer
tagToPacketDirection 1 = Just ServerToClient
tagToPacketDirection 2 = Just Bidirectional
tagToPacketDirection _ = Nothing

public export
packetDirectionRoundtrip : (d : PacketDirection) -> tagToPacketDirection (packetDirectionToTag d) = Just d
packetDirectionRoundtrip ClientToServer = Refl
packetDirectionRoundtrip ServerToClient = Refl
packetDirectionRoundtrip Bidirectional  = Refl

---------------------------------------------------------------------------
-- SubAckCode (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
subAckCodeSize : Nat
subAckCodeSize = 1

public export
subAckCodeToTag : SubAckCode -> Bits8
subAckCodeToTag GrantedQoS0 = 0
subAckCodeToTag GrantedQoS1 = 1
subAckCodeToTag GrantedQoS2 = 2
subAckCodeToTag SubFailure  = 3

public export
tagToSubAckCode : Bits8 -> Maybe SubAckCode
tagToSubAckCode 0 = Just GrantedQoS0
tagToSubAckCode 1 = Just GrantedQoS1
tagToSubAckCode 2 = Just GrantedQoS2
tagToSubAckCode 3 = Just SubFailure
tagToSubAckCode _ = Nothing

public export
subAckCodeRoundtrip : (s : SubAckCode) -> tagToSubAckCode (subAckCodeToTag s) = Just s
subAckCodeRoundtrip GrantedQoS0 = Refl
subAckCodeRoundtrip GrantedQoS1 = Refl
subAckCodeRoundtrip GrantedQoS2 = Refl
subAckCodeRoundtrip SubFailure  = Refl
