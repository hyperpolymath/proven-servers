-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SocketABI: Top-level ABI module for proven-socket.
--
-- Re-exports all ABI sub-modules so that downstream consumers can
-- import a single module to get the complete ABI:
--
--   import SocketABI
--
-- This brings into scope:
--   - Layout:      Bits8 tag encodings for all types, with roundtrip proofs
--   - Transitions: ValidTransition GADT, CanSendRecv/CanBind/CanListen/
--                  CanAccept witnesses, impossibility proofs, decidability
--   - Foreign:     Opaque handle types and FFI function contract

module SocketABI

import public SocketABI.Layout
import public SocketABI.Foreign
import public SocketABI.Transitions

%default total
