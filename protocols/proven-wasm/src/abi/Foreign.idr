-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- WASMABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/wasm.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected module instance pool
--   - Function import/export registration
--   - Memory instance management (grow/size)
--   - Global variable tracking (with mutability enforcement)
--   - Table element storage
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching WASMABI.Types exactly.

module WASMABI.Foreign

import WASMABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a WASM module instance context.
||| Created by wasm_create(), destroyed by wasm_destroy().
export
data WASMContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match wasm_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | wasm_abi_version            | () -> u32                                 |
-- |                             | Returns ABI version (must equal           |
-- |                             | abiVersion).                              |
-- +-----------------------------+-------------------------------------------+
-- | wasm_create                 | () -> c_int                               |
-- |                             | Creates module instance in Unloaded       |
-- |                             | state. Returns -1 on failure.             |
-- +-----------------------------+-------------------------------------------+
-- | wasm_destroy                | (slot: c_int) -> void                     |
-- |                             | Releases a module instance slot.          |
-- +-----------------------------+-------------------------------------------+
-- | wasm_state                  | (slot: c_int) -> u8 (ModuleState tag)     |
-- |                             | Returns current module state.             |
-- +-----------------------------+-------------------------------------------+
-- | wasm_load                   | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Unloaded -> Loaded.           |
-- +-----------------------------+-------------------------------------------+
-- | wasm_instantiate            | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Loaded -> Instantiated.       |
-- +-----------------------------+-------------------------------------------+
-- | wasm_start                  | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Instantiated -> Running.      |
-- +-----------------------------+-------------------------------------------+
-- | wasm_trap                   | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Running -> Trapped.           |
-- +-----------------------------+-------------------------------------------+
-- | wasm_add_func               | (slot: c_int, name_ptr: [*]u8,           |
-- |                             |  name_len: u32, kind: u8,                 |
-- |                             |  param_count: u32, result_count: u32)     |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Registers a function (import or export).  |
-- +-----------------------------+-------------------------------------------+
-- | wasm_func_count             | (slot: c_int) -> u32                     |
-- |                             | Returns total registered functions.       |
-- +-----------------------------+-------------------------------------------+
-- | wasm_memory_grow            | (slot: c_int, pages: u32)                |
-- |                             | -> i32 (prev pages or -1 on failure)      |
-- |                             | Grows linear memory.                     |
-- +-----------------------------+-------------------------------------------+
-- | wasm_memory_size            | (slot: c_int) -> u32                     |
-- |                             | Returns current memory size in pages.    |
-- +-----------------------------+-------------------------------------------+
-- | wasm_add_global             | (slot: c_int, name_ptr: [*]u8,           |
-- |                             |  name_len: u32, val_type: u8, mut: u8)   |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Registers a global variable.             |
-- +-----------------------------+-------------------------------------------+
-- | wasm_global_count           | (slot: c_int) -> u32                     |
-- |                             | Returns total registered globals.        |
-- +-----------------------------+-------------------------------------------+
-- | wasm_can_transition         | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks module state            |
-- |                             | transition validity.                      |
-- +-----------------------------+-------------------------------------------+
-- | wasm_export_count           | (slot: c_int) -> u32                     |
-- |                             | Returns number of exports.               |
-- +-----------------------------+-------------------------------------------+
