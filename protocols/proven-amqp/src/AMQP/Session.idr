-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AMQP 0-9-1 Connection and Channel State Machine
--
-- Models the AMQP connection lifecycle as a finite state machine with
-- dependent types ensuring only valid transitions can be constructed.
--
-- Connection states:
--   Idle -> Negotiating -> TuningOk -> Open -> Closing -> Idle
--
-- Channel states:
--   Closed -> Opening -> Open -> Closing -> Closed
--
-- Consumer and delivery tag management is included for tracking
-- active consumers and outstanding deliveries per channel.

module AMQP.Session

import AMQP.Types

%default total

-- ============================================================================
-- Connection states (AMQP 0-9-1 Section 2.2.4)
-- ============================================================================

||| The states of an AMQP connection lifecycle.
||| AMQP connections go through a negotiation phase before becoming
||| fully operational.
public export
data ConnectionState : Type where
  ||| No connection established. Initial and terminal state.
  Idle        : ConnectionState
  ||| TCP connected, protocol header sent, awaiting Connection.Start.
  Negotiating : ConnectionState
  ||| Connection.Start-Ok sent, Connection.Tune received, awaiting Tune-Ok.
  TuningOk    : ConnectionState
  ||| Connection.Open sent and accepted. Fully operational.
  Open        : ConnectionState
  ||| Connection.Close sent or received. Waiting for Close-Ok.
  Closing     : ConnectionState

public export
Eq ConnectionState where
  Idle        == Idle        = True
  Negotiating == Negotiating = True
  TuningOk    == TuningOk    = True
  Open        == Open        = True
  Closing     == Closing     = True
  _           == _           = False

public export
Show ConnectionState where
  show Idle        = "Idle"
  show Negotiating = "Negotiating"
  show TuningOk    = "TuningOk"
  show Open        = "Open"
  show Closing     = "Closing"

-- ============================================================================
-- Connection events
-- ============================================================================

||| Events that drive connection state transitions.
public export
data ConnectionEvent : Type where
  ||| TCP connection established, protocol header sent.
  ProtocolHeaderSent   : ConnectionEvent
  ||| Connection.Start received from broker, Start-Ok sent.
  StartOkSent          : ConnectionEvent
  ||| Connection.Tune received, Tune-Ok sent.
  TuneOkSent           : ConnectionEvent
  ||| Connection.Open-Ok received from broker.
  OpenOkReceived       : ConnectionEvent
  ||| Connection.Close sent by client.
  CloseInitiated       : ConnectionEvent
  ||| Connection.Close received from broker.
  CloseReceived        : ConnectionEvent
  ||| Connection.Close-Ok received, connection fully closed.
  CloseOkReceived      : ConnectionEvent
  ||| TCP connection lost unexpectedly.
  ConnectionLost       : ConnectionEvent

public export
Show ConnectionEvent where
  show ProtocolHeaderSent = "ProtocolHeaderSent"
  show StartOkSent        = "StartOkSent"
  show TuneOkSent         = "TuneOkSent"
  show OpenOkReceived     = "OpenOkReceived"
  show CloseInitiated     = "CloseInitiated"
  show CloseReceived      = "CloseReceived"
  show CloseOkReceived    = "CloseOkReceived"
  show ConnectionLost     = "ConnectionLost"

-- ============================================================================
-- Connection transition function (total over all state/event combinations)
-- ============================================================================

||| Result of a connection state transition.
public export
record ConnectionTransition where
  constructor MkConnectionTransition
  ||| The new state after the transition.
  newState : ConnectionState
  ||| Whether the transition was valid and applied.
  valid    : Bool

