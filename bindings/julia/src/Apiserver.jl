# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-apiserver protocol (API gateway/server).
#
# Wraps the C-ABI functions from protocols/proven-apiserver/ffi/zig/src/apiserver.zig
# via ccall into libproven_apiserver.so.

module Apiserver

using ..ProvenServers: check_status, check_slot, SlotId

export AuthScheme, RateLimitStrategy, ApiVersion, ResponseFormat, GatewayError,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_apiserver"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""API authentication schemes.  Matches `AuthScheme` in `ApiserverABI.Types`."""
@enum AuthScheme::UInt8 begin
    API_KEY = 0
    BEARER = 1
    BASIC = 2
    O_AUTH2 = 3
    HMAC = 4
    MTLS = 5
end


"""API rate limiting strategies.  Matches `RateLimitStrategy` in `ApiserverABI.Types`."""
@enum RateLimitStrategy::UInt8 begin
    FIXED_WINDOW = 0
    SLIDING_WINDOW = 1
    TOKEN_BUCKET = 2
    LEAKY_BUCKET = 3
end


"""API version identifiers.  Matches `ApiVersion` in `ApiserverABI.Types`."""
@enum ApiVersion::UInt8 begin
    V1 = 0
    V2 = 1
    V3 = 2
    LATEST = 3
    DEPRECATED = 4
end


"""API response formats.  Matches `ResponseFormat` in `ApiserverABI.Types`."""
@enum ResponseFormat::UInt8 begin
    JSON = 0
    XML = 1
    PROTOBUF = 2
    MESSAGE_PACK = 3
end


"""API gateway error codes.  Matches `GatewayError` in `ApiserverABI.Types`."""
@enum GatewayError::UInt8 begin
    UNAUTHORIZED = 0
    RATE_LIMITED = 1
    NOT_FOUND = 2
    BAD_REQUEST = 3
    SERVICE_UNAVAILABLE = 4
    CIRCUIT_OPEN = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_apiserver."""
function abi_version()::UInt32
    ccall((:apiserver_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new API gateway/server context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:apiserver_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given API gateway/server context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:apiserver_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> GatewayError

Get the current API gateway/server lifecycle state.
"""
function get_state(slot::SlotId)::GatewayError
    GatewayError(ccall((:apiserver_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::GatewayError, to::GatewayError) -> Bool

Check whether a API gateway/server state transition is valid.
"""
function can_transition(from::GatewayError, to::GatewayError)::Bool
    ccall((:apiserver_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Apiserver
