-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- MQTTABI.Transitions: Valid MQTT broker state transitions and QoS delivery
-- state machines.
--
-- Broker lifecycle (5 states):
--
--   Idle --> Connected --> Subscribed --> Publishing --> Disconnecting --> Idle
--                  ^            |               |
--                  |            v               v
--                  +--- Subscribed <--- Publishing
--                  |            |
--                  +--- Connected (unsubscribe all)
--
-- With abort edges:
--   Any non-Idle state --Abort--> Disconnecting
--   Disconnecting --Cleanup--> Idle
--   Idle is initial; Idle is reachable only from Disconnecting.
--
-- QoS 0 delivery: Idle -> Complete (fire and forget, no intermediate states).
-- QoS 1 delivery: Idle -> AwaitingPubAck -> Complete | Failed.
-- QoS 2 delivery: Idle -> AwaitingPubRec -> AwaitingPubRel -> AwaitingPubComp -> Complete | Failed.
--
-- Key invariant: CanPublish requires Connected or Subscribed state.
-- Key invariant: Idle has no outbound edges except Connect.

module MQTTABI.Transitions

import MQTTABI.Layout

%default total

---------------------------------------------------------------------------
-- ValidBrokerTransition: exhaustive enumeration of legal broker transitions.
---------------------------------------------------------------------------

||| Proof witness that a broker state transition is valid.
public export
data ValidBrokerTransition : BrokerState -> BrokerState -> Type where
  ||| Idle -> Connected (client sends CONNECT, broker sends CONNACK accepted).
  ClientConnected      : ValidBrokerTransition Idle Connected
  ||| Connected -> Subscribed (client sends SUBSCRIBE, broker sends SUBACK).
  ClientSubscribed     : ValidBrokerTransition Connected Subscribed
  ||| Subscribed -> Subscribed (client sends additional SUBSCRIBE).
  AdditionalSubscribe  : ValidBrokerTransition Subscribed Subscribed
  ||| Subscribed -> Connected (client unsubscribes from all topics).
  AllUnsubscribed      : ValidBrokerTransition Subscribed Connected
  ||| Connected -> Publishing (client sends PUBLISH with QoS > 0).
  BeginPublish         : ValidBrokerTransition Connected Publishing
  ||| Subscribed -> Publishing (client sends PUBLISH while subscribed).
  BeginPublishSub      : ValidBrokerTransition Subscribed Publishing
  ||| Publishing -> Connected (QoS flow complete, no subscriptions active).
  PublishDoneNoSub     : ValidBrokerTransition Publishing Connected
  ||| Publishing -> Subscribed (QoS flow complete, subscriptions still active).
  PublishDoneSub       : ValidBrokerTransition Publishing Subscribed
  ||| Connected -> Disconnecting (client sends DISCONNECT or connection lost).
  DisconnectFromConn   : ValidBrokerTransition Connected Disconnecting
  ||| Subscribed -> Disconnecting (connection lost while subscribed).
  DisconnectFromSub    : ValidBrokerTransition Subscribed Disconnecting
  ||| Publishing -> Disconnecting (connection lost during QoS flow).
  DisconnectFromPub    : ValidBrokerTransition Publishing Disconnecting
  ||| Disconnecting -> Idle (cleanup complete, resources released).
  CleanupDone          : ValidBrokerTransition Disconnecting Idle

---------------------------------------------------------------------------
-- Capability witnesses
---------------------------------------------------------------------------

||| Proof that a session can publish messages.
||| Publishing requires the client to be Connected or Subscribed.
public export
data CanPublish : BrokerState -> Type where
  ConnectedCanPublish  : CanPublish Connected
  SubscribedCanPublish : CanPublish Subscribed

||| Proof that a session can subscribe to topics.
||| Subscribing requires the client to be Connected or already Subscribed.
public export
data CanSubscribe : BrokerState -> Type where
  ConnectedCanSubscribe  : CanSubscribe Connected
  SubscribedCanSubscribe : CanSubscribe Subscribed

||| Proof that a session can receive forwarded messages.
||| Only Subscribed clients receive forwarded publishes.
public export
data CanReceive : BrokerState -> Type where
  SubscribedCanReceive : CanReceive Subscribed

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot leave the Idle state except via ClientConnected.
public export
idleCannotPublish : CanPublish Idle -> Void
idleCannotPublish _ impossible

