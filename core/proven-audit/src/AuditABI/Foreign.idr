-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AuditABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.

module AuditABI.Foreign

import Audit.Types
import AuditABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an audit trail session.
||| Created by audit_create(), destroyed by audit_destroy().
export
data AuditHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version — must match audit_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------------------------------------------------+
-- | Function              | Signature                                     |
-- +-----------------------+-----------------------------------------------+
-- | audit_abi_version     | () -> Bits32                                  |
-- +-----------------------+-----------------------------------------------+
-- | audit_create          | (level: u8, integrity: u8, retention: u8)     |
-- |                       |   -> c_int (slot)                             |
-- |                       | Creates trail in Idle state.                  |
-- +-----------------------+-----------------------------------------------+
-- | audit_destroy         | (slot: c_int) -> ()                           |
-- +-----------------------+-----------------------------------------------+
-- | audit_state           | (slot: c_int) -> u8 (AuditTrailState tag)     |
-- +-----------------------+-----------------------------------------------+
-- | audit_last_error      | (slot: c_int) -> u8 (AuditError tag or 255)   |
-- +-----------------------+-----------------------------------------------+
-- | audit_event_count     | (slot: c_int) -> u32                          |
-- +-----------------------+-----------------------------------------------+
-- | audit_open            | (slot: c_int) -> u8 (0=ok, 1=rejected)        |
-- +-----------------------+-----------------------------------------------+
-- | audit_seal            | (slot: c_int) -> u8 (0=ok, 1=rejected)        |
-- +-----------------------+-----------------------------------------------+
-- | audit_archive         | (slot: c_int) -> u8 (0=ok, 1=rejected)        |
-- +-----------------------+-----------------------------------------------+
-- | audit_fail            | (slot: c_int, err: u8) -> u8                  |
-- +-----------------------+-----------------------------------------------+
-- | audit_reset           | (slot: c_int) -> u8 (0=ok, 1=rejected)        |
-- +-----------------------+-----------------------------------------------+
-- | audit_record_event    | (slot: c_int, category: u8) -> u8             |
-- |                       | Returns 255=ok or AuditError tag              |
-- +-----------------------+-----------------------------------------------+
-- | audit_can_transition  | (from: u8, to: u8) -> u8 (1=yes, 0=no)       |
-- +-----------------------+-----------------------------------------------+
-- | audit_level           | (slot: c_int) -> u8 (AuditLevel tag)          |
-- +-----------------------+-----------------------------------------------+
-- | audit_integrity       | (slot: c_int) -> u8 (Integrity tag)           |
-- +-----------------------+-----------------------------------------------+
-- | audit_retention       | (slot: c_int) -> u8 (RetentionPolicy tag)     |
-- +-----------------------+-----------------------------------------------+