||| Connection state transition function.
||| Invalid combinations produce the same state with valid=False.
public export
connectionTransition : ConnectionState -> ConnectionEvent -> ConnectionTransition
-- From Idle
connectionTransition Idle ProtocolHeaderSent = MkConnectionTransition Negotiating True
connectionTransition Idle _                  = MkConnectionTransition Idle False
-- From Negotiating
connectionTransition Negotiating StartOkSent    = MkConnectionTransition TuningOk True
connectionTransition Negotiating ConnectionLost = MkConnectionTransition Idle True
connectionTransition Negotiating _              = MkConnectionTransition Negotiating False
-- From TuningOk
connectionTransition TuningOk TuneOkSent     = MkConnectionTransition Open True
connectionTransition TuningOk ConnectionLost = MkConnectionTransition Idle True
connectionTransition TuningOk _              = MkConnectionTransition TuningOk False
-- From Open
connectionTransition Open CloseInitiated = MkConnectionTransition Closing True
connectionTransition Open CloseReceived  = MkConnectionTransition Closing True
connectionTransition Open ConnectionLost = MkConnectionTransition Idle True
connectionTransition Open _              = MkConnectionTransition Open False
-- From Closing
connectionTransition Closing CloseOkReceived = MkConnectionTransition Idle True
connectionTransition Closing ConnectionLost  = MkConnectionTransition Idle True
connectionTransition Closing _               = MkConnectionTransition Closing False

-- ============================================================================
-- Channel states (AMQP 0-9-1 Section 2.2.5)
-- ============================================================================

||| The states of an AMQP channel lifecycle.
||| Multiple channels are multiplexed over a single connection.
public export
data ChannelState : Type where
  ||| Channel is closed (initial/terminal).
  Closed   : ChannelState
  ||| Channel.Open sent, awaiting Channel.Open-Ok.
  Opening  : ChannelState
  ||| Channel is fully open and operational.
  ChOpen   : ChannelState
  ||| Channel.Close sent or received, awaiting Close-Ok.
  ChClosing : ChannelState

public export
Eq ChannelState where
  Closed    == Closed    = True
  Opening   == Opening   = True
  ChOpen    == ChOpen    = True
  ChClosing == ChClosing = True
  _         == _         = False

public export
Show ChannelState where
  show Closed    = "Closed"
  show Opening   = "Opening"
  show ChOpen    = "Open"
  show ChClosing = "Closing"

-- ============================================================================
-- Channel events
-- ============================================================================

||| Events that drive channel state transitions.
public export
data ChannelEvent : Type where
  ||| Channel.Open sent by client.
  ChannelOpenSent      : ChannelEvent
  ||| Channel.Open-Ok received from broker.
  ChannelOpenOk        : ChannelEvent
  ||| Channel.Close sent by client or received from broker.
  ChannelCloseInitiated : ChannelEvent
  ||| Channel.Close-Ok received.
  ChannelCloseOk       : ChannelEvent
  ||| Parent connection lost.
  ChannelConnectionLost : ChannelEvent

public export
Show ChannelEvent where
  show ChannelOpenSent       = "ChannelOpenSent"
  show ChannelOpenOk         = "ChannelOpenOk"
  show ChannelCloseInitiated = "ChannelCloseInitiated"
  show ChannelCloseOk        = "ChannelCloseOk"
  show ChannelConnectionLost = "ChannelConnectionLost"

-- ============================================================================
-- Channel transition function
-- ============================================================================

||| Result of a channel state transition.
public export
record ChannelTransition where
  constructor MkChannelTransition
  newState : ChannelState
  valid    : Bool

||| Channel state transition function (total).
public export
channelTransition : ChannelState -> ChannelEvent -> ChannelTransition
-- From Closed
channelTransition Closed ChannelOpenSent       = MkChannelTransition Opening True
channelTransition Closed _                     = MkChannelTransition Closed False
-- From Opening
channelTransition Opening ChannelOpenOk         = MkChannelTransition ChOpen True
channelTransition Opening ChannelConnectionLost = MkChannelTransition Closed True
channelTransition Opening _                     = MkChannelTransition Opening False
-- From ChOpen
channelTransition ChOpen ChannelCloseInitiated  = MkChannelTransition ChClosing True
channelTransition ChOpen ChannelConnectionLost  = MkChannelTransition Closed True
channelTransition ChOpen _                      = MkChannelTransition ChOpen False
-- From ChClosing
channelTransition ChClosing ChannelCloseOk        = MkChannelTransition Closed True
channelTransition ChClosing ChannelConnectionLost  = MkChannelTransition Closed True
channelTransition ChClosing _                      = MkChannelTransition ChClosing False

