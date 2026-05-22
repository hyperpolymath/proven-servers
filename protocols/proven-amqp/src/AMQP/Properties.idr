-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AMQP 0-9-1 Message Properties (AMQP 0-9-1 Section 4.2.6)
--
-- Basic content properties carried in the content header frame.
-- These include content-type, delivery-mode, priority, correlation-id,
-- reply-to, expiration, message-id, timestamp, type, user-id, and app-id.
-- Priority is bounded 0-9 per the AMQP specification.

module AMQP.Properties

import AMQP.Types

%default total

-- ============================================================================
-- Priority (AMQP 0-9-1 Section 4.2.6 — bounded 0..9)
-- ============================================================================

||| AMQP message priority values, bounded 0-9 per specification.
||| We model this as a refinement type: the constructor requires proof
||| that the value is within the valid range.
public export
data Priority : Type where
  ||| Construct a priority from a Bits8 value.
  ||| Only values 0-9 are valid per AMQP 0-9-1.
  MkPriority : (val : Bits8) -> Priority

public export
Eq Priority where
  (MkPriority a) == (MkPriority b) = a == b

public export
Show Priority where
  show (MkPriority v) = "Priority " ++ show (cast {to=Nat} v)

||| Validate and construct a Priority from a raw byte.
||| Returns Nothing if the value exceeds 9.
public export
mkPriority : Bits8 -> Maybe Priority
mkPriority v = if v <= 9 then Just (MkPriority v) else Nothing

||| Extract the raw byte value from a Priority.
public export
priorityValue : Priority -> Bits8
priorityValue (MkPriority v) = v

||| Default priority (0 — lowest).
public export
defaultPriority : Priority
defaultPriority = MkPriority 0

-- ============================================================================
-- Timestamp
-- ============================================================================

||| AMQP timestamp: seconds since Unix epoch (1 January 1970 00:00:00 UTC).
||| Represented as a 64-bit unsigned integer per AMQP wire format.
public export
record AMQPTimestamp where
  constructor MkAMQPTimestamp
  ||| Seconds since Unix epoch.
  epochSeconds : Bits64

public export
Eq AMQPTimestamp where
  a == b = a.epochSeconds == b.epochSeconds

public export
Show AMQPTimestamp where
  show ts = "Timestamp(" ++ show (cast {to=Integer} ts.epochSeconds) ++ ")"

-- ============================================================================
-- Basic Properties (AMQP 0-9-1 Section 4.2.6)
-- ============================================================================

||| Complete set of AMQP Basic content properties.
||| All fields are optional (Maybe) — the property flags in the content
||| header indicate which are present on the wire.
public export
record BasicProperties where
  constructor MkBasicProperties
  ||| MIME content type (e.g., "application/json").
  contentType     : Maybe String
  ||| MIME content encoding (e.g., "gzip").
  contentEncoding : Maybe String
  ||| Application-specific header table (represented as key-value pairs).
  headers         : Maybe (List (String, String))
  ||| Message delivery mode (persistent or non-persistent).
  deliveryMode    : Maybe DeliveryMode
  ||| Message priority (0-9).
  priority        : Maybe Priority
  ||| Application-defined correlation identifier for RPC.
  correlationId   : Maybe String
  ||| Reply-to queue name for RPC responses.
  replyTo         : Maybe String
  ||| Message expiration as a string of milliseconds (TTL).
  expiration      : Maybe String
  ||| Application-defined message identifier.
  messageId       : Maybe String
  ||| Message timestamp (seconds since epoch).
  timestamp       : Maybe AMQPTimestamp
  ||| Application-defined message type name.
  msgType         : Maybe String
  ||| User identifier of the publishing connection.
  userId          : Maybe String
  ||| Application identifier for the publishing application.
  appId           : Maybe String

||| Construct empty BasicProperties (all fields Nothing).
public export
emptyProperties : BasicProperties
emptyProperties = MkBasicProperties
  { contentType     = Nothing
  , contentEncoding = Nothing
  , headers         = Nothing
  , deliveryMode    = Nothing
  , priority        = Nothing
  , correlationId   = Nothing
  , replyTo         = Nothing
  , expiration      = Nothing
  , messageId       = Nothing
  , timestamp       = Nothing
  , msgType         = Nothing
  , userId          = Nothing
  , appId           = Nothing
  }

-- ============================================================================
-- Property flag calculation
-- ============================================================================

||| AMQP property flag bits per AMQP 0-9-1 Basic class.
||| Each bit corresponds to a property field being present.
||| Bit 15 = content-type, Bit 14 = content-encoding, ..., Bit 3 = app-id.
public export
propertyFlags : BasicProperties -> Bits16
propertyFlags p =
  let b15 = case p.contentType     of Nothing => 0; Just _ => 0x8000
      b14 = case p.contentEncoding of Nothing => 0; Just _ => 0x4000
      b13 = case p.headers         of Nothing => 0; Just _ => 0x2000
      b12 = case p.deliveryMode    of Nothing => 0; Just _ => 0x1000
      b11 = case p.priority        of Nothing => 0; Just _ => 0x0800
      b10 = case p.correlationId   of Nothing => 0; Just _ => 0x0400
      b9  = case p.replyTo         of Nothing => 0; Just _ => 0x0200
      b8  = case p.expiration      of Nothing => 0; Just _ => 0x0100
      b7  = case p.messageId       of Nothing => 0; Just _ => 0x0080
      b6  = case p.timestamp       of Nothing => 0; Just _ => 0x0040
      b5  = case p.msgType         of Nothing => 0; Just _ => 0x0020
      b4  = case p.userId          of Nothing => 0; Just _ => 0x0010
      b3  = case p.appId           of Nothing => 0; Just _ => 0x0008
  in prim__or_Bits16 b15 (prim__or_Bits16 b14 (prim__or_Bits16 b13
     (prim__or_Bits16 b12 (prim__or_Bits16 b11 (prim__or_Bits16 b10
     (prim__or_Bits16 b9 (prim__or_Bits16 b8 (prim__or_Bits16 b7
     (prim__or_Bits16 b6 (prim__or_Bits16 b5 (prim__or_Bits16 b4 b3)))))))))))

||| Count the number of properties set.
public export
propertyCount : BasicProperties -> Nat
propertyCount p =
  let ct = case p.contentType     of Nothing => 0; Just _ => 1
      ce = case p.contentEncoding of Nothing => 0; Just _ => 1
      hd = case p.headers         of Nothing => 0; Just _ => 1
      dm = case p.deliveryMode    of Nothing => 0; Just _ => 1
      pr = case p.priority        of Nothing => 0; Just _ => 1
      ci = case p.correlationId   of Nothing => 0; Just _ => 1
      rt = case p.replyTo         of Nothing => 0; Just _ => 1
      ex = case p.expiration      of Nothing => 0; Just _ => 1
      mi = case p.messageId       of Nothing => 0; Just _ => 1
      ts = case p.timestamp       of Nothing => 0; Just _ => 1
      mt = case p.msgType         of Nothing => 0; Just _ => 1
      ui = case p.userId          of Nothing => 0; Just _ => 1
      ai = case p.appId           of Nothing => 0; Just _ => 1
  in ct + ce + hd + dm + pr + ci + rt + ex + mi + ts + mt + ui + ai
