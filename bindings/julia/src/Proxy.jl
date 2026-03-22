# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-proxy protocol (Reverse Proxy server).
#
# Wraps the C-ABI functions from protocols/proven-proxy/ffi/zig/src/proxy.zig
# via ccall into libproven_proxy.so.

module Proxy

using ..ProvenServers: check_status, check_slot, SlotId

export ProxyMode,
       HopByHopHeader,
       CacheDirective,
       ProxyError,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_proxy"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Proxy operating modes."""
@enum ProxyMode::UInt8 begin
    MODE_FORWARD = 0
    MODE_REVERSE = 1
end

"""HTTP hop-by-hop headers."""
@enum HopByHopHeader::UInt8 begin
    HBH_CONNECTION = 0
    HBH_KEEP_ALIVE = 1
    HBH_PROXY_AUTH = 2
    HBH_PROXY_AUTHZ = 3
    HBH_TE = 4
    HBH_TRAILERS = 5
    HBH_TRANSFER_ENCODING = 6
    HBH_UPGRADE = 7
end

"""HTTP cache directives."""
@enum CacheDirective::UInt8 begin
    CACHE_NO_CACHE = 0
    CACHE_NO_STORE = 1
    CACHE_MAX_AGE = 2
    CACHE_PUBLIC = 3
    CACHE_PRIVATE = 4
    CACHE_MUST_REVALIDATE = 5
end

"""Proxy-specific error codes."""
@enum ProxyError::UInt8 begin
    ERR_BAD_GATEWAY = 0
    ERR_GATEWAY_TIMEOUT = 1
    ERR_UPSTREAM_REFUSED = 2
    ERR_UPSTREAM_TLS = 3
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_proxy."""
function abi_version()::UInt32
    ccall((:proxy_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Proxy context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:proxy_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Proxy context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:proxy_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ProxyMode

Get the current Proxy lifecycle state.
"""
function get_state(slot::SlotId)::ProxyMode
    ProxyMode(ccall((:proxy_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ProxyMode, to::ProxyMode) -> Bool

Check whether a Proxy state transition is valid.
"""
function can_transition(from::ProxyMode, to::ProxyMode)::Bool
    ccall((:proxy_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Proxy