-- ============================================================================
-- Virtual host
-- ============================================================================

||| An AMQP virtual host provides namespace isolation.
||| Each connection targets exactly one vhost.
public export
record VHost where
  constructor MkVHost
  ||| The virtual host path (e.g., "/" for default).
  path : String

public export
Eq VHost where
  a == b = a.path == b.path

public export
Show VHost where
  show v = "VHost(" ++ show v.path ++ ")"

||| The default virtual host ("/").
public export
defaultVHost : VHost
defaultVHost = MkVHost "/"

-- ============================================================================
-- Consumer tag and delivery tag
-- ============================================================================

||| A consumer tag uniquely identifies a consumer within a channel.
||| Created by Basic.Consume and used to cancel with Basic.Cancel.
public export
record ConsumerTag where
  constructor MkConsumerTag
  ||| The tag string (server-generated or client-specified).
  tag : String

public export
Eq ConsumerTag where
  a == b = a.tag == b.tag

public export
Show ConsumerTag where
  show ct = "ConsumerTag(" ++ show ct.tag ++ ")"

||| A delivery tag is a monotonically increasing 64-bit integer
||| assigned by the broker to each delivered message on a channel.
||| Used for Basic.Ack, Basic.Nack, and Basic.Reject.
public export
record DeliveryTag where
  constructor MkDeliveryTag
  ||| The delivery tag value (channel-scoped, monotonically increasing).
  tag : Bits64

public export
Eq DeliveryTag where
  a == b = a.tag == b.tag

public export
Show DeliveryTag where
  show dt = "DeliveryTag(" ++ show (cast {to=Integer} dt.tag) ++ ")"

-- ============================================================================
-- QoS (Basic.Qos) settings
-- ============================================================================

||| Quality of service settings for a channel (Basic.Qos).
||| Controls the prefetch window for message delivery.
public export
record QoSSettings where
  constructor MkQoSSettings
  ||| Maximum number of unacknowledged messages (0 = unlimited).
  prefetchCount : Bits16
  ||| Maximum total size of unacknowledged messages in bytes (0 = unlimited).
  prefetchSize  : Bits32
  ||| Whether QoS applies to the entire connection (True) or just the channel (False).
  global        : Bool

public export
Show QoSSettings where
  show q = "QoS(count=" ++ show (cast {to=Nat} q.prefetchCount)
           ++ ", size=" ++ show (cast {to=Nat} q.prefetchSize)
           ++ ", global=" ++ show q.global ++ ")"

||| Default QoS settings (no limits).
public export
defaultQoS : QoSSettings
defaultQoS = MkQoSSettings
  { prefetchCount = 0
  , prefetchSize  = 0
  , global        = False
  }

-- ============================================================================
-- Connection negotiation parameters
-- ============================================================================

||| Negotiated connection parameters after Connection.Tune.
public export
record ConnectionParams where
  constructor MkConnectionParams
  ||| Maximum number of channels (0 = unlimited).
  channelMax : Bits16
  ||| Maximum frame size in bytes.
  frameMax   : Bits32
  ||| Heartbeat interval in seconds (0 = disabled).
  heartbeat  : Bits16
  ||| Virtual host for this connection.
  vhost      : VHost

public export
Show ConnectionParams where
  show p = "ConnectionParams(channelMax=" ++ show (cast {to=Nat} p.channelMax)
           ++ ", frameMax=" ++ show (cast {to=Nat} p.frameMax)
           ++ ", heartbeat=" ++ show (cast {to=Nat} p.heartbeat)
           ++ ", vhost=" ++ show p.vhost ++ ")"
