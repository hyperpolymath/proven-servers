-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AMQPABI.Transitions: Valid AMQP broker state transitions and capability
-- witnesses.
--
-- Broker lifecycle (6 states):
--
--   Idle --> Connected --> ChannelOpen --> Consuming
--                  ^            |              |
--                  |            v              v
--                  +--- ChannelOpen <--- Publishing
--                  |            |
--                  +--- Connected (all channels closed)
--
-- With abort edges:
--   Any non-Idle state --Abort--> Disconnecting
--   Disconnecting --Cleanup--> Idle
--   Idle is initial; Idle is reachable only from Disconnecting.
--
-- Key invariant: CanPublish requires ChannelOpen or Consuming state.
-- Key invariant: CanConsume requires ChannelOpen or Consuming state.
-- Key invariant: Idle has no outbound edges except Connect.

module AMQPABI.Transitions

import AMQPABI.Layout

%default total

---------------------------------------------------------------------------
-- ValidBrokerTransition: exhaustive enumeration of legal transitions.
---------------------------------------------------------------------------

||| Proof witness that a broker state transition is valid.
public export
data ValidBrokerTransition : BrokerState -> BrokerState -> Type where
  ||| Idle -> Connected (connection negotiated, AMQP handshake complete).
  ClientConnected       : ValidBrokerTransition BSIdle BSConnected
  ||| Connected -> ChannelOpen (first channel opened).
  FirstChannelOpened    : ValidBrokerTransition BSConnected BSChannelOpen
  ||| ChannelOpen -> ChannelOpen (additional channels opened/closed, at least one remains).
  ChannelActivity       : ValidBrokerTransition BSChannelOpen BSChannelOpen
  ||| ChannelOpen -> Connected (all channels closed).
  AllChannelsClosed     : ValidBrokerTransition BSChannelOpen BSConnected
  ||| ChannelOpen -> Consuming (Basic.Consume issued on a channel).
  BeginConsuming        : ValidBrokerTransition BSChannelOpen BSConsuming
  ||| Consuming -> Consuming (additional consumers added).
  AdditionalConsumer    : ValidBrokerTransition BSConsuming BSConsuming
  ||| Consuming -> ChannelOpen (all consumers cancelled).
  AllConsumersCancelled : ValidBrokerTransition BSConsuming BSChannelOpen
  ||| ChannelOpen -> Publishing (Basic.Publish with confirms).
  BeginPublish          : ValidBrokerTransition BSChannelOpen BSPublishing
  ||| Consuming -> Publishing (publish while consuming).
  BeginPublishConsuming : ValidBrokerTransition BSConsuming BSPublishing
  ||| Publishing -> ChannelOpen (all confirms received, no consumers).
  PublishDoneNoCons     : ValidBrokerTransition BSPublishing BSChannelOpen
  ||| Publishing -> Consuming (all confirms received, consumers active).
  PublishDoneCons       : ValidBrokerTransition BSPublishing BSConsuming
  ||| Connected -> Disconnecting (connection close initiated).
  DisconnectFromConn    : ValidBrokerTransition BSConnected BSDisconnecting
  ||| ChannelOpen -> Disconnecting (connection lost or close).
  DisconnectFromChan    : ValidBrokerTransition BSChannelOpen BSDisconnecting
  ||| Consuming -> Disconnecting (connection lost during consume).
  DisconnectFromCons    : ValidBrokerTransition BSConsuming BSDisconnecting
  ||| Publishing -> Disconnecting (connection lost during publish).
  DisconnectFromPub     : ValidBrokerTransition BSPublishing BSDisconnecting
  ||| Disconnecting -> Idle (cleanup complete, resources released).
  CleanupDone           : ValidBrokerTransition BSDisconnecting BSIdle

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a session can publish messages.
||| Publishing requires at least one open channel.
public export
data CanPublish : BrokerState -> Type where
  ChannelOpenCanPublish  : CanPublish BSChannelOpen
  ConsumingCanPublish    : CanPublish BSConsuming

||| Proof that a session can start consuming messages.
||| Consuming requires at least one open channel.
public export
data CanConsume : BrokerState -> Type where
  ChannelOpenCanConsume  : CanConsume BSChannelOpen
  ConsumingCanConsume    : CanConsume BSConsuming

