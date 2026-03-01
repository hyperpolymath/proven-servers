-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AuthConnABI: Top-level ABI module for proven-authconn.
--
-- Re-exports all ABI sub-modules so that downstream consumers can
-- import a single module to get the complete ABI:
--
--   import AuthConnABI
--
-- This brings into scope:
--   - Layout:      Bits8 tag encodings for all types, with roundtrip proofs
--   - Transitions: ValidTransition GADT, CanAuthenticate/CanAccessResource
--                  witnesses, impossibility proofs, and decidability procedures
--   - Foreign:     Opaque handle types and FFI function contract

module AuthConnABI

import public AuthConnABI.Layout
import public AuthConnABI.Foreign
import public AuthConnABI.Transitions

%default total
