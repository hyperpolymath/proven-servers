-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SMTPABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.

module SMTPABI.Foreign

import SMTPABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an SMTP session context.
||| Created by smtp_create_context(), destroyed by smtp_destroy_context().
export
data SmtpHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match smtp_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-------------------------+-----------------------------------------------+
-- | Function                | Signature                                     |
-- +-------------------------+-----------------------------------------------+
-- | smtp_abi_version        | () -> Bits32                                  |
-- +-------------------------+-----------------------------------------------+
-- | smtp_create_context     | () -> c_int (slot, -1 on failure)             |
-- |                         | Creates context in Connected state.           |
-- +-------------------------+-----------------------------------------------+
-- | smtp_destroy_context    | (slot: c_int) -> ()                           |
-- +-------------------------+-----------------------------------------------+
-- | smtp_greet              | (slot: c_int, is_ehlo: u8) -> u8             |
-- |                         | 0=ok, 1=rejected. HELO (is_ehlo=0) or        |
-- |                         | EHLO (is_ehlo=1).                             |
-- +-------------------------+-----------------------------------------------+
-- | smtp_authenticate       | (slot: c_int, mech: u8) -> u8                |
-- |                         | Begin AUTH exchange. 0=ok (-> AuthStarted),   |
-- |                         | 1=rejected.                                   |
-- +-------------------------+-----------------------------------------------+
-- | smtp_auth_complete      | (slot: c_int, success: u8) -> u8             |
-- |                         | Complete AUTH. success=1 -> Authenticated,    |
-- |                         | success=0 -> back to Greeted.                 |
-- +-------------------------+-----------------------------------------------+
-- | smtp_set_sender         | (slot: c_int) -> u8                           |
-- |                         | MAIL FROM. 0=ok, 1=rejected.                  |
-- +-------------------------+-----------------------------------------------+
-- | smtp_add_recipient      | (slot: c_int) -> u8                           |
-- |                         | RCPT TO. 0=ok, 1=rejected (max 64 or wrong   |
-- |                         | state).                                       |
-- +-------------------------+-----------------------------------------------+
-- | smtp_start_data         | (slot: c_int) -> u8                           |
-- |                         | DATA. 0=ok (-> Data), 1=rejected.             |
-- +-------------------------+-----------------------------------------------+
-- | smtp_append_data        | (slot: c_int, len: u32) -> u8                 |
-- |                         | Append len bytes to message buffer.           |
-- |                         | 0=ok, 1=rejected (wrong state or overflow).   |
-- +-------------------------+-----------------------------------------------+
-- | smtp_finish_data        | (slot: c_int) -> u8                           |
-- |                         | End-of-data. 0=ok (-> MessageReceived),       |
-- |                         | 1=rejected.                                   |
-- +-------------------------+-----------------------------------------------+
-- | smtp_reset              | (slot: c_int) -> u8                           |
-- |                         | RSET. 0=ok (-> Greeted or Authenticated),     |
-- |                         | 1=rejected.                                   |
-- +-------------------------+-----------------------------------------------+
-- | smtp_quit               | (slot: c_int) -> u8                           |
-- |                         | QUIT. 0=ok (-> Quit), 1=rejected.             |
-- +-------------------------+-----------------------------------------------+
-- | smtp_get_state          | (slot: c_int) -> u8 (SmtpSessionState tag)    |
-- +-------------------------+-----------------------------------------------+
-- | smtp_get_reply_code     | (slot: c_int) -> u8 (ReplyCode tag)           |
-- +-------------------------+-----------------------------------------------+
-- | smtp_get_recipient_count| (slot: c_int) -> u8                           |
-- +-------------------------+-----------------------------------------------+
-- | smtp_get_data_size      | (slot: c_int) -> u32                          |
-- +-------------------------+-----------------------------------------------+
-- | smtp_get_auth_mechanism | (slot: c_int) -> u8 (AuthMechTag, 255=none)   |
-- +-------------------------+-----------------------------------------------+
-- | smtp_is_authenticated   | (slot: c_int) -> u8 (1=yes, 0=no)            |
-- +-------------------------+-----------------------------------------------+
-- | smtp_enable_tls         | (slot: c_int) -> u8 (0=ok, 1=rejected)        |
-- +-------------------------+-----------------------------------------------+
-- | smtp_is_tls_active      | (slot: c_int) -> u8 (1=yes, 0=no)            |
-- +-------------------------+-----------------------------------------------+
-- | smtp_can_transition     | (from: u8, to: u8) -> u8 (1=yes, 0=no)        |
-- +-------------------------+-----------------------------------------------+
