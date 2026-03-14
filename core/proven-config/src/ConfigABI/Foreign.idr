-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ConfigABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.

module ConfigABI.Foreign

import Config.Types
import ConfigABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a configuration session.
||| Created by config_create(), destroyed by config_destroy().
export
data ConfigHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version — must match config_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------------------------------------------------+
-- | Function                | Signature                                   |
-- +-------------------------+---------------------------------------------+
-- | config_abi_version      | () -> u32                                   |
-- +-------------------------+---------------------------------------------+
-- | config_create           | (source: u8) -> c_int (slot)                |
-- |                         | Creates session in Uninitialised state,      |
-- |                         | records the config source.                   |
-- +-------------------------+---------------------------------------------+
-- | config_destroy          | (slot: c_int) -> ()                         |
-- +-------------------------+---------------------------------------------+
-- | config_state            | (slot: c_int) -> u8 (ConfigState tag)       |
-- +-------------------------+---------------------------------------------+
-- | config_source           | (slot: c_int) -> u8 (ConfigSource tag)      |
-- +-------------------------+---------------------------------------------+
-- | config_policy           | (slot: c_int) -> u8 (SecurityPolicy tag)    |
-- +-------------------------+---------------------------------------------+
-- | config_override_level   | (slot: c_int) -> u8 (OverrideLevel tag)     |
-- +-------------------------+---------------------------------------------+
-- | config_last_error       | (slot: c_int) -> u8 (ConfigError tag/255)   |
-- +-------------------------+---------------------------------------------+
-- | config_load             | (slot: c_int) -> u8 (0=ok, 1=rejected)      |
-- +-------------------------+---------------------------------------------+
-- | config_validate         | (slot: c_int) -> u8 (0=ok, 1=rejected)      |
-- +-------------------------+---------------------------------------------+
-- | config_accept           | (slot: c_int) -> u8 (0=ok, 1=rejected)      |
-- +-------------------------+---------------------------------------------+
-- | config_reject           | (slot: c_int, err: u8) -> u8                |
-- +-------------------------+---------------------------------------------+
-- | config_reload           | (slot: c_int) -> u8 (0=ok, 1=rejected)      |
-- +-------------------------+---------------------------------------------+
-- | config_lock             | (slot: c_int) -> u8 (0=ok, 1=rejected)      |
-- +-------------------------+---------------------------------------------+
-- | config_unlock           | (slot: c_int) -> u8 (0=ok, 1=rejected)      |
-- +-------------------------+---------------------------------------------+
-- | config_reset            | (slot: c_int) -> u8 (0=ok, 1=rejected)      |
-- +-------------------------+---------------------------------------------+
-- | config_error            | (slot: c_int, err: u8) -> u8                |
-- +-------------------------+---------------------------------------------+
-- | config_set_policy       | (slot: c_int, policy: u8) -> u8             |
-- +-------------------------+---------------------------------------------+
-- | config_set_override     | (slot: c_int, level: u8) -> u8              |
-- +-------------------------+---------------------------------------------+
-- | config_can_transition   | (from: u8, to: u8) -> u8 (1=yes, 0=no)     |
-- +-------------------------+---------------------------------------------+
-- | config_is_restrictive   | (policy: u8) -> u8 (1=yes, 0=no)           |
-- +-------------------------+---------------------------------------------+
-- | config_override_dominates | (a: u8, b: u8) -> u8 (1=yes, 0=no)       |
-- +-------------------------+---------------------------------------------+