||| Cannot publish from Disconnecting.
public export
disconnectingCannotPublish : CanPublish Disconnecting -> Void
disconnectingCannotPublish _ impossible

||| Cannot subscribe from Idle.
public export
idleCannotSubscribe : CanSubscribe Idle -> Void
idleCannotSubscribe _ impossible

||| Cannot subscribe from Publishing.
public export
publishingCannotSubscribe : CanSubscribe Publishing -> Void
publishingCannotSubscribe _ impossible

||| Cannot receive from Connected (must subscribe first).
public export
connectedCannotReceive : CanReceive Connected -> Void
connectedCannotReceive _ impossible

||| Cannot transition from Idle to Subscribed directly (must connect first).
public export
cannotSkipToSubscribed : ValidBrokerTransition Idle Subscribed -> Void
cannotSkipToSubscribed _ impossible

||| Cannot transition from Idle to Publishing directly.
public export
cannotSkipToPublishing : ValidBrokerTransition Idle Publishing -> Void
cannotSkipToPublishing _ impossible

||| Cannot go from Disconnecting back to Connected directly.
public export
cannotReconnectFromDisconnecting : ValidBrokerTransition Disconnecting Connected -> Void
cannotReconnectFromDisconnecting _ impossible

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Check whether a broker state transition is valid.
public export
validateBrokerTransition : (from : BrokerState) -> (to : BrokerState)
                        -> Maybe (ValidBrokerTransition from to)
validateBrokerTransition Idle          Connected     = Just ClientConnected
validateBrokerTransition Connected     Subscribed    = Just ClientSubscribed
validateBrokerTransition Subscribed    Subscribed    = Just AdditionalSubscribe
validateBrokerTransition Subscribed    Connected     = Just AllUnsubscribed
validateBrokerTransition Connected     Publishing    = Just BeginPublish
validateBrokerTransition Subscribed    Publishing    = Just BeginPublishSub
validateBrokerTransition Publishing    Connected     = Just PublishDoneNoSub
validateBrokerTransition Publishing    Subscribed    = Just PublishDoneSub
validateBrokerTransition Connected     Disconnecting = Just DisconnectFromConn
validateBrokerTransition Subscribed    Disconnecting = Just DisconnectFromSub
validateBrokerTransition Publishing    Disconnecting = Just DisconnectFromPub
validateBrokerTransition Disconnecting Idle          = Just CleanupDone
validateBrokerTransition _             _             = Nothing

---------------------------------------------------------------------------
-- QoS 0 delivery state machine (trivial: fire and forget)
---------------------------------------------------------------------------

||| QoS 0 delivery: the only valid transition is Idle -> Complete.
public export
data ValidQoS0Transition : QoSDeliveryState -> QoSDeliveryState -> Type where
  ||| Fire and forget: immediately complete.
  QoS0FireAndForget : ValidQoS0Transition QDIdle QDComplete

||| Validate a QoS 0 delivery transition.
public export
validateQoS0 : (from : QoSDeliveryState) -> (to : QoSDeliveryState)
            -> Maybe (ValidQoS0Transition from to)
validateQoS0 QDIdle QDComplete = Just QoS0FireAndForget
validateQoS0 _      _         = Nothing

---------------------------------------------------------------------------
-- QoS 1 delivery state machine
---------------------------------------------------------------------------

||| QoS 1 delivery transitions.
||| Idle -> AwaitingPubAck -> Complete (on PUBACK) or Failed (on timeout).
public export
data ValidQoS1Transition : QoSDeliveryState -> QoSDeliveryState -> Type where
  ||| PUBLISH sent, now awaiting PUBACK.
  QoS1Published  : ValidQoS1Transition QDIdle AwaitingPubAck
  ||| PUBACK received, delivery complete.
  QoS1Acked      : ValidQoS1Transition AwaitingPubAck QDComplete
  ||| Timeout or error while awaiting PUBACK.
  QoS1AckFailed  : ValidQoS1Transition AwaitingPubAck QDFailed

||| Validate a QoS 1 delivery transition.
public export
validateQoS1 : (from : QoSDeliveryState) -> (to : QoSDeliveryState)
            -> Maybe (ValidQoS1Transition from to)
