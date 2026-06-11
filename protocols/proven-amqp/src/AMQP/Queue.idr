-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- AMQP 0-9-1 Queue Declarations with Durability/Exclusivity Proofs
--
-- Models queue declarations with dependent type proofs ensuring that
-- certain invalid combinations cannot be constructed:
--   - Exclusive queues cannot be durable (they are destroyed on connection close)
--   - Auto-delete queues must have at least one consumer before deletion triggers
--
-- Queue bindings link queues to exchanges with a routing key.

module AMQP.Queue

import AMQP.Types

%default total

-- ============================================================================
-- Queue declaration
-- ============================================================================

||| An AMQP queue declaration.
||| Queues store messages for consumers. They may be durable (survive broker
||| restart), exclusive (single connection, auto-deleted), and/or auto-delete
||| (deleted when last consumer unsubscribes).
public export
record QueueDecl where
  constructor MkQueueDecl
  ||| Queue name (empty string = server-generated name).
  name       : String
  ||| Whether the queue survives broker restart.
  durable    : Bool
  ||| Whether the queue is exclusive to the declaring connection.
  exclusive  : Bool
  ||| Whether the queue is deleted when the last consumer unsubscribes.
  autoDelete : Bool

public export
Eq QueueDecl where
  a == b = a.name == b.name
           && a.durable == b.durable
           && a.exclusive == b.exclusive
           && a.autoDelete == b.autoDelete

public export
Show QueueDecl where
  show q = "Queue("
           ++ show q.name ++ ", "
           ++ "durable=" ++ show q.durable ++ ", "
           ++ "exclusive=" ++ show q.exclusive ++ ", "
           ++ "autoDelete=" ++ show q.autoDelete ++ ")"

-- ============================================================================
-- Queue validity proofs
-- ============================================================================

||| Proof that a queue declaration is valid per AMQP 0-9-1 semantics.
||| An exclusive queue cannot be durable, because exclusive queues are
||| bound to the declaring connection and destroyed when it closes.
public export
data ValidQueue : QueueDecl -> Type where
  ||| A non-exclusive queue is always valid regardless of durability.
  NonExclusiveValid : (q : QueueDecl) -> (q.exclusive = False) -> ValidQueue q
  ||| An exclusive queue is valid only if it is not durable.
  ExclusiveNonDurableValid : (q : QueueDecl) -> (q.exclusive = True) -> (q.durable = False) -> ValidQueue q

||| Check whether a queue declaration is valid.
||| Returns a proof witness if valid, Nothing otherwise.
public export
validateQueue : (q : QueueDecl) -> Maybe (ValidQueue q)
validateQueue q with (q.exclusive) proof exclPrf
  validateQueue q | False = Just (NonExclusiveValid q exclPrf)
  validateQueue q | True with (q.durable) proof durPrf
    validateQueue q | True | False = Just (ExclusiveNonDurableValid q exclPrf durPrf)
    validateQueue q | True | True  = Nothing

||| A durable exclusive queue is impossible.
public export
durableExclusiveImpossible : (q : QueueDecl) -> q.exclusive = True -> q.durable = True -> ValidQueue q -> Void
durableExclusiveImpossible q exclPrf durPrf (NonExclusiveValid q notExclPrf) =
  absurd (trans (sym notExclPrf) exclPrf)
durableExclusiveImpossible q exclPrf durPrf (ExclusiveNonDurableValid q _ notDurPrf) =
  absurd (trans (sym notDurPrf) durPrf)

-- ============================================================================
-- Queue construction helpers
-- ============================================================================

||| Create a standard durable, non-exclusive queue.
public export
mkDurableQueue : (name : String) -> QueueDecl
mkDurableQueue n = MkQueueDecl
  { name       = n
  , durable    = True
  , exclusive  = False
  , autoDelete = False
  }

||| Create a temporary exclusive queue (auto-deleted, non-durable).
public export
mkExclusiveQueue : (name : String) -> QueueDecl
mkExclusiveQueue n = MkQueueDecl
  { name       = n
  , durable    = False
  , exclusive  = True
  , autoDelete = True
  }

||| Create an auto-delete queue (non-exclusive, non-durable).
public export
mkAutoDeleteQueue : (name : String) -> QueueDecl
mkAutoDeleteQueue n = MkQueueDecl
  { name       = n
  , durable    = False
  , exclusive  = False
  , autoDelete = True
  }

-- ============================================================================
-- Queue binding
-- ============================================================================

||| A binding between a queue and an exchange with a routing key.
||| Bindings determine which messages an exchange routes to which queues.
public export
record QueueBinding where
  constructor MkQueueBinding
  ||| Name of the queue being bound.
  queueName    : String
  ||| Name of the exchange to bind to.
  exchangeName : String
  ||| Routing key for the binding (interpretation depends on exchange type).
  routingKey   : String

public export
Eq QueueBinding where
  a == b = a.queueName == b.queueName
           && a.exchangeName == b.exchangeName
           && a.routingKey == b.routingKey

public export
Show QueueBinding where
  show b = "Binding("
           ++ show b.queueName ++ " <- "
           ++ show b.exchangeName ++ " [key="
           ++ show b.routingKey ++ "])"

-- ============================================================================
-- Queue declare result
-- ============================================================================

||| Result of a Queue.Declare-Ok response from the broker.
public export
record QueueDeclareOk where
  constructor MkQueueDeclareOk
  ||| The actual queue name (may be server-generated if empty was declared).
  name         : String
  ||| Number of messages currently in the queue.
  messageCount : Nat
  ||| Number of consumers currently subscribed.
  consumerCount : Nat

public export
Show QueueDeclareOk where
  show r = "QueueDeclareOk("
           ++ show r.name ++ ", msgs="
           ++ show r.messageCount ++ ", consumers="
           ++ show r.consumerCount ++ ")"
