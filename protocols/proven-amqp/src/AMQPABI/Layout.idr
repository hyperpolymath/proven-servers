-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AMQPABI.Layout: C-ABI-compatible numeric representations of AMQP types.
--
-- Maps every constructor of the core AMQP sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/amqp.h) and the
-- Zig FFI enums (ffi/zig/src/amqp.zig) exactly.
--
-- Types covered:
--   FrameType        (4 constructors, tags 0-3)
--   MethodClass      (7 constructors, tags 0-6)
--   ExchangeType     (4 constructors, tags 0-3)
--   DeliveryMode     (2 constructors, tags 0-1)
--   ErrorSeverity    (2 constructors, tags 0-1)
--   ConnectionState  (5 constructors, tags 0-4)
--   ChannelState     (4 constructors, tags 0-3)
--   BrokerState      (6 constructors, tags 0-5)

module AMQPABI.Layout

import AMQP.Types
import AMQP.Session

%default total

---------------------------------------------------------------------------
-- FrameType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
frameTypeSize : Nat
frameTypeSize = 1

||| Encode a FrameType to its ABI tag value.
||| Note: these are sequential 0-3, distinct from the AMQP wire codes.
public export
frameTypeToTag : FrameType -> Bits8
frameTypeToTag Method    = 0
frameTypeToTag Header    = 1
frameTypeToTag Body      = 2
frameTypeToTag Heartbeat = 3

public export
tagToFrameType : Bits8 -> Maybe FrameType
tagToFrameType 0 = Just Method
tagToFrameType 1 = Just Header
tagToFrameType 2 = Just Body
tagToFrameType 3 = Just Heartbeat
tagToFrameType _ = Nothing

public export
frameTypeRoundtrip : (f : FrameType) -> tagToFrameType (frameTypeToTag f) = Just f
frameTypeRoundtrip Method    = Refl
frameTypeRoundtrip Header    = Refl
frameTypeRoundtrip Body      = Refl
frameTypeRoundtrip Heartbeat = Refl