validateQoS1 QDIdle         AwaitingPubAck = Just QoS1Published
validateQoS1 AwaitingPubAck QDComplete     = Just QoS1Acked
validateQoS1 AwaitingPubAck QDFailed       = Just QoS1AckFailed
validateQoS1 _              _              = Nothing

---------------------------------------------------------------------------
-- QoS 2 delivery state machine
---------------------------------------------------------------------------

||| QoS 2 delivery transitions.
||| Idle -> AwaitingPubRec -> AwaitingPubRel -> AwaitingPubComp -> Complete.
||| Each intermediate state can also transition to Failed on timeout.
public export
data ValidQoS2Transition : QoSDeliveryState -> QoSDeliveryState -> Type where
  ||| PUBLISH sent, now awaiting PUBREC.
  QoS2Published    : ValidQoS2Transition QDIdle AwaitingPubRec
  ||| PUBREC received, now awaiting PUBREL.
  QoS2Received     : ValidQoS2Transition AwaitingPubRec AwaitingPubRel
  ||| PUBREL sent, now awaiting PUBCOMP.
  QoS2Released     : ValidQoS2Transition AwaitingPubRel AwaitingPubComp
  ||| PUBCOMP received, delivery complete.
  QoS2Completed    : ValidQoS2Transition AwaitingPubComp QDComplete
  ||| Timeout or error while awaiting PUBREC.
  QoS2RecFailed    : ValidQoS2Transition AwaitingPubRec QDFailed
  ||| Timeout or error while awaiting PUBREL.
  QoS2RelFailed    : ValidQoS2Transition AwaitingPubRel QDFailed
  ||| Timeout or error while awaiting PUBCOMP.
  QoS2CompFailed   : ValidQoS2Transition AwaitingPubComp QDFailed

||| Validate a QoS 2 delivery transition.
public export
validateQoS2 : (from : QoSDeliveryState) -> (to : QoSDeliveryState)
            -> Maybe (ValidQoS2Transition from to)
validateQoS2 QDIdle          AwaitingPubRec  = Just QoS2Published
validateQoS2 AwaitingPubRec  AwaitingPubRel  = Just QoS2Received
validateQoS2 AwaitingPubRel  AwaitingPubComp = Just QoS2Released
validateQoS2 AwaitingPubComp QDComplete      = Just QoS2Completed
validateQoS2 AwaitingPubRec  QDFailed        = Just QoS2RecFailed
validateQoS2 AwaitingPubRel  QDFailed        = Just QoS2RelFailed
validateQoS2 AwaitingPubComp QDFailed        = Just QoS2CompFailed
validateQoS2 _               _               = Nothing

---------------------------------------------------------------------------
-- QoS impossibility proofs
---------------------------------------------------------------------------

||| Cannot skip from Idle directly to Complete in QoS 1.
public export
cannotSkipQoS1 : ValidQoS1Transition QDIdle QDComplete -> Void
cannotSkipQoS1 _ impossible

||| Cannot skip from Idle directly to Complete in QoS 2.
public export
cannotSkipQoS2 : ValidQoS2Transition QDIdle QDComplete -> Void
cannotSkipQoS2 _ impossible

||| Cannot skip from AwaitingPubRec directly to Complete in QoS 2.
public export
cannotSkipQoS2Mid : ValidQoS2Transition AwaitingPubRec QDComplete -> Void
cannotSkipQoS2Mid _ impossible

||| Complete is terminal in all QoS delivery machines.
public export
completeIsTerminalQoS1 : ValidQoS1Transition QDComplete s -> Void
completeIsTerminalQoS1 _ impossible

||| Complete is terminal in QoS 2.
public export
completeIsTerminalQoS2 : ValidQoS2Transition QDComplete s -> Void
completeIsTerminalQoS2 _ impossible

||| Failed is terminal in QoS 1.
public export
failedIsTerminalQoS1 : ValidQoS1Transition QDFailed s -> Void
failedIsTerminalQoS1 _ impossible

||| Failed is terminal in QoS 2.
public export
failedIsTerminalQoS2 : ValidQoS2Transition QDFailed s -> Void
failedIsTerminalQoS2 _ impossible
