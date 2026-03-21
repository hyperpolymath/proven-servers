-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- MqttABI.Types: C-ABI-compatible numeric representations of Mqtt types.
--
-- Maps every constructor of the core Mqtt sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/mqtt.zig) exactly.
--
-- Types covered:
--   PacketType                (15 constructors, tags 0-14)
--   QoS                       (3 constructors, tags 0-2)
--   ConnAckCode               (6 constructors, tags 0-5)
--   MQTTVersion               (2 constructors, tags 0-1)
--   BrokerState               (5 constructors, tags 0-4)
--   QoSDeliveryState          (7 constructors, tags 0-6)
--   PropertyType              (10 constructors, tags 0-9)
--   PacketDirection           (3 constructors, tags 0-2)
--   SubAckCode                (4 constructors, tags 0-3)

module MqttABI.Types

%default total

---------------------------------------------------------------------------
-- PacketType (15 constructors, tags 0-14)
---------------------------------------------------------------------------

public export
packet_typeSize : Nat
packet_typeSize = 1

||| PacketType sum type for ABI encoding.
public export
data PacketType : Type where
  Connect : PacketType
  Connack : PacketType
  Publish : PacketType
  Puback : PacketType
  Pubrec : PacketType
  Pubrel : PacketType
  Pubcomp : PacketType
  Subscribe : PacketType
  Suback : PacketType
  Unsubscribe : PacketType
  Unsuback : PacketType
  Pingreq : PacketType
  Pingresp : PacketType
  Disconnect : PacketType
  Auth : PacketType

||| Encode a PacketType to its ABI tag value.
public export
packet_typeToTag : PacketType -> Bits8
packet_typeToTag Connect = 0
packet_typeToTag Connack = 1
packet_typeToTag Publish = 2
packet_typeToTag Puback = 3
packet_typeToTag Pubrec = 4
packet_typeToTag Pubrel = 5
packet_typeToTag Pubcomp = 6
packet_typeToTag Subscribe = 7
packet_typeToTag Suback = 8
packet_typeToTag Unsubscribe = 9
packet_typeToTag Unsuback = 10
packet_typeToTag Pingreq = 11
packet_typeToTag Pingresp = 12
packet_typeToTag Disconnect = 13
packet_typeToTag Auth = 14

||| Decode an ABI tag to a PacketType.
public export
tagToPacketType : Bits8 -> Maybe PacketType
tagToPacketType 0 = Just Connect
tagToPacketType 1 = Just Connack
tagToPacketType 2 = Just Publish
tagToPacketType 3 = Just Puback
tagToPacketType 4 = Just Pubrec
tagToPacketType 5 = Just Pubrel
tagToPacketType 6 = Just Pubcomp
tagToPacketType 7 = Just Subscribe
tagToPacketType 8 = Just Suback
tagToPacketType 9 = Just Unsubscribe
tagToPacketType 10 = Just Unsuback
tagToPacketType 11 = Just Pingreq
tagToPacketType 12 = Just Pingresp
tagToPacketType 13 = Just Disconnect
tagToPacketType 14 = Just Auth
tagToPacketType _ = Nothing

||| Roundtrip proof: decoding an encoded PacketType yields the original.
public export
packet_typeRoundtrip : (x : PacketType) -> tagToPacketType (packet_typeToTag x) = Just x
packet_typeRoundtrip Connect = Refl
packet_typeRoundtrip Connack = Refl
packet_typeRoundtrip Publish = Refl
packet_typeRoundtrip Puback = Refl
packet_typeRoundtrip Pubrec = Refl
packet_typeRoundtrip Pubrel = Refl
packet_typeRoundtrip Pubcomp = Refl
packet_typeRoundtrip Subscribe = Refl
packet_typeRoundtrip Suback = Refl
packet_typeRoundtrip Unsubscribe = Refl
packet_typeRoundtrip Unsuback = Refl
packet_typeRoundtrip Pingreq = Refl
packet_typeRoundtrip Pingresp = Refl
packet_typeRoundtrip Disconnect = Refl
packet_typeRoundtrip Auth = Refl

