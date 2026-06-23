-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- TimestampABI.Foreign: foreign-function declarations for the C bridge and
-- the complete FFI contract the Zig engine (ffi/zig/src/timestamp.zig) must
-- provide.
--
-- The Zig engine manages a mutex-protected pool of append-only receipt
-- logs.  It stores ONLY hashes and metadata — never document contents.
-- Every function uses the C calling convention and communicates enum values
-- via Bits8 tags matching TimestampABI.Types exactly.

module TimestampABI.Foreign

import TimestampABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle
---------------------------------------------------------------------------

||| Opaque handle to a timestamp-log session.
||| Created by ts_create(), released by ts_destroy().
export
data TimestampContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match ts_abi_version() in the Zig engine.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature / behaviour                     |
-- +-----------------------------+-------------------------------------------+
-- | ts_abi_version              | () -> u32. Returns ABI version.           |
-- +-----------------------------+-------------------------------------------+
-- | ts_hash                     | (algo:u8, data:ptr, len:usize,            |
-- |                             |  out_hex:ptr, cap:usize) -> i32           |
-- |                             | Hash data with `algo`, write lowercase    |
-- |                             | hex to out_hex; return hex length or -1.  |
-- |                             | Data is hashed and discarded, not stored. |
-- +-----------------------------+-------------------------------------------+
-- | ts_now_iso8601              | (out:ptr, cap:usize) -> i32               |
-- |                             | Current UTC time as ISO-8601 ("...Z").    |
-- +-----------------------------+-------------------------------------------+
-- | ts_create                   | (name:ptr, name_len:u32) -> c_int (slot)  |
-- |                             | New log in Active state; -1 on failure.   |
-- +-----------------------------+-------------------------------------------+
-- | ts_destroy                  | (slot:c_int) -> void                      |
-- +-----------------------------+-------------------------------------------+
-- | ts_state                    | (slot:c_int) -> u8 (ServerState tag)      |
-- +-----------------------------+-------------------------------------------+
-- | ts_append                   | (slot, algo:u8, content_hash_hex:ptr,len, |
-- |                             |  created_at:ptr,len, label:ptr,len,       |
-- |                             |  reference:ptr,len, out_id:*u64,          |
-- |                             |  out_receipt_hex:ptr, cap) -> u8 (status) |
-- |                             | Append a receipt: compute receipt_hash    |
-- |                             | over the canonical pre-image (linking to  |
-- |                             | the previous receipt) and store it.       |
-- |                             | 0=ok, 1=rejected (bad input / not Active),|
-- |                             | 2=full.                                   |
-- +-----------------------------+-------------------------------------------+
-- | ts_count                    | (slot) -> u32. Number of receipts.        |
-- +-----------------------------+-------------------------------------------+
-- | ts_get_receipt_hash         | (slot, index:u32, out:ptr, cap) -> i32    |
-- | ts_get_prev_hash            | (slot, index:u32, out:ptr, cap) -> i32    |
-- | ts_get_content_hash         | (slot, index:u32, out:ptr, cap) -> i32    |
-- |                             | Field getters for GET /api/receipt/:id.   |
-- +-----------------------------+-------------------------------------------+
-- | ts_verify_chain             | (slot) -> u8 (VerificationResult tag)     |
-- |                             | Re-derive every receipt_hash and check    |
-- |                             | each link; detects any tampering.         |
-- +-----------------------------+-------------------------------------------+
-- | ts_verify_content           | (slot, index:u32, algo:u8, data:ptr,len)  |
-- |                             |  -> u8 (VerificationResult tag)           |
-- |                             | Re-hash supplied content and compare to   |
-- |                             | the stored content_hash (for /verify).    |
-- +-----------------------------+-------------------------------------------+
-- | ts_seal / ts_reopen         | (slot) -> u8 (0=ok,1=rejected). FSM moves.|
-- | ts_shutdown / ts_cleanup    | (slot) -> u8 (0=ok,1=rejected). FSM moves.|
-- +-----------------------------+-------------------------------------------+
-- | ts_can_transition           | (from:u8, to:u8) -> u8 (1/0). Stateless.  |
-- +-----------------------------+-------------------------------------------+

-- TODO(rfc3161): a future `ts_append_rfc3161` variant (or an extra source
-- argument) would attach an external TSA token and set the source tag to 1.
