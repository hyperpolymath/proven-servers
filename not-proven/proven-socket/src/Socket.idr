-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Socket: Top-level module for proven-socket.
-- Re-exports Socket.Types and provides socket-related constants.

module Socket

import public Socket.Types

%default total

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

||| Default TCP listen backlog size.
public export
defaultBacklog : Nat
defaultBacklog = 128

||| Maximum number of simultaneous connections.
public export
maxConnections : Nat
maxConnections = 65535
