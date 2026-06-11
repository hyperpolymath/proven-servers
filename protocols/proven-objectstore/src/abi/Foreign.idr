-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- ObjectstoreABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/objectstore.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected session pool
--   - Bucket registry (max 32 buckets per session)
--   - Object metadata tracking per bucket (max 256 objects)
--   - Multipart upload state (max 8 concurrent uploads)
--   - ACL enforcement per bucket/object
--   - Storage class assignment
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching ObjectstoreABI.Types exactly.

module ObjectstoreABI.Foreign

import ObjectstoreABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an object store session.
||| Created by objectstore_create(), destroyed by objectstore_destroy().
export
data ObjectstoreContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match objectstore_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature                               |
-- +-------------------------------+-----------------------------------------+
-- | objectstore_abi_version       | () -> u32                               |
-- +-------------------------------+-----------------------------------------+
-- | objectstore_create            | (region_ptr: ptr, region_len: u32)      |
-- |                               |  -> c_int (slot)                        |
-- |                               | Creates session in Ready state.         |
-- +-------------------------------+-----------------------------------------+
-- | objectstore_destroy           | (slot: c_int) -> void                   |
-- +-------------------------------+-----------------------------------------+
-- | objectstore_state             | (slot: c_int) -> u8 (SessionState tag)  |
-- +-------------------------------+-----------------------------------------+
-- | objectstore_create_bucket     | (slot: c_int, name_ptr: ptr,            |
-- |                               |  name_len: u32, acl: u8)               |
-- |                               |  -> u8 (0=ok, 1=rejected)               |
-- +-------------------------------+-----------------------------------------+
-- | objectstore_delete_bucket     | (slot: c_int, name_ptr: ptr,            |
-- |                               |  name_len: u32) -> u8                   |
-- +-------------------------------+-----------------------------------------+
-- | objectstore_select_bucket     | (slot: c_int, name_ptr: ptr,            |
-- |                               |  name_len: u32) -> u8                   |
-- |                               | Transitions Ready -> BucketActive.      |
-- +-------------------------------+-----------------------------------------+
-- | objectstore_put_object        | (slot: c_int, key_ptr: ptr,             |
-- |                               |  key_len: u32, body_ptr: ptr,           |
-- |                               |  body_len: u32, storage_class: u8)      |
-- |                               |  -> u8 (0=ok, 1=rejected)               |
-- +-------------------------------+-----------------------------------------+
-- | objectstore_get_object        | (slot: c_int, key_ptr: ptr,             |
-- |                               |  key_len: u32) -> u8                    |
-- +-------------------------------+-----------------------------------------+
-- | objectstore_delete_object     | (slot: c_int, key_ptr: ptr,             |
-- |                               |  key_len: u32) -> u8                    |
-- +-------------------------------+-----------------------------------------+
-- | objectstore_head_object       | (slot: c_int, key_ptr: ptr,             |
-- |                               |  key_len: u32) -> u8 (1=exists, 0=no)  |
-- +-------------------------------+-----------------------------------------+
-- | objectstore_init_multipart    | (slot: c_int, key_ptr: ptr,             |
-- |                               |  key_len: u32) -> u8                    |
-- |                               | Transitions BucketActive -> Uploading.  |
-- +-------------------------------+-----------------------------------------+
-- | objectstore_complete_multipart| (slot: c_int) -> u8                     |
-- |                               | Transitions Uploading -> BucketActive.  |
-- +-------------------------------+-----------------------------------------+
-- | objectstore_bucket_count      | (slot: c_int) -> u32                    |
-- +-------------------------------+-----------------------------------------+
-- | objectstore_close             | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- +-------------------------------+-----------------------------------------+
-- | objectstore_cleanup           | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                               | Transitions Closing -> Idle.            |
-- +-------------------------------+-----------------------------------------+
