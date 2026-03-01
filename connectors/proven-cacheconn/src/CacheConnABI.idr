-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CacheConnABI: Top-level ABI module for proven-cacheconn.
--
-- Re-exports all ABI sub-modules:
--   - Layout:      Bits8 tag encodings for all types, with roundtrip proofs
--   - Transitions: ValidTransition GADT, CanOperate/CanFlush witnesses
--   - Foreign:     Opaque handle types and FFI function contract

module CacheConnABI

import public CacheConnABI.Layout
import public CacheConnABI.Foreign
import public CacheConnABI.Transitions

%default total
