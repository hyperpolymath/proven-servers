-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GitABI.Foreign: Foreign function declarations for the C bridge.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected Git server session pool
--   - Ref advertisement tracking
--   - Pack negotiation state
--   - Hook execution results
--   - Thread-safe via per-pool mutex

module GitABI.Foreign

import GitABI.Types

%default total

export
data GitContext : Type where [external]

public export
abiVersion : Bits32
abiVersion = 1

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature                               |
-- +-------------------------------+-----------------------------------------+
-- | git_abi_version               | () -> u32                               |
-- | git_create                    | (path_ptr, path_len, cmd) -> c_int      |
-- | git_destroy                   | (slot) -> void                          |
-- | git_state                     | (slot) -> u8 (ServerState tag)          |
-- | git_advertise_ref             | (slot, ref_type, name_ptr, len) -> u8   |
-- | git_ref_count                 | (slot) -> u32                           |
-- | git_begin_negotiation         | (slot) -> u8                            |
-- | git_finish_negotiation        | (slot) -> u8                            |
-- | git_begin_transfer            | (slot) -> u8                            |
-- | git_finish_transfer           | (slot) -> u8                            |
-- | git_run_hook                  | (slot, hook_type) -> u8 (HookResult)    |
-- | git_shutdown                  | (slot) -> u8                            |
-- | git_cleanup                   | (slot) -> u8                            |
-- | git_can_transition            | (from, to) -> u8                        |
-- +-------------------------------+-----------------------------------------+
