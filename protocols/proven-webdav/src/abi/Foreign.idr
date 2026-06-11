-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- WebDAVABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/webdav.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected resource pool
--   - Lock management (scope, type, depth, timeout)
--   - Property storage and PROPPATCH operations
--   - Collection (MKCOL) and copy/move tracking
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching WebDAVABI.Types exactly.

module WebDAVABI.Foreign

import WebDAVABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a WebDAV resource context.
||| Created by webdav_create(), destroyed by webdav_destroy().
export
data WebDAVContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match webdav_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | webdav_abi_version          | () -> u32                                 |
-- |                             | Returns ABI version (must equal           |
-- |                             | abiVersion).                              |
-- +-----------------------------+-------------------------------------------+
-- | webdav_create               | (path_ptr: [*]u8, path_len: u32)         |
-- |                             | -> c_int                                  |
-- |                             | Creates resource entry. Returns -1 on     |
-- |                             | failure.                                  |
-- +-----------------------------+-------------------------------------------+
-- | webdav_destroy              | (slot: c_int) -> void                     |
-- |                             | Releases a resource slot.                 |
-- +-----------------------------+-------------------------------------------+
-- | webdav_lock                 | (slot: c_int, scope: u8, depth: u8,      |
-- |                             |  timeout: u32)                            |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Acquires a lock on the resource.          |
-- +-----------------------------+-------------------------------------------+
-- | webdav_unlock               | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Releases the lock on the resource.        |
-- +-----------------------------+-------------------------------------------+
-- | webdav_is_locked            | (slot: c_int) -> u8 (1=locked, 0=not)    |
-- |                             | Returns whether resource is locked.       |
-- +-----------------------------+-------------------------------------------+
-- | webdav_lock_scope           | (slot: c_int) -> u8 (LockScope tag)      |
-- |                             | Returns lock scope tag.                   |
-- +-----------------------------+-------------------------------------------+
-- | webdav_set_property         | (slot: c_int, name_ptr: [*]u8,           |
-- |                             |  name_len: u32, val_ptr: [*]u8,          |
-- |                             |  val_len: u32)                            |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Sets a property on the resource.          |
-- +-----------------------------+-------------------------------------------+
-- | webdav_remove_property      | (slot: c_int, name_ptr: [*]u8,           |
-- |                             |  name_len: u32)                           |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Removes a property from the resource.     |
-- +-----------------------------+-------------------------------------------+
-- | webdav_property_count       | (slot: c_int) -> u32                     |
-- |                             | Returns number of properties.            |
-- +-----------------------------+-------------------------------------------+
-- | webdav_mkcol                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Marks resource as collection.             |
-- +-----------------------------+-------------------------------------------+
-- | webdav_is_collection        | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- |                             | Returns whether resource is a collection. |
-- +-----------------------------+-------------------------------------------+
-- | webdav_copy                 | (src: c_int, dst: c_int, depth: u8)      |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Copies resource properties.               |
-- +-----------------------------+-------------------------------------------+
-- | webdav_move                 | (src: c_int, dst: c_int)                 |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Moves resource to new slot.               |
-- +-----------------------------+-------------------------------------------+
