-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- QueueConn: Top-level module for proven-queueconn.
-- Re-exports QueueConn.Types and provides message-queue-related constants.

module QueueConn

import public QueueConn.Types

%default total

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

||| Maximum message body size in bytes (1 MiB).
public export
maxMessageSize : Nat
maxMessageSize = 1048576

||| Default prefetch count — how many unacknowledged messages a consumer
||| may hold at once.
public export
defaultPrefetch : Nat
defaultPrefetch = 10

||| Default acknowledgement timeout in seconds.  If a message is not
||| acknowledged within this window it will be re-delivered.
public export
ackTimeout : Nat
ackTimeout = 30
