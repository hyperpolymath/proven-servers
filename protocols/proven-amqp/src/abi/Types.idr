-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- AmqpABI.Types: C-ABI-compatible numeric representations of Amqp types.
--
-- Maps every constructor of the core Amqp sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/amqp.zig) exactly.
--
-- Types covered:
--   FrameType                 (4 constructors, tags 0-3)
--   MethodClass               (7 constructors, tags 0-6)
--   ExchangeType              (4 constructors, tags 0-3)
--   DeliveryMode              (2 constructors, tags 0-1)
--   ErrorSeverity             (2 constructors, tags 0-1)
--   ConnectionState           (5 constructors, tags 0-4)
--   ChannelState              (4 constructors, tags 0-3)
--   BrokerState               (6 constructors, tags 0-5)

module AmqpABI.Types

%default total

---------------------------------------------------------------------------
-- FrameType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
frame_typeSize : Nat
frame_typeSize = 1

||| FrameType sum type for ABI encoding.
public export
data FrameType : Type where
  Method : FrameType
  Header : FrameType
  Body : FrameType
  Heartbeat : FrameType

||| Encode a FrameType to its ABI tag value.
public export
frame_typeToTag : FrameType -> Bits8
frame_typeToTag Method = 0
frame_typeToTag Header = 1
frame_typeToTag Body = 2
frame_typeToTag Heartbeat = 3

||| Decode an ABI tag to a FrameType.
public export
tagToFrameType : Bits8 -> Maybe FrameType
tagToFrameType 0 = Just Method
tagToFrameType 1 = Just Header
tagToFrameType 2 = Just Body
tagToFrameType 3 = Just Heartbeat
tagToFrameType _ = Nothing

||| Roundtrip proof: decoding an encoded FrameType yields the original.
public export
frame_typeRoundtrip : (x : FrameType) -> tagToFrameType (frame_typeToTag x) = Just x
frame_typeRoundtrip Method = Refl
frame_typeRoundtrip Header = Refl
frame_typeRoundtrip Body = Refl
frame_typeRoundtrip Heartbeat = Refl

