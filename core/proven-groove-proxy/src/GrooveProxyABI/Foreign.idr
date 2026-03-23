-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GrooveProxyABI.Foreign: FFI function contracts for the Zig implementation.
--
-- Declares opaque handle types and the C-compatible function signatures
-- that the Zig FFI layer must implement. These are contracts: the Zig
-- code must match these signatures exactly.

module GrooveProxyABI.Foreign

import GrooveProxy.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle types
---------------------------------------------------------------------------

||| Opaque handle to the proxy server instance.
||| Created by groove_proxy_start, consumed by groove_proxy_stop.
export
data ProxyHandle : Type where [external]

||| Opaque handle to a single proxied connection.
||| Created on accept, consumed on close.
export
data ConnHandle : Type where [external]

---------------------------------------------------------------------------
-- FFI function contracts
---------------------------------------------------------------------------

||| Start the proxy server.
||| Returns an opaque handle that MUST be consumed by groove_proxy_stop.
|||
||| @param ipv4_addr  IPv4 bind address (e.g. "127.0.0.1")
||| @param ipv4_port  IPv4 listen port
||| @param ipv6_addr  IPv6 target address (e.g. "::1")
||| @param ipv6_port  IPv6 target port
||| @returns          Opaque server handle, or negative error code
export
%foreign "C:groove_proxy_start,groove_proxy"
groove_proxy_start : String -> Bits16 -> String -> Bits16 -> PrimIO ProxyHandle

||| Stop the proxy server and release all resources.
||| Consumes the server handle.
|||
||| @param handle  The server handle from groove_proxy_start
export
%foreign "C:groove_proxy_stop,groove_proxy"
groove_proxy_stop : ProxyHandle -> PrimIO ()

||| Get current proxy statistics.
|||
||| @param handle  The server handle
||| @returns       JSON-encoded stats string
export
%foreign "C:groove_proxy_stats,groove_proxy"
groove_proxy_stats : ProxyHandle -> PrimIO String

||| Check if kernel splice(2) is available on this platform.
|||
||| @returns  1 if splice is available (Linux), 0 if fallback (macOS/Windows)
export
%foreign "C:groove_proxy_has_splice,groove_proxy"
groove_proxy_has_splice : PrimIO Bits8

||| Get the number of active connections.
|||
||| @param handle  The server handle
||| @returns       Number of currently active proxied connections
export
%foreign "C:groove_proxy_active_count,groove_proxy"
groove_proxy_active_count : ProxyHandle -> PrimIO Bits32
