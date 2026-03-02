-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FrameABI.Foreign: Foreign function declarations for the C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle types (FrameParser) that cannot be inspected or
--      forged from Idris2 code -- they exist only as pointers managed
--      by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function frame_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.
--
-- The opaque handle pattern ensures that:
--   - Idris2 code cannot construct a FrameParser out of thin air
--   - Idris2 code cannot inspect the internal representation
--   - Lifetime management is handled entirely by the Zig allocator
--   - The type checker can still track handles through the program

module FrameABI.Foreign

import Frame.Types
import FrameABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle types
---------------------------------------------------------------------------

||| Opaque handle to a frame parser.
||| This type has no Idris2-visible constructors -- values can only be
||| created by the Zig FFI via frame_parser_create() and destroyed via
||| frame_parser_destroy().
export
data FrameParser : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
||| The Zig implementation's frame_abi_version() function MUST return
||| this exact value.
|||
||| Increment this value whenever:
|||   - A new function is added to the FFI
|||   - An existing function signature changes
|||   - Tag values in Layout.idr change
|||   - Handle semantics change
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- The following documents the complete set of C-ABI functions that the
-- Zig implementation (ffi/zig/src/frame.zig) must export.
--
-- These are DECLARATIONS ONLY -- no %foreign annotations yet.
--
-- +-----------------------------------------------------------------------+
-- | Function                | Signature                                   |
-- +-------------------------+---------------------------------------------+
-- | frame_abi_version       | () -> Bits32                                |
-- |                         | Must return abiVersion (currently 1).       |
-- +-------------------------+---------------------------------------------+
-- | frame_parser_create     | (strategy: Bits8, delimiter: Bits8,         |
-- |                         |  length_enc: Bits8, max_size: Bits32,       |
-- |                         |  err: Ptr) -> Ptr FrameParser               |
-- |                         | Creates parser in AwaitingHeader state.     |
-- |                         | Returns NULL on failure, sets *err.          |
-- +-------------------------+---------------------------------------------+
-- | frame_parser_state      | (p: Ptr FrameParser) -> Bits8               |
-- |                         | Returns FrameState tag.                      |
-- |                         | Returns Failed (3) if p is NULL.             |
-- +-------------------------+---------------------------------------------+
-- | frame_feed              | (p: Ptr FrameParser, buf: Ptr,              |
-- |                         |  len: Bits32) -> Bits8                      |
-- |                         | Requires: CanDecode state.                   |
-- |                         | Feeds data into the parser.                  |
-- |                         | Returns FrameError tag (0 = success).        |
-- |                         | May transition to AwaitingPayload, Complete, |
-- |                         | or Failed depending on strategy and data.    |
-- +-------------------------+---------------------------------------------+
-- | frame_emit              | (p: Ptr FrameParser, out_buf: Ptr,          |
-- |                         |  out_len: Ptr Bits32) -> Bits8              |
-- |                         | Requires: Complete state (CanEmit).          |
-- |                         | Copies the assembled frame to out_buf.       |
-- |                         | Returns FrameError tag (0 = success).        |
-- +-------------------------+---------------------------------------------+
-- | frame_reset             | (p: Ptr FrameParser) -> Bits8               |
-- |                         | Requires: CanReset state.                    |
-- |                         | Transitions: Complete|Failed -> AwaitingHdr. |
-- |                         | Returns FrameError tag (0 = success).        |
-- +-------------------------+---------------------------------------------+
-- | frame_parser_destroy    | (p: Ptr FrameParser) -> ()                  |
-- |                         | Frees the parser.  Safe with NULL.           |
-- +-------------------------+---------------------------------------------+
