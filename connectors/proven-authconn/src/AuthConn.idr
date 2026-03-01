-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AuthConn: Top-level module for proven-authconn.
-- Re-exports AuthConn.Types and provides authentication-related constants.

module AuthConn

import public AuthConn.Types

%default total

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

||| Maximum access token lifetime in seconds (1 hour).
public export
maxTokenLifetime : Nat
maxTokenLifetime = 3600

||| Maximum refresh token lifetime in seconds (24 hours).
public export
maxRefreshLifetime : Nat
maxRefreshLifetime = 86400

||| Maximum consecutive failed login attempts before lockout.
public export
maxLoginAttempts : Nat
maxLoginAttempts = 5

||| Account lockout duration in seconds (15 minutes).
public export
lockoutDuration : Nat
lockoutDuration = 900
