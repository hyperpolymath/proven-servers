-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SOCKSABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/socks.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected SOCKS5 connection pool
--   - Connection lifecycle state machine
--     (Initial -> Authenticating -> Authenticated -> Connecting ->
--      Established -> Closed)
--   - Authentication method negotiation
--   - Command execution with address type tracking
--   - Reply code management
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching SOCKSABI.Types exactly.

module SOCKSABI.Foreign

import SOCKSABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a SOCKS5 connection context.
||| Created by socks_create(), destroyed by socks_destroy().
export
data SOCKSContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match socks_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | socks_abi_version           | () -> u32                                 |
-- |                             | Returns ABI version (must equal           |
-- |                             | abiVersion).                              |
-- +-----------------------------+-------------------------------------------+
-- | socks_create                | (auth: u8) -> c_int                       |
-- |                             | Creates connection in Initial state.      |
-- |                             | Returns slot (0-63) or -1 on failure.     |
-- +-----------------------------+-------------------------------------------+
-- | socks_destroy               | (slot: c_int) -> void                     |
-- |                             | Releases a connection slot.               |
-- +-----------------------------+-------------------------------------------+
-- | socks_get_state             | (slot: c_int) -> u8 (State tag)           |
-- |                             | Returns current connection state.         |
-- +-----------------------------+-------------------------------------------+
-- | socks_get_auth              | (slot: c_int) -> u8 (AuthMethod tag)      |
-- |                             | Returns authentication method tag.        |
-- +-----------------------------+-------------------------------------------+
-- | socks_get_reply             | (slot: c_int) -> u8 (Reply tag)           |
-- |                             | Returns last reply code tag.              |
-- +-----------------------------+-------------------------------------------+
-- | socks_get_command           | (slot: c_int) -> u8 (Command tag)         |
-- |                             | Returns active command tag.               |
-- +-----------------------------+-------------------------------------------+
-- | socks_get_addr_type         | (slot: c_int) -> u8 (AddressType tag)     |
-- |                             | Returns address type tag.                 |
-- +-----------------------------+-------------------------------------------+
-- | socks_authenticate          | (slot: c_int) -> u8 (0=ok, 1=fail)       |
-- |                             | Transitions Initial -> Authenticating.    |
-- +-----------------------------+-------------------------------------------+
-- | socks_auth_complete         | (slot: c_int, reply: u8) -> u8            |
-- |                             | Completes authentication phase.           |
-- |                             | Transitions to Authenticated or Closed.   |
-- +-----------------------------+-------------------------------------------+
-- | socks_connect               | (slot: c_int, cmd: u8, addr: u8) -> u8   |
-- |                             | Sends command. Transitions Authenticated  |
-- |                             | -> Connecting.                            |
-- +-----------------------------+-------------------------------------------+
-- | socks_connect_complete      | (slot: c_int, reply: u8) -> u8            |
-- |                             | Completes command. Transitions to         |
-- |                             | Established or Closed.                    |
-- +-----------------------------+-------------------------------------------+
-- | socks_close                 | (slot: c_int) -> void                     |
-- |                             | Transitions any state to Closed.          |
-- +-----------------------------+-------------------------------------------+
-- | socks_can_transition        | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks state transition        |
-- |                             | validity.                                 |
-- +-----------------------------+-------------------------------------------+