||| Proof that a session can open a channel.
||| Requires an established connection.
public export
data CanOpenChannel : BrokerState -> Type where
  ConnectedCanOpenChannel  : CanOpenChannel BSConnected
  ChannelOpenCanOpenMore   : CanOpenChannel BSChannelOpen

||| Proof that a session can acknowledge deliveries.
||| Acking requires at least one open channel.
public export
data CanAck : BrokerState -> Type where
  ChannelOpenCanAck : CanAck BSChannelOpen
  ConsumingCanAck   : CanAck BSConsuming
  PublishingCanAck  : CanAck BSPublishing

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot publish from Idle.
public export
idleCannotPublish : CanPublish BSIdle -> Void
idleCannotPublish _ impossible

||| Cannot publish from Disconnecting.
public export
disconnectingCannotPublish : CanPublish BSDisconnecting -> Void
disconnectingCannotPublish _ impossible

||| Cannot publish from Connected (need to open a channel first).
public export
connectedCannotPublish : CanPublish BSConnected -> Void
connectedCannotPublish _ impossible

||| Cannot consume from Idle.
public export
idleCannotConsume : CanConsume BSIdle -> Void
idleCannotConsume _ impossible

||| Cannot consume from Connected (need to open a channel first).
public export
connectedCannotConsume : CanConsume BSConnected -> Void
connectedCannotConsume _ impossible

||| Cannot open channels from Idle.
public export
idleCannotOpenChannel : CanOpenChannel BSIdle -> Void
idleCannotOpenChannel _ impossible

||| Cannot transition from Idle to ChannelOpen directly (must connect first).
public export
cannotSkipToChannelOpen : ValidBrokerTransition BSIdle BSChannelOpen -> Void
cannotSkipToChannelOpen _ impossible

||| Cannot transition from Idle to Consuming directly.
public export
cannotSkipToConsuming : ValidBrokerTransition BSIdle BSConsuming -> Void
cannotSkipToConsuming _ impossible

||| Cannot go from Disconnecting back to Connected directly.
public export
cannotReconnectFromDisconnecting : ValidBrokerTransition BSDisconnecting BSConnected -> Void
cannotReconnectFromDisconnecting _ impossible

||| Cannot ack from Idle.
public export
idleCannotAck : CanAck BSIdle -> Void
idleCannotAck _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether a broker state transition is valid.
public export
validateBrokerTransition : (from : BrokerState) -> (to : BrokerState)
                        -> Maybe (ValidBrokerTransition from to)
validateBrokerTransition BSIdle          BSConnected     = Just ClientConnected
validateBrokerTransition BSConnected     BSChannelOpen   = Just FirstChannelOpened
validateBrokerTransition BSChannelOpen   BSChannelOpen   = Just ChannelActivity
validateBrokerTransition BSChannelOpen   BSConnected     = Just AllChannelsClosed
validateBrokerTransition BSChannelOpen   BSConsuming     = Just BeginConsuming
validateBrokerTransition BSConsuming     BSConsuming     = Just AdditionalConsumer
validateBrokerTransition BSConsuming     BSChannelOpen   = Just AllConsumersCancelled
validateBrokerTransition BSChannelOpen   BSPublishing    = Just BeginPublish
validateBrokerTransition BSConsuming     BSPublishing    = Just BeginPublishConsuming
validateBrokerTransition BSPublishing    BSChannelOpen   = Just PublishDoneNoCons
validateBrokerTransition BSPublishing    BSConsuming     = Just PublishDoneCons
validateBrokerTransition BSConnected     BSDisconnecting = Just DisconnectFromConn
validateBrokerTransition BSChannelOpen   BSDisconnecting = Just DisconnectFromChan
validateBrokerTransition BSConsuming     BSDisconnecting = Just DisconnectFromCons
validateBrokerTransition BSPublishing    BSDisconnecting = Just DisconnectFromPub
validateBrokerTransition BSDisconnecting BSIdle          = Just CleanupDone
validateBrokerTransition _               _              = Nothing
