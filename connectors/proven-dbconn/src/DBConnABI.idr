-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
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
