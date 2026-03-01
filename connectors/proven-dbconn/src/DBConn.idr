-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DBConn: Top-level module for proven-dbconn.
-- Re-exports DBConn.Types and provides database-related constants.

module DBConn

import public DBConn.Types

%default total

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

||| Default PostgreSQL port.
public export
defaultPort : Nat
defaultPort = 5432

||| Maximum number of connections in a pool.
public export
maxPoolSize : Nat
maxPoolSize = 100

||| Default query timeout in seconds.
public export
queryTimeout : Nat
queryTimeout = 30

||| Maximum number of parameters in a single prepared statement.
||| Matches PostgreSQL's internal limit for bind parameters.
public export
maxParamCount : Nat
maxParamCount = 65535
