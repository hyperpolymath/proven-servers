-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AMQP 0-9-1 Exchange Declarations
--
-- Models exchange declarations with durability and auto-delete properties.
-- Default exchanges (direct, fanout, topic, headers) are provided with
-- their standard names per AMQP 0-9-1 Section 3.1.3.
-- Routing key matching functions enforce the exchange-type-specific
-- routing semantics at the type level.

module AMQP.Exchange

import AMQP.Types

%default total

-- ============================================================================
-- Exchange declaration
-- ============================================================================

||| An AMQP exchange declaration.
||| Exchanges receive messages from publishers and route them to queues
||| based on bindings and routing keys.
public export
record ExchangeDecl where
  constructor MkExchangeDecl
  ||| Exchange name (empty string = default exchange).
  name       : String
  ||| Exchange type (direct, fanout, topic, headers).
  exchType   : ExchangeType
  ||| Whether the exchange survives broker restart.
  durable    : Bool
  ||| Whether the exchange is deleted when all queues unbind.
  autoDelete : Bool
  ||| Whether the exchange is internal (cannot be published to directly).
  internal   : Bool

public export
Eq ExchangeDecl where
  a == b = a.name == b.name
           && a.exchType == b.exchType
           && a.durable == b.durable
           && a.autoDelete == b.autoDelete
           && a.internal == b.internal

public export
Show ExchangeDecl where
  show e = "Exchange("
           ++ show e.name ++ ", "
           ++ show e.exchType ++ ", "
           ++ "durable=" ++ show e.durable ++ ", "
           ++ "autoDelete=" ++ show e.autoDelete ++ ", "
           ++ "internal=" ++ show e.internal ++ ")"

-- ============================================================================
-- Default exchanges (AMQP 0-9-1 Section 3.1.3.1-3.1.3.4)
-- ============================================================================

||| The default direct exchange (empty name).
||| Every queue is automatically bound to this exchange with its queue name
||| as the routing key.
public export
defaultExchange : ExchangeDecl
defaultExchange = MkExchangeDecl
  { name       = ""
  , exchType   = Direct
  , durable    = True
  , autoDelete = False
  , internal   = False
  }

||| The standard "amq.direct" exchange.
public export
amqDirect : ExchangeDecl
amqDirect = MkExchangeDecl
  { name       = "amq.direct"
  , exchType   = Direct
  , durable    = True
  , autoDelete = False
  , internal   = False
  }

||| The standard "amq.fanout" exchange.
public export
amqFanout : ExchangeDecl
amqFanout = MkExchangeDecl
  { name       = "amq.fanout"
  , exchType   = Fanout
  , durable    = True
  , autoDelete = False
  , internal   = False
  }

||| The standard "amq.topic" exchange.
public export
amqTopic : ExchangeDecl
amqTopic = MkExchangeDecl
  { name       = "amq.topic"
  , exchType   = Topic
  , durable    = True
  , autoDelete = False
  , internal   = False
  }

||| The standard "amq.headers" exchange.
public export
amqHeaders : ExchangeDecl
amqHeaders = MkExchangeDecl
  { name       = "amq.headers"
  , exchType   = Headers
  , durable    = True
  , autoDelete = False
  , internal   = False
  }

-- ============================================================================
-- Routing key matching
-- ============================================================================

||| Split a routing key or binding pattern into segments by '.'.
public export
splitRoutingKey : String -> List String
splitRoutingKey s = map pack (splitOn '.' (unpack s))
  where
    splitOn : Char -> List Char -> List (List Char)
    splitOn _   [] = [[]]
    splitOn sep (c :: cs) =
      if c == sep
        then [] :: splitOn sep cs
        else case splitOn sep cs of
               []        => [[c]]
               (w :: ws) => (c :: w) :: ws

||| Match a routing key against a binding pattern for topic exchanges.
||| Supports '*' (single word) and '#' (zero or more words) wildcards.
||| AMQP 0-9-1 Section 3.1.3.3.
public export
topicMatch : (routingKey : String) -> (pattern : String) -> Bool
topicMatch key pat = matchWords (splitRoutingKey key) (splitRoutingKey pat)
  where
    matchWords : List String -> List String -> Bool
    matchWords []       []          = True
    matchWords _        ["#"]       = True
    matchWords []       _           = False
    matchWords (_ :: ks) ("*" :: ps) = matchWords ks ps
    matchWords (k :: ks) (p :: ps) =
      if k == p then matchWords ks ps else False
    matchWords _ _ = False

||| Match a routing key against a binding key for direct exchanges.
||| Direct exchanges require exact match.
public export
directMatch : (routingKey : String) -> (bindingKey : String) -> Bool
directMatch rk bk = rk == bk

||| Check if routing would deliver a message on a fanout exchange.
||| Fanout exchanges always deliver to all bound queues.
public export
fanoutMatch : (routingKey : String) -> (bindingKey : String) -> Bool
fanoutMatch _ _ = True
