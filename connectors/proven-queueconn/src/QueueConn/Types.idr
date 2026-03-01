-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- QueueConn.Types: Core type definitions for message queue connector
-- interfaces.  Closed sum types representing queue operations, delivery
-- guarantees, connection states, message lifecycle states, and error
-- categories.  These types enforce that any message queue backend
-- connector is type-safe at the boundary.

module QueueConn.Types

%default total

---------------------------------------------------------------------------
-- QueueOp — the operation being requested of the queue.
---------------------------------------------------------------------------

||| Operations that can be performed against a message queue backend.
public export
data QueueOp : Type where
  ||| Publish a message to a queue or exchange.
  Publish     : QueueOp
  ||| Subscribe to receive messages from a queue.
  Subscribe   : QueueOp
  ||| Acknowledge successful processing of a message.
  Acknowledge : QueueOp
  ||| Reject a message, optionally requesting redelivery.
  Reject      : QueueOp
  ||| Inspect the next message without removing it from the queue.
  Peek        : QueueOp
  ||| Remove all messages from a queue.
  Purge       : QueueOp

public export
Show QueueOp where
  show Publish     = "Publish"
  show Subscribe   = "Subscribe"
  show Acknowledge = "Acknowledge"
  show Reject      = "Reject"
  show Peek        = "Peek"
  show Purge       = "Purge"

---------------------------------------------------------------------------
-- DeliveryGuarantee — message delivery semantics.
---------------------------------------------------------------------------

||| The delivery guarantee level for message processing.
public export
data DeliveryGuarantee : Type where
  ||| Fire-and-forget.  Messages may be lost but never duplicated.
  AtMostOnce  : DeliveryGuarantee
  ||| Messages are guaranteed delivered but may arrive more than once.
  AtLeastOnce : DeliveryGuarantee
  ||| Messages are delivered exactly once (requires idempotency or
  ||| transactional coordination).
  ExactlyOnce : DeliveryGuarantee

public export
Show DeliveryGuarantee where
  show AtMostOnce  = "AtMostOnce"
  show AtLeastOnce = "AtLeastOnce"
  show ExactlyOnce = "ExactlyOnce"

---------------------------------------------------------------------------
-- QueueState — the state of a queue connection.
---------------------------------------------------------------------------

||| The lifecycle state of a message queue connection.
public export
data QueueState : Type where
  ||| No connection established to the queue backend.
  Disconnected : QueueState
  ||| Connection established and operational.
  Connected    : QueueState
  ||| Actively consuming messages from one or more queues.
  Consuming    : QueueState
  ||| Actively producing messages to one or more queues.
  Producing    : QueueState
  ||| Connection has entered a failed state.
  Failed       : QueueState

public export
Show QueueState where
  show Disconnected = "Disconnected"
  show Connected    = "Connected"
  show Consuming    = "Consuming"
  show Producing    = "Producing"
  show Failed       = "Failed"

---------------------------------------------------------------------------
-- MessageState — the lifecycle of a single message.
---------------------------------------------------------------------------

||| The lifecycle state of an individual message in the queue.
public export
data MessageState : Type where
  ||| The message is enqueued and awaiting delivery.
  Pending      : MessageState
  ||| The message has been delivered to a consumer but not yet acknowledged.
  Delivered    : MessageState
  ||| The consumer acknowledged successful processing.
  Acknowledged : MessageState
  ||| The consumer rejected the message.
  Rejected     : MessageState
  ||| The message exceeded its retry limit and was moved to a dead-letter
  ||| queue.
  DeadLettered : MessageState
  ||| The message's TTL has elapsed and it was discarded.
  Expired      : MessageState

public export
Show MessageState where
  show Pending      = "Pending"
  show Delivered    = "Delivered"
  show Acknowledged = "Acknowledged"
  show Rejected     = "Rejected"
  show DeadLettered = "DeadLettered"
  show Expired      = "Expired"

---------------------------------------------------------------------------
-- QueueError — queue operation error categories.
---------------------------------------------------------------------------

||| Error categories that a message queue connector can report.
public export
data QueueError : Type where
  ||| The connection to the queue backend was lost.
  ConnectionLost     : QueueError
  ||| The specified queue does not exist.
  QueueNotFound      : QueueError
  ||| The message body exceeds the maximum allowed size.
  MessageTooLarge    : QueueError
  ||| The queue or account quota has been exceeded.
  QuotaExceeded      : QueueError
  ||| The acknowledgement was not received within the timeout window.
  AckTimeout         : QueueError
  ||| The caller lacks permission for this operation.
  Unauthorized       : QueueError
  ||| The message body could not be serialised or deserialised.
  SerializationError : QueueError

public export
Show QueueError where
  show ConnectionLost     = "ConnectionLost"
  show QueueNotFound      = "QueueNotFound"
  show MessageTooLarge    = "MessageTooLarge"
  show QuotaExceeded      = "QuotaExceeded"
  show AckTimeout         = "AckTimeout"
  show Unauthorized       = "Unauthorized"
  show SerializationError = "SerializationError"