---------------------------------------------------------------------------
-- QoS (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
qo_sSize : Nat
qo_sSize = 1

||| QoS sum type for ABI encoding.
public export
data QoS : Type where
  AtMostOnce : QoS
  AtLeastOnce : QoS
  ExactlyOnce : QoS

||| Encode a QoS to its ABI tag value.
public export
qo_sToTag : QoS -> Bits8
qo_sToTag AtMostOnce = 0
qo_sToTag AtLeastOnce = 1
qo_sToTag ExactlyOnce = 2

||| Decode an ABI tag to a QoS.
public export
tagToQoS : Bits8 -> Maybe QoS
tagToQoS 0 = Just AtMostOnce
tagToQoS 1 = Just AtLeastOnce
tagToQoS 2 = Just ExactlyOnce
tagToQoS _ = Nothing

||| Roundtrip proof: decoding an encoded QoS yields the original.
public export
qo_sRoundtrip : (x : QoS) -> tagToQoS (qo_sToTag x) = Just x
qo_sRoundtrip AtMostOnce = Refl
qo_sRoundtrip AtLeastOnce = Refl
qo_sRoundtrip ExactlyOnce = Refl

---------------------------------------------------------------------------
-- ConnAckCode (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
conn_ack_codeSize : Nat
conn_ack_codeSize = 1

||| ConnAckCode sum type for ABI encoding.
public export
data ConnAckCode : Type where
  ConnectionAccepted : ConnAckCode
  UnacceptableProtocol : ConnAckCode
  IdentifierRejected : ConnAckCode
  ServerUnavailable : ConnAckCode
  BadCredentials : ConnAckCode
  NotAuthorised : ConnAckCode

||| Encode a ConnAckCode to its ABI tag value.
public export
conn_ack_codeToTag : ConnAckCode -> Bits8
conn_ack_codeToTag ConnectionAccepted = 0
conn_ack_codeToTag UnacceptableProtocol = 1
conn_ack_codeToTag IdentifierRejected = 2
conn_ack_codeToTag ServerUnavailable = 3
conn_ack_codeToTag BadCredentials = 4
conn_ack_codeToTag NotAuthorised = 5

||| Decode an ABI tag to a ConnAckCode.
public export
tagToConnAckCode : Bits8 -> Maybe ConnAckCode
tagToConnAckCode 0 = Just ConnectionAccepted
tagToConnAckCode 1 = Just UnacceptableProtocol
tagToConnAckCode 2 = Just IdentifierRejected
tagToConnAckCode 3 = Just ServerUnavailable
tagToConnAckCode 4 = Just BadCredentials
tagToConnAckCode 5 = Just NotAuthorised
tagToConnAckCode _ = Nothing

||| Roundtrip proof: decoding an encoded ConnAckCode yields the original.
public export
conn_ack_codeRoundtrip : (x : ConnAckCode) -> tagToConnAckCode (conn_ack_codeToTag x) = Just x
conn_ack_codeRoundtrip ConnectionAccepted = Refl
conn_ack_codeRoundtrip UnacceptableProtocol = Refl
conn_ack_codeRoundtrip IdentifierRejected = Refl
conn_ack_codeRoundtrip ServerUnavailable = Refl
conn_ack_codeRoundtrip BadCredentials = Refl
conn_ack_codeRoundtrip NotAuthorised = Refl

---------------------------------------------------------------------------
-- MQTTVersion (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
m_q_t_t_versionSize : Nat
m_q_t_t_versionSize = 1

||| MQTTVersion sum type for ABI encoding.
public export
data MQTTVersion : Type where
  Mqtt311 : MQTTVersion
  Mqtt50 : MQTTVersion

||| Encode a MQTTVersion to its ABI tag value.
public export
m_q_t_t_versionToTag : MQTTVersion -> Bits8
m_q_t_t_versionToTag Mqtt311 = 0
m_q_t_t_versionToTag Mqtt50 = 1

||| Decode an ABI tag to a MQTTVersion.
public export
tagToMQTTVersion : Bits8 -> Maybe MQTTVersion
tagToMQTTVersion 0 = Just Mqtt311
tagToMQTTVersion 1 = Just Mqtt50
tagToMQTTVersion _ = Nothing

||| Roundtrip proof: decoding an encoded MQTTVersion yields the original.
public export
m_q_t_t_versionRoundtrip : (x : MQTTVersion) -> tagToMQTTVersion (m_q_t_t_versionToTag x) = Just x
m_q_t_t_versionRoundtrip Mqtt311 = Refl
m_q_t_t_versionRoundtrip Mqtt50 = Refl

---------------------------------------------------------------------------
-- BrokerState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
broker_stateSize : Nat
broker_stateSize = 1

||| BrokerState sum type for ABI encoding.
public export
data BrokerState : Type where
  Idle : BrokerState
  Connected : BrokerState
  Subscribed : BrokerState
  Publishing : BrokerState
  Disconnecting : BrokerState

||| Encode a BrokerState to its ABI tag value.
public export
broker_stateToTag : BrokerState -> Bits8
broker_stateToTag Idle = 0
broker_stateToTag Connected = 1
broker_stateToTag Subscribed = 2
broker_stateToTag Publishing = 3
broker_stateToTag Disconnecting = 4

||| Decode an ABI tag to a BrokerState.
public export
tagToBrokerState : Bits8 -> Maybe BrokerState
tagToBrokerState 0 = Just Idle
tagToBrokerState 1 = Just Connected
tagToBrokerState 2 = Just Subscribed
tagToBrokerState 3 = Just Publishing
tagToBrokerState 4 = Just Disconnecting
tagToBrokerState _ = Nothing

||| Roundtrip proof: decoding an encoded BrokerState yields the original.
public export
broker_stateRoundtrip : (x : BrokerState) -> tagToBrokerState (broker_stateToTag x) = Just x
broker_stateRoundtrip Idle = Refl
broker_stateRoundtrip Connected = Refl
broker_stateRoundtrip Subscribed = Refl
broker_stateRoundtrip Publishing = Refl
broker_stateRoundtrip Disconnecting = Refl

---------------------------------------------------------------------------
-- QoSDeliveryState (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
qo_s_delivery_stateSize : Nat
qo_s_delivery_stateSize = 1

||| QoSDeliveryState sum type for ABI encoding.
public export
data QoSDeliveryState : Type where
  QdIdle : QoSDeliveryState
  AwaitingPuback : QoSDeliveryState
  AwaitingPubrec : QoSDeliveryState
  AwaitingPubrel : QoSDeliveryState
  AwaitingPubcomp : QoSDeliveryState
  QdComplete : QoSDeliveryState
  QdFailed : QoSDeliveryState

||| Encode a QoSDeliveryState to its ABI tag value.
public export
qo_s_delivery_stateToTag : QoSDeliveryState -> Bits8
qo_s_delivery_stateToTag QdIdle = 0
qo_s_delivery_stateToTag AwaitingPuback = 1
qo_s_delivery_stateToTag AwaitingPubrec = 2
qo_s_delivery_stateToTag AwaitingPubrel = 3
qo_s_delivery_stateToTag AwaitingPubcomp = 4
qo_s_delivery_stateToTag QdComplete = 5
qo_s_delivery_stateToTag QdFailed = 6

||| Decode an ABI tag to a QoSDeliveryState.
public export
tagToQoSDeliveryState : Bits8 -> Maybe QoSDeliveryState
tagToQoSDeliveryState 0 = Just QdIdle
tagToQoSDeliveryState 1 = Just AwaitingPuback
tagToQoSDeliveryState 2 = Just AwaitingPubrec
tagToQoSDeliveryState 3 = Just AwaitingPubrel
tagToQoSDeliveryState 4 = Just AwaitingPubcomp
tagToQoSDeliveryState 5 = Just QdComplete
tagToQoSDeliveryState 6 = Just QdFailed
tagToQoSDeliveryState _ = Nothing

||| Roundtrip proof: decoding an encoded QoSDeliveryState yields the original.
public export
qo_s_delivery_stateRoundtrip : (x : QoSDeliveryState) -> tagToQoSDeliveryState (qo_s_delivery_stateToTag x) = Just x
qo_s_delivery_stateRoundtrip QdIdle = Refl
qo_s_delivery_stateRoundtrip AwaitingPuback = Refl
qo_s_delivery_stateRoundtrip AwaitingPubrec = Refl
qo_s_delivery_stateRoundtrip AwaitingPubrel = Refl
qo_s_delivery_stateRoundtrip AwaitingPubcomp = Refl
qo_s_delivery_stateRoundtrip QdComplete = Refl
qo_s_delivery_stateRoundtrip QdFailed = Refl

---------------------------------------------------------------------------
-- PropertyType (10 constructors, tags 0-9)
---------------------------------------------------------------------------

public export
property_typeSize : Nat
property_typeSize = 1

||| PropertyType sum type for ABI encoding.
public export
data PropertyType : Type where
  SessionExpiryInterval : PropertyType
  ReceiveMaximum : PropertyType
  MaximumQos : PropertyType
  RetainAvailable : PropertyType
  MaximumPacketSize : PropertyType
  TopicAliasMaximum : PropertyType
  WildcardSubAvailable : PropertyType
  SubIdAvailable : PropertyType
  SharedSubAvailable : PropertyType
  ServerKeepAlive : PropertyType

||| Encode a PropertyType to its ABI tag value.
public export
property_typeToTag : PropertyType -> Bits8
property_typeToTag SessionExpiryInterval = 0
property_typeToTag ReceiveMaximum = 1
property_typeToTag MaximumQos = 2
property_typeToTag RetainAvailable = 3
property_typeToTag MaximumPacketSize = 4
property_typeToTag TopicAliasMaximum = 5
property_typeToTag WildcardSubAvailable = 6
property_typeToTag SubIdAvailable = 7
property_typeToTag SharedSubAvailable = 8
property_typeToTag ServerKeepAlive = 9

||| Decode an ABI tag to a PropertyType.
public export
tagToPropertyType : Bits8 -> Maybe PropertyType
tagToPropertyType 0 = Just SessionExpiryInterval
tagToPropertyType 1 = Just ReceiveMaximum
tagToPropertyType 2 = Just MaximumQos
tagToPropertyType 3 = Just RetainAvailable
tagToPropertyType 4 = Just MaximumPacketSize
tagToPropertyType 5 = Just TopicAliasMaximum
tagToPropertyType 6 = Just WildcardSubAvailable
tagToPropertyType 7 = Just SubIdAvailable
tagToPropertyType 8 = Just SharedSubAvailable
tagToPropertyType 9 = Just ServerKeepAlive
tagToPropertyType _ = Nothing

||| Roundtrip proof: decoding an encoded PropertyType yields the original.
public export
property_typeRoundtrip : (x : PropertyType) -> tagToPropertyType (property_typeToTag x) = Just x
property_typeRoundtrip SessionExpiryInterval = Refl
property_typeRoundtrip ReceiveMaximum = Refl
property_typeRoundtrip MaximumQos = Refl
property_typeRoundtrip RetainAvailable = Refl
property_typeRoundtrip MaximumPacketSize = Refl
property_typeRoundtrip TopicAliasMaximum = Refl
property_typeRoundtrip WildcardSubAvailable = Refl
property_typeRoundtrip SubIdAvailable = Refl
property_typeRoundtrip SharedSubAvailable = Refl
property_typeRoundtrip ServerKeepAlive = Refl

---------------------------------------------------------------------------
-- PacketDirection (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
packet_directionSize : Nat
packet_directionSize = 1

||| PacketDirection sum type for ABI encoding.
public export
data PacketDirection : Type where
  ClientToServer : PacketDirection
  ServerToClient : PacketDirection
  Bidirectional : PacketDirection

||| Encode a PacketDirection to its ABI tag value.
public export
packet_directionToTag : PacketDirection -> Bits8
packet_directionToTag ClientToServer = 0
packet_directionToTag ServerToClient = 1
packet_directionToTag Bidirectional = 2

||| Decode an ABI tag to a PacketDirection.
public export
tagToPacketDirection : Bits8 -> Maybe PacketDirection
tagToPacketDirection 0 = Just ClientToServer
tagToPacketDirection 1 = Just ServerToClient
tagToPacketDirection 2 = Just Bidirectional
tagToPacketDirection _ = Nothing

||| Roundtrip proof: decoding an encoded PacketDirection yields the original.
public export
packet_directionRoundtrip : (x : PacketDirection) -> tagToPacketDirection (packet_directionToTag x) = Just x
packet_directionRoundtrip ClientToServer = Refl
packet_directionRoundtrip ServerToClient = Refl
packet_directionRoundtrip Bidirectional = Refl

---------------------------------------------------------------------------
-- SubAckCode (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
sub_ack_codeSize : Nat
sub_ack_codeSize = 1

||| SubAckCode sum type for ABI encoding.
public export
data SubAckCode : Type where
  GrantedQos0 : SubAckCode
  GrantedQos1 : SubAckCode
  GrantedQos2 : SubAckCode
  SubFailure : SubAckCode

||| Encode a SubAckCode to its ABI tag value.
public export
sub_ack_codeToTag : SubAckCode -> Bits8
sub_ack_codeToTag GrantedQos0 = 0
sub_ack_codeToTag GrantedQos1 = 1
sub_ack_codeToTag GrantedQos2 = 2
sub_ack_codeToTag SubFailure = 3

||| Decode an ABI tag to a SubAckCode.
public export
tagToSubAckCode : Bits8 -> Maybe SubAckCode
tagToSubAckCode 0 = Just GrantedQos0
tagToSubAckCode 1 = Just GrantedQos1
tagToSubAckCode 2 = Just GrantedQos2
tagToSubAckCode 3 = Just SubFailure
tagToSubAckCode _ = Nothing

||| Roundtrip proof: decoding an encoded SubAckCode yields the original.
public export
sub_ack_codeRoundtrip : (x : SubAckCode) -> tagToSubAckCode (sub_ack_codeToTag x) = Just x
sub_ack_codeRoundtrip GrantedQos0 = Refl
sub_ack_codeRoundtrip GrantedQos1 = Refl
sub_ack_codeRoundtrip GrantedQos2 = Refl
sub_ack_codeRoundtrip SubFailure = Refl
