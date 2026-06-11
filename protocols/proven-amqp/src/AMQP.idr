-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- proven-amqp: An AMQP 0-9-1 implementation that cannot crash.
--
-- Architecture:
--   - Types: Frame types, method classes, exchange types, delivery modes,
--     error codes with severity classification
--   - Properties: Basic content properties (content-type, delivery-mode,
--     priority, correlation-id, etc.) with property flag calculation
--   - Exchange: Exchange declarations with routing key matching for
--     direct, fanout, and topic exchange types
--   - Queue: Queue declarations with durability/exclusivity proofs —
--     exclusive queues cannot be durable (compile-time enforcement)
--   - Session: Connection and channel state machines with dependent-type
--     transitions, virtual host isolation, consumer/delivery tag tracking,
--     QoS settings
--   - Frame: Frame structure with parse error types, method identification,
--     heartbeat/channel validation
--
-- This module defines the core AMQP types and re-exports submodules.

module AMQP

import public AMQP.Types
import public AMQP.Properties
import public AMQP.Exchange
import public AMQP.Queue
import public AMQP.Session
import public AMQP.Frame

%default total

||| Default AMQP TCP port (plaintext).
public export
amqpPort : Bits16
amqpPort = 5672

||| Default AMQPS TCP port (TLS).
public export
amqpsPort : Bits16
amqpsPort = 5671

||| AMQP 0-9-1 protocol version: major.
public export
protocolMajor : Bits8
protocolMajor = 0

||| AMQP 0-9-1 protocol version: minor.
public export
protocolMinor : Bits8
protocolMinor = 9

||| AMQP 0-9-1 protocol version: revision.
public export
protocolRevision : Bits8
protocolRevision = 1

||| Maximum frame size in bytes per AMQP 0-9-1 negotiation default.
public export
maxFrameSize : Nat
maxFrameSize = 131072

||| Default heartbeat interval in seconds.
public export
heartbeatInterval : Nat
heartbeatInterval = 60

||| AMQP protocol header (8 bytes): "AMQP" + 0 + major + minor + revision.
||| This is sent by the client as the very first data on the TCP connection.
public export
protocolHeader : List Bits8
protocolHeader = [0x41, 0x4D, 0x51, 0x50, 0, 0, 9, 1]
