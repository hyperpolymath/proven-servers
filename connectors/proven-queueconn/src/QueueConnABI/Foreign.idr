-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- QueueConnABI.Foreign: Foreign function declarations for the C bridge.

module QueueConnABI.Foreign

import QueueConn.Types
import QueueConnABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle types
---------------------------------------------------------------------------

||| Opaque handle to a queue connection.
export
data QueueHandle : Type where [external]

||| Opaque handle to a message.
export
data MessageHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-------------------------------+------------------------------------------------+
-- | Function                      | Signature                                      |
-- +-------------------------------+------------------------------------------------+
-- | queueconn_abi_version         | () -> Bits32                                   |
-- +-------------------------------+------------------------------------------------+
-- | queueconn_connect             | (host: Ptr, port: Bits16,                      |
-- |                               |  guarantee: Bits8, err: Ptr)                   |
-- |                               |  -> Ptr QueueHandle                            |
-- +-------------------------------+------------------------------------------------+
-- | queueconn_disconnect          | (h: Ptr QueueHandle) -> Bits8                  |
-- +-------------------------------+------------------------------------------------+
-- | queueconn_state               | (h: Ptr QueueHandle) -> Bits8                  |
-- +-------------------------------+------------------------------------------------+
-- | queueconn_subscribe           | (h: Ptr QueueHandle, queue: Ptr,               |
-- |                               |  queue_len: Bits32) -> Bits8                   |
-- |                               | Requires: CanSubscribe. -> Consuming.          |
-- +-------------------------------+------------------------------------------------+
-- | queueconn_unsubscribe         | (h: Ptr QueueHandle) -> Bits8                  |
-- |                               | Consuming -> Connected.                        |
-- +-------------------------------+------------------------------------------------+
-- | queueconn_publish             | (h: Ptr QueueHandle, queue: Ptr,               |
-- |                               |  queue_len: Bits32, body: Ptr,                 |
-- |                               |  body_len: Bits32) -> Bits8                    |
-- |                               | Connected -> Producing -> Connected.           |
-- +-------------------------------+------------------------------------------------+
-- | queueconn_receive             | (h: Ptr QueueHandle,                           |
-- |                               |  err: Ptr) -> Ptr MessageHandle                |
-- |                               | Requires: CanConsume.                          |
-- +-------------------------------+------------------------------------------------+
-- | queueconn_acknowledge         | (m: Ptr MessageHandle) -> Bits8                |
-- +-------------------------------+------------------------------------------------+
-- | queueconn_reject              | (m: Ptr MessageHandle,                         |
-- |                               |  requeue: Bits8) -> Bits8                      |
-- +-------------------------------+------------------------------------------------+
-- | queueconn_message_state       | (m: Ptr MessageHandle) -> Bits8                |
-- +-------------------------------+------------------------------------------------+
-- | queueconn_message_free        | (m: Ptr MessageHandle) -> ()                   |
-- +-------------------------------+------------------------------------------------+
