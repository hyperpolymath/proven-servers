-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ProxyABI.Foreign: Foreign function declarations for the Proxy C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle type (ProxyContext) that cannot be inspected or
--      forged from Idris2 code -- it exists only as a slot index managed
--      by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function proxy_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.

module ProxyABI.Foreign

import Proxy.Types
import ProxyABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a proxy connection context instance.
||| This type has no Idris2-visible constructors -- values can only be
||| created by the Zig FFI via proxy_create() and destroyed via
||| proxy_destroy().
export
data ProxyContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
||| The Zig implementation's proxy_abi_version() function MUST return
||| this exact value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- The following documents the complete set of C-ABI functions that the
-- Zig implementation (ffi/zig/src/proxy.zig) must export.
--
-- +--------------------------------------------------------------------------+
-- | Function                      | Signature                                |
-- +-------------------------------+------------------------------------------+
-- | proxy_abi_version             | () -> u32                                |
-- |                               | Must return abiVersion (currently 1).    |
-- +-------------------------------+------------------------------------------+
-- | proxy_create                  | (mode: u8) -> c_int                      |
-- |                               | Creates a new proxy in given mode.       |
-- |                               | Returns -1 if no slots available.        |
-- +-------------------------------+------------------------------------------+
-- | proxy_destroy                 | (slot: c_int) -> void                    |
-- |                               | Frees the proxy context.                 |
-- +-------------------------------+------------------------------------------+
-- | proxy_get_mode                | (slot: c_int) -> u8                      |
-- |                               | Returns the ProxyMode tag.               |
-- |                               | Returns Forward (0) if slot invalid.     |
-- +-------------------------------+------------------------------------------+
-- | proxy_set_cache_directive     | (slot: c_int, directive: u8)             |
-- |                               |  -> u8 (ProxyFFIError tag)               |
-- |                               | Set active cache directive.              |
-- +-------------------------------+------------------------------------------+
-- | proxy_get_cache_directive     | (slot: c_int) -> u8                      |
-- |                               | Returns the CacheDirective tag.          |
-- +-------------------------------+------------------------------------------+
-- | proxy_check_hop_header        | (slot: c_int, header: u8)                |
-- |                               |  -> u8 (1 = must strip, 0 = pass)        |
-- |                               | Check if header must be stripped.         |
-- +-------------------------------+------------------------------------------+
-- | proxy_get_request_count       | (slot: c_int) -> u32                     |
-- |                               | Returns number of proxied requests.      |
-- +-------------------------------+------------------------------------------+
-- | proxy_record_request          | (slot: c_int) -> u8 (ProxyFFIError tag)  |
-- |                               | Record a proxied request.                |
-- +-------------------------------+------------------------------------------+
-- | proxy_get_cache_hits          | (slot: c_int) -> u32                     |
-- |                               | Returns number of cache hits.            |
-- +-------------------------------+------------------------------------------+
-- | proxy_record_cache_hit        | (slot: c_int) -> u8 (ProxyFFIError tag)  |
-- |                               | Record a cache hit.                      |
-- +-------------------------------+------------------------------------------+
-- | proxy_get_last_error          | (slot: c_int) -> u8                      |
-- |                               | Returns the last ProxyFFIError tag,      |
-- |                               | or 255 if no error occurred.             |
-- +-------------------------------+------------------------------------------+
