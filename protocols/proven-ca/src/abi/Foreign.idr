-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CaABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/ca.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching CaABI.Types exactly.

module CaABI.Foreign

import CaABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Ca context.
||| Created by ca_create*(), destroyed by ca_destroy*().
export
data CaContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match ca_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (35 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | ca_abi_version                    | () -> u32                                   |
-- | ca_create                         | () -> c_int                                 |
-- | ca_destroy                        | (slot: c_int) -> void                       |
-- | ca_issue_cert                     | (slot: c_int, cert_type_tag: u8, key_alg... |
-- | ca_sign_cert                      | (slot: c_int, cert_id: c_int) -> u8         |
-- | ca_revoke_cert                    | (slot: c_int, cert_id: c_int, reason_tag... |
-- | ca_suspend_cert                   | (slot: c_int, cert_id: c_int) -> u8         |
-- | ca_reinstate_cert                 | (slot: c_int, cert_id: c_int) -> u8         |
-- | ca_expire_cert                    | (slot: c_int, cert_id: c_int) -> u8         |
-- | ca_renew_cert                     | (slot: c_int, cert_id: c_int) -> c_int      |
-- | ca_cert_state                     | (slot: c_int, cert_id: c_int) -> u8         |
-- | ca_cert_type                      | (slot: c_int, cert_id: c_int) -> u8         |
-- | ca_cert_key_algo                  | (slot: c_int, cert_id: c_int) -> u8         |
-- | ca_cert_sig_algo                  | (slot: c_int, cert_id: c_int) -> u8         |
-- | ca_cert_count                     | (slot: c_int) -> c_int                      |
-- | ca_validate_chain                 | (slot: c_int, cert_id: c_int) -> u8         |
-- | ca_set_issuer                     | (slot: c_int, cert_id: c_int, issuer_id:... |
-- | ca_cert_issuer                    | (slot: c_int, cert_id: c_int) -> c_int      |
-- | ca_can_issue                      | (issuer_tag: u8, child_tag: u8) -> u8       |
-- | ca_can_transition                 | (from_tag: u8, to_tag: u8) -> u8            |
-- | ca_crl_status                     | (slot: c_int) -> u8                         |
-- | ca_update_crl                     | (slot: c_int) -> u8                         |
-- | ca_ocsp_status                    | (slot: c_int) -> u8                         |
-- | ca_ocsp_query                     | (slot: c_int, cert_id: c_int) -> u8         |
-- | ca_set_validity                   | (slot: c_int, cert_id: c_int, not_before... |
-- | ca_cert_not_before                | (slot: c_int, cert_id: c_int) -> u64        |
-- | ca_cert_not_after                 | (slot: c_int, cert_id: c_int) -> u64        |
-- | ca_cert_serial                    | (slot: c_int, cert_id: c_int) -> u64        |
-- | ca_next_serial                    | (slot: c_int) -> u64                        |
-- | ca_set_path_length                | (slot: c_int, cert_id: c_int, max_path_l... |
-- | ca_cert_path_length               | (slot: c_int, cert_id: c_int) -> i32        |
-- | ca_validate_path_length           | (slot: c_int, cert_id: c_int) -> u8         |
-- | ca_set_key_usage                  | (slot: c_int, cert_id: c_int, key_usage_... |
-- | ca_cert_key_usage                 | (slot: c_int, cert_id: c_int) -> u16        |
-- | ca_validate_key_usage             | (slot: c_int, cert_id: c_int) -> u8         |
-- +───────────────────────────────────+─────────────────────────────────────────────+
