-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ZerotrustABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/zerotrust.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching ZerotrustABI.Types exactly.

module ZerotrustABI.Foreign

import ZerotrustABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Zerotrust context.
||| Created by zerotrust_create*(), destroyed by zerotrust_destroy*().
export
data ZerotrustContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match zerotrust_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (21 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | zt_abi_version                    | () -> u32                                   |
-- | zt_create                         | (policy: u8) -> c_int                       |
-- | zt_destroy                        | (slot: c_int) -> void                       |
-- | zt_phase                          | (slot: c_int) -> u8                         |
-- | zt_policy                         | (slot: c_int) -> u8                         |
-- | zt_identity_confidence            | (slot: c_int) -> u8                         |
-- | zt_device_trust                   | (slot: c_int) -> u8                         |
-- | zt_access_decision                | (slot: c_int) -> u8                         |
-- | zt_verify_identity                | (slot: c_int, confidence: u8) -> u8         |
-- | zt_check_device                   | (slot: c_int, trust: u8) -> u8              |
-- | zt_evaluate_policy                | (slot: c_int) -> u8                         |
-- | zt_grant_access                   | (slot: c_int) -> u8                         |
-- | zt_add_signal                     | (slot: c_int, kind: u8, value: u16) -> u8   |
-- | zt_signal_count                   | (slot: c_int) -> u32                        |
-- | zt_signal_value                   | (slot: c_int, kind: u8) -> u16              |
-- | zt_trust_score                    | (slot: c_int) -> u16                        |
-- | zt_trust_level                    | (slot: c_int) -> u8                         |
-- | zt_can_transition                 | (from: u8, to: u8) -> u8                    |
-- | zt_can_deny                       | (phase: u8) -> u8                           |
-- | zt_can_grant                      | (phase: u8) -> u8                           |
-- | zt_is_terminal                    | (phase: u8) -> u8                           |
-- +───────────────────────────────────+─────────────────────────────────────────────+
