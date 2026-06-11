-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- SmtpABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/smtp.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching SmtpABI.Types exactly.

module SmtpABI.Foreign

import SmtpABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Smtp context.
||| Created by smtp_create*(), destroyed by smtp_destroy*().
export
data SmtpContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match smtp_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (22 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | smtp_abi_version                  | () -> u32                                   |
-- | smtp_create_context               | () -> c_int                                 |
-- | smtp_destroy_context              | (slot: c_int) -> void                       |
-- | smtp_get_state                    | (slot: c_int) -> u8                         |
-- | smtp_get_reply_code               | (slot: c_int) -> u8                         |
-- | smtp_get_recipient_count          | (slot: c_int) -> u8                         |
-- | smtp_get_data_size                | (slot: c_int) -> u32                        |
-- | smtp_get_auth_mechanism           | (slot: c_int) -> u8                         |
-- | smtp_is_authenticated             | (slot: c_int) -> u8                         |
-- | smtp_is_tls_active                | (slot: c_int) -> u8                         |
-- | smtp_greet                        | (slot: c_int, is_ehlo: u8) -> u8            |
-- | smtp_authenticate                 | (slot: c_int, mech: u8) -> u8               |
-- | smtp_auth_complete                | (slot: c_int, success: u8) -> u8            |
-- | smtp_set_sender                   | (slot: c_int) -> u8                         |
-- | smtp_add_recipient                | (slot: c_int) -> u8                         |
-- | smtp_start_data                   | (slot: c_int) -> u8                         |
-- | smtp_append_data                  | (slot: c_int, len: u32) -> u8               |
-- | smtp_finish_data                  | (slot: c_int) -> u8                         |
-- | smtp_reset                        | (slot: c_int) -> u8                         |
-- | smtp_quit                         | (slot: c_int) -> u8                         |
-- | smtp_enable_tls                   | (slot: c_int) -> u8                         |
-- | smtp_can_transition               | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