---------------------------------------------------------------------------
-- MethodClass (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
method_classSize : Nat
method_classSize = 1

||| MethodClass sum type for ABI encoding.
public export
data MethodClass : Type where
  Connection : MethodClass
  Channel : MethodClass
  Exchange : MethodClass
  Queue : MethodClass
  Basic : MethodClass
  Tx : MethodClass
  Confirm : MethodClass

||| Encode a MethodClass to its ABI tag value.
public export
method_classToTag : MethodClass -> Bits8
method_classToTag Connection = 0
method_classToTag Channel = 1
method_classToTag Exchange = 2
method_classToTag Queue = 3
method_classToTag Basic = 4
method_classToTag Tx = 5
method_classToTag Confirm = 6

||| Decode an ABI tag to a MethodClass.
public export
tagToMethodClass : Bits8 -> Maybe MethodClass
tagToMethodClass 0 = Just Connection
tagToMethodClass 1 = Just Channel
tagToMethodClass 2 = Just Exchange
tagToMethodClass 3 = Just Queue
tagToMethodClass 4 = Just Basic
tagToMethodClass 5 = Just Tx
tagToMethodClass 6 = Just Confirm
tagToMethodClass _ = Nothing

||| Roundtrip proof: decoding an encoded MethodClass yields the original.
public export
method_classRoundtrip : (x : MethodClass) -> tagToMethodClass (method_classToTag x) = Just x
method_classRoundtrip Connection = Refl
method_classRoundtrip Channel = Refl
method_classRoundtrip Exchange = Refl
method_classRoundtrip Queue = Refl
method_classRoundtrip Basic = Refl
method_classRoundtrip Tx = Refl
method_classRoundtrip Confirm = Refl

---------------------------------------------------------------------------
-- ExchangeType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
exchange_typeSize : Nat
exchange_typeSize = 1

||| ExchangeType sum type for ABI encoding.
public export
data ExchangeType : Type where
  Direct : ExchangeType
  Fanout : ExchangeType
  Topic : ExchangeType
  Headers : ExchangeType

||| Encode a ExchangeType to its ABI tag value.
public export
exchange_typeToTag : ExchangeType -> Bits8
exchange_typeToTag Direct = 0
exchange_typeToTag Fanout = 1
exchange_typeToTag Topic = 2
exchange_typeToTag Headers = 3

||| Decode an ABI tag to a ExchangeType.
public export
tagToExchangeType : Bits8 -> Maybe ExchangeType
tagToExchangeType 0 = Just Direct
tagToExchangeType 1 = Just Fanout
tagToExchangeType 2 = Just Topic
tagToExchangeType 3 = Just Headers
tagToExchangeType _ = Nothing

||| Roundtrip proof: decoding an encoded ExchangeType yields the original.
public export
exchange_typeRoundtrip : (x : ExchangeType) -> tagToExchangeType (exchange_typeToTag x) = Just x
exchange_typeRoundtrip Direct = Refl
exchange_typeRoundtrip Fanout = Refl
exchange_typeRoundtrip Topic = Refl
exchange_typeRoundtrip Headers = Refl

---------------------------------------------------------------------------
-- DeliveryMode (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
delivery_modeSize : Nat
delivery_modeSize = 1

||| DeliveryMode sum type for ABI encoding.
public export
data DeliveryMode : Type where
  NonPersistent : DeliveryMode
  Persistent : DeliveryMode

||| Encode a DeliveryMode to its ABI tag value.
public export
delivery_modeToTag : DeliveryMode -> Bits8
delivery_modeToTag NonPersistent = 0
delivery_modeToTag Persistent = 1

||| Decode an ABI tag to a DeliveryMode.
public export
tagToDeliveryMode : Bits8 -> Maybe DeliveryMode
tagToDeliveryMode 0 = Just NonPersistent
tagToDeliveryMode 1 = Just Persistent
tagToDeliveryMode _ = Nothing

||| Roundtrip proof: decoding an encoded DeliveryMode yields the original.
public export
delivery_modeRoundtrip : (x : DeliveryMode) -> tagToDeliveryMode (delivery_modeToTag x) = Just x
delivery_modeRoundtrip NonPersistent = Refl
delivery_modeRoundtrip Persistent = Refl

---------------------------------------------------------------------------
-- ErrorSeverity (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
error_severitySize : Nat
error_severitySize = 1

||| ErrorSeverity sum type for ABI encoding.
public export
data ErrorSeverity : Type where
  ChannelLevel : ErrorSeverity
  ConnectionLevel : ErrorSeverity

||| Encode a ErrorSeverity to its ABI tag value.
public export
error_severityToTag : ErrorSeverity -> Bits8
error_severityToTag ChannelLevel = 0
error_severityToTag ConnectionLevel = 1

||| Decode an ABI tag to a ErrorSeverity.
public export
tagToErrorSeverity : Bits8 -> Maybe ErrorSeverity
tagToErrorSeverity 0 = Just ChannelLevel
tagToErrorSeverity 1 = Just ConnectionLevel
tagToErrorSeverity _ = Nothing

||| Roundtrip proof: decoding an encoded ErrorSeverity yields the original.
public export
error_severityRoundtrip : (x : ErrorSeverity) -> tagToErrorSeverity (error_severityToTag x) = Just x
error_severityRoundtrip ChannelLevel = Refl
error_severityRoundtrip ConnectionLevel = Refl

---------------------------------------------------------------------------
-- ConnectionState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
connection_stateSize : Nat
connection_stateSize = 1

||| ConnectionState sum type for ABI encoding.
public export
data ConnectionState : Type where
  Idle : ConnectionState
  Negotiating : ConnectionState
  TuningOk : ConnectionState
  Open : ConnectionState
  Closing : ConnectionState

||| Encode a ConnectionState to its ABI tag value.
public export
connection_stateToTag : ConnectionState -> Bits8
connection_stateToTag Idle = 0
connection_stateToTag Negotiating = 1
connection_stateToTag TuningOk = 2
connection_stateToTag Open = 3
connection_stateToTag Closing = 4

||| Decode an ABI tag to a ConnectionState.
public export
tagToConnectionState : Bits8 -> Maybe ConnectionState
tagToConnectionState 0 = Just Idle
tagToConnectionState 1 = Just Negotiating
tagToConnectionState 2 = Just TuningOk
tagToConnectionState 3 = Just Open
tagToConnectionState 4 = Just Closing
tagToConnectionState _ = Nothing

||| Roundtrip proof: decoding an encoded ConnectionState yields the original.
public export
connection_stateRoundtrip : (x : ConnectionState) -> tagToConnectionState (connection_stateToTag x) = Just x
connection_stateRoundtrip Idle = Refl
connection_stateRoundtrip Negotiating = Refl
connection_stateRoundtrip TuningOk = Refl
connection_stateRoundtrip Open = Refl
connection_stateRoundtrip Closing = Refl

---------------------------------------------------------------------------
-- ChannelState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
channel_stateSize : Nat
channel_stateSize = 1

||| ChannelState sum type for ABI encoding.
public export
data ChannelState : Type where
  Closed : ChannelState
  Opening : ChannelState
  ChOpen : ChannelState
  ChClosing : ChannelState

||| Encode a ChannelState to its ABI tag value.
public export
channel_stateToTag : ChannelState -> Bits8
channel_stateToTag Closed = 0
channel_stateToTag Opening = 1
channel_stateToTag ChOpen = 2
channel_stateToTag ChClosing = 3

||| Decode an ABI tag to a ChannelState.
public export
tagToChannelState : Bits8 -> Maybe ChannelState
tagToChannelState 0 = Just Closed
tagToChannelState 1 = Just Opening
tagToChannelState 2 = Just ChOpen
tagToChannelState 3 = Just ChClosing
tagToChannelState _ = Nothing

||| Roundtrip proof: decoding an encoded ChannelState yields the original.
public export
channel_stateRoundtrip : (x : ChannelState) -> tagToChannelState (channel_stateToTag x) = Just x
channel_stateRoundtrip Closed = Refl
channel_stateRoundtrip Opening = Refl
channel_stateRoundtrip ChOpen = Refl
channel_stateRoundtrip ChClosing = Refl

---------------------------------------------------------------------------
-- BrokerState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
broker_stateSize : Nat
broker_stateSize = 1

||| BrokerState sum type for ABI encoding.
public export
data BrokerState : Type where
  Idle : BrokerState
  Connected : BrokerState
  ChannelOpen : BrokerState
  Consuming : BrokerState
  Publishing : BrokerState
  Disconnecting : BrokerState

||| Encode a BrokerState to its ABI tag value.
public export
broker_stateToTag : BrokerState -> Bits8
broker_stateToTag Idle = 0
broker_stateToTag Connected = 1
broker_stateToTag ChannelOpen = 2
broker_stateToTag Consuming = 3
broker_stateToTag Publishing = 4
broker_stateToTag Disconnecting = 5

||| Decode an ABI tag to a BrokerState.
public export
tagToBrokerState : Bits8 -> Maybe BrokerState
tagToBrokerState 0 = Just Idle
tagToBrokerState 1 = Just Connected
tagToBrokerState 2 = Just ChannelOpen
tagToBrokerState 3 = Just Consuming
tagToBrokerState 4 = Just Publishing
tagToBrokerState 5 = Just Disconnecting
tagToBrokerState _ = Nothing

||| Roundtrip proof: decoding an encoded BrokerState yields the original.
public export
broker_stateRoundtrip : (x : BrokerState) -> tagToBrokerState (broker_stateToTag x) = Just x
broker_stateRoundtrip Idle = Refl
broker_stateRoundtrip Connected = Refl
broker_stateRoundtrip ChannelOpen = Refl
broker_stateRoundtrip Consuming = Refl
broker_stateRoundtrip Publishing = Refl
broker_stateRoundtrip Disconnecting = Refl
