-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DBConnABI: Top-level ABI module for proven-dbconn.
--
-- Re-exports all ABI sub-modules so that downstream consumers can
-- import a single module to get the complete ABI:
--
--   import DBConnABI
--
-- This brings into scope:
--   - Layout:      Bits8 tag encodings for all types, with roundtrip proofs
--   - Transitions: ValidTransition GADT, CanQuery/CanBeginTx witnesses,
--                  impossibility proofs, and decidability procedures
--   - Foreign:     Opaque handle types and FFI function contract

module DBConnABI

import public DBConnABI.Layout
import public DBConnABI.Foreign
import public DBConnABI.Transitions

%default total
