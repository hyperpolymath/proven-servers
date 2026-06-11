-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- NesySolverAPIABI.Foreign: Opaque handle types and C ABI function
-- signatures for proven-nesy-solver-api.
--
-- The Zig FFI layer (ffi/zig/src/nesy_solver_api.zig) implements these
-- signatures.  Any language that speaks C can call into the same layer.

module NesySolverAPIABI.Foreign

import NesySolverAPI.Types
import NesySolverAPIABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handles.
---------------------------------------------------------------------------

||| An opaque handle to a playground session owned by the Zig/C layer.
||| Treat this as a cookie: construct via `session_open`, destroy via
||| `session_close`.  Never dereference the pointer.
public export
data SessionHandle : Type where
  MkSessionHandle : AnyPtr -> SessionHandle

||| An opaque handle to a prover-dispatch context owned by the Zig/C
||| layer.  Obtained from `dispatch_begin` and released by
||| `dispatch_end`.
public export
data DispatchHandle : Type where
  MkDispatchHandle : AnyPtr -> DispatchHandle

||| Strongly-typed identifier (UUID v7 string).  Owned by the caller.
public export
AttemptId : Type
AttemptId = String

||| SHA-256 hex digest of the obligation content.
public export
ObligationId : Type
ObligationId = String

---------------------------------------------------------------------------
-- FFI function signatures (documentation only — Idris2 %foreign
-- declarations for actual calls live in downstream binding files).
---------------------------------------------------------------------------

||| Names of the C ABI functions exposed by ffi/zig/src/nesy_solver_api.zig.
||| Callers must match these names exactly.
public export
ffiFunctionNames : List String
ffiFunctionNames =
  [ "nesy_session_open"       -- () -> SessionHandle
  , "nesy_session_close"      -- SessionHandle -> ()
  , "nesy_dispatch_begin"     -- SessionHandle -> ProverKind tag -> InputLanguage tag
                              --   -> ObligationClass tag -> *const u8 (content)
                              --   -> usize (content_len) -> DispatchHandle
  , "nesy_dispatch_poll"      -- DispatchHandle -> ProveOutcome tag (0-3)
  , "nesy_dispatch_duration"  -- DispatchHandle -> u64 (ms)
  , "nesy_dispatch_end"       -- DispatchHandle -> ()
  , "nesy_obligation_hash"    -- *const u8, usize -> *mut u8 (64 hex chars)
  , "nesy_strategy_lookup"    -- ObligationClass tag -> ProverKind tag (top)
  , "nesy_record_attempt"     -- SessionHandle -> all fields... -> bool (ok)
  ]

||| Version of the C ABI.  Bump the major component on any
||| breaking change (tag reassignment, signature change, struct layout).
public export
abiVersionMajor : Nat
abiVersionMajor = 0

public export
abiVersionMinor : Nat
abiVersionMinor = 1