---------------------------------------------------------------------------
-- MethodClass (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
methodClassSize : Nat
methodClassSize = 1

public export
methodClassToTag : MethodClass -> Bits8
methodClassToTag Connection = 0
methodClassToTag Channel    = 1
methodClassToTag Exchange   = 2
methodClassToTag Queue      = 3
methodClassToTag Basic      = 4
methodClassToTag Tx         = 5
methodClassToTag Confirm    = 6

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

public export
methodClassRoundtrip : (m : MethodClass) -> tagToMethodClass (methodClassToTag m) = Just m
methodClassRoundtrip Connection = Refl
methodClassRoundtrip Channel    = Refl
methodClassRoundtrip Exchange   = Refl
methodClassRoundtrip Queue      = Refl
methodClassRoundtrip Basic      = Refl
methodClassRoundtrip Tx         = Refl
methodClassRoundtrip Confirm    = Refl

---------------------------------------------------------------------------
-- ExchangeType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
exchangeTypeSize : Nat
exchangeTypeSize = 1

public export
exchangeTypeToTag : ExchangeType -> Bits8
exchangeTypeToTag Direct  = 0
exchangeTypeToTag Fanout  = 1
exchangeTypeToTag Topic   = 2
exchangeTypeToTag Headers = 3

public export
tagToExchangeType : Bits8 -> Maybe ExchangeType
tagToExchangeType 0 = Just Direct
tagToExchangeType 1 = Just Fanout
tagToExchangeType 2 = Just Topic
tagToExchangeType 3 = Just Headers
tagToExchangeType _ = Nothing

public export
exchangeTypeRoundtrip : (e : ExchangeType) -> tagToExchangeType (exchangeTypeToTag e) = Just e
exchangeTypeRoundtrip Direct  = Refl
exchangeTypeRoundtrip Fanout  = Refl
exchangeTypeRoundtrip Topic   = Refl
exchangeTypeRoundtrip Headers = Refl

---------------------------------------------------------------------------
-- DeliveryMode (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
deliveryModeSize : Nat
deliveryModeSize = 1

public export
deliveryModeToTag : DeliveryMode -> Bits8
deliveryModeToTag NonPersistent = 0
deliveryModeToTag Persistent    = 1

public export
tagToDeliveryMode : Bits8 -> Maybe DeliveryMode
tagToDeliveryMode 0 = Just NonPersistent
tagToDeliveryMode 1 = Just Persistent
tagToDeliveryMode _ = Nothing

public export
deliveryModeRoundtrip : (d : DeliveryMode) -> tagToDeliveryMode (deliveryModeToTag d) = Just d
deliveryModeRoundtrip NonPersistent = Refl
deliveryModeRoundtrip Persistent    = Refl

---------------------------------------------------------------------------
-- ErrorSeverity (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
errorSeveritySize : Nat
errorSeveritySize = 1

public export
errorSeverityToTag : ErrorSeverity -> Bits8
errorSeverityToTag ChannelLevel    = 0
errorSeverityToTag ConnectionLevel = 1

public export
tagToErrorSeverity : Bits8 -> Maybe ErrorSeverity
tagToErrorSeverity 0 = Just ChannelLevel
tagToErrorSeverity 1 = Just ConnectionLevel
tagToErrorSeverity _ = Nothing

public export
errorSeverityRoundtrip : (s : ErrorSeverity) -> tagToErrorSeverity (errorSeverityToTag s) = Just s
errorSeverityRoundtrip ChannelLevel    = Refl
errorSeverityRoundtrip ConnectionLevel = Refl

---------------------------------------------------------------------------
-- ConnectionState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
connectionStateSize : Nat
connectionStateSize = 1

public export
connectionStateToTag : ConnectionState -> Bits8
connectionStateToTag Idle        = 0
connectionStateToTag Negotiating = 1
connectionStateToTag TuningOk    = 2
connectionStateToTag Open        = 3
connectionStateToTag Closing     = 4

public export
tagToConnectionState : Bits8 -> Maybe ConnectionState
tagToConnectionState 0 = Just Idle
tagToConnectionState 1 = Just Negotiating
tagToConnectionState 2 = Just TuningOk
tagToConnectionState 3 = Just Open
tagToConnectionState 4 = Just Closing
tagToConnectionState _ = Nothing

public export
connectionStateRoundtrip : (s : ConnectionState) -> tagToConnectionState (connectionStateToTag s) = Just s
connectionStateRoundtrip Idle        = Refl
connectionStateRoundtrip Negotiating = Refl
connectionStateRoundtrip TuningOk    = Refl
connectionStateRoundtrip Open        = Refl
connectionStateRoundtrip Closing     = Refl

---------------------------------------------------------------------------
-- ChannelState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
channelStateSize : Nat
channelStateSize = 1

public export
channelStateToTag : ChannelState -> Bits8
channelStateToTag Closed    = 0
channelStateToTag Opening   = 1
channelStateToTag ChOpen    = 2
channelStateToTag ChClosing = 3

public export
tagToChannelState : Bits8 -> Maybe ChannelState
tagToChannelState 0 = Just Closed
tagToChannelState 1 = Just Opening
tagToChannelState 2 = Just ChOpen
tagToChannelState 3 = Just ChClosing
tagToChannelState _ = Nothing

public export
channelStateRoundtrip : (s : ChannelState) -> tagToChannelState (channelStateToTag s) = Just s
channelStateRoundtrip Closed    = Refl
channelStateRoundtrip Opening   = Refl
channelStateRoundtrip ChOpen    = Refl
channelStateRoundtrip ChClosing = Refl

---------------------------------------------------------------------------
-- BrokerState (6 constructors, tags 0-5)
-- Composite lifecycle state used by the FFI for simplified management.
---------------------------------------------------------------------------

||| Broker-side AMQP session lifecycle states.
||| This is a simplified view used by the FFI layer, combining
||| connection + channel states into a single enum for the C ABI.
public export
data BrokerState : Type where
  ||| No connection. Initial and terminal state.
  BSIdle          : BrokerState
  ||| Connection negotiated, no channels open yet.
  BSConnected     : BrokerState
  ||| At least one channel is open.
  BSChannelOpen   : BrokerState
  ||| Actively consuming messages on one or more channels.
  BSConsuming     : BrokerState
  ||| Actively publishing messages (in-flight acks pending).
  BSPublishing    : BrokerState
  ||| Connection closing (close handshake in progress).
  BSDisconnecting : BrokerState

public export
Eq BrokerState where
  BSIdle          == BSIdle          = True
  BSConnected     == BSConnected     = True
  BSChannelOpen   == BSChannelOpen   = True
  BSConsuming     == BSConsuming     = True
  BSPublishing    == BSPublishing    = True
  BSDisconnecting == BSDisconnecting = True
  _               == _               = False

public export
Show BrokerState where
  show BSIdle          = "Idle"
  show BSConnected     = "Connected"
  show BSChannelOpen   = "ChannelOpen"
  show BSConsuming     = "Consuming"
  show BSPublishing    = "Publishing"
  show BSDisconnecting = "Disconnecting"

public export
brokerStateSize : Nat
brokerStateSize = 1

public export
brokerStateToTag : BrokerState -> Bits8
brokerStateToTag BSIdle          = 0
brokerStateToTag BSConnected     = 1
brokerStateToTag BSChannelOpen   = 2
brokerStateToTag BSConsuming     = 3
brokerStateToTag BSPublishing    = 4
brokerStateToTag BSDisconnecting = 5

public export
tagToBrokerState : Bits8 -> Maybe BrokerState
tagToBrokerState 0 = Just BSIdle
tagToBrokerState 1 = Just BSConnected
tagToBrokerState 2 = Just BSChannelOpen
tagToBrokerState 3 = Just BSConsuming
tagToBrokerState 4 = Just BSPublishing
tagToBrokerState 5 = Just BSDisconnecting
tagToBrokerState _ = Nothing

public export
brokerStateRoundtrip : (s : BrokerState) -> tagToBrokerState (brokerStateToTag s) = Just s
brokerStateRoundtrip BSIdle          = Refl
brokerStateRoundtrip BSConnected     = Refl
brokerStateRoundtrip BSChannelOpen   = Refl
brokerStateRoundtrip BSConsuming     = Refl
brokerStateRoundtrip BSPublishing    = Refl
brokerStateRoundtrip BSDisconnecting = Refl
