-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Audit: Top-level module for proven-audit.
-- Re-exports Audit.Types and provides audit-related constants.

module Audit

import public Audit.Types

%default total

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

||| Maximum audit event size in bytes (64 KiB).
public export
maxEventSize : Nat
maxEventSize = 65536

||| Default retention period in days.
public export
defaultRetention : Nat
defaultRetention = 90

||| The hash algorithm used for audit chain integrity.
public export
chainAlgorithm : String
chainAlgorithm = "SHA-256"
