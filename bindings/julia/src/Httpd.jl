# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-httpd protocol (HTTP server).
#
# Wraps the C-ABI functions from protocols/proven-httpd/ffi/zig/src/httpd.zig
# via ccall into libproven_httpd.so.

module Httpd

using ..ProvenServers: check_status, check_slot, SlotId

export HttpMethod, RequestPhase, HttpVersion, StatusCode, ParseResult,
       abi_version, create_context, destroy_context, parse_request,
       get_method, get_phase, get_version, set_status, send_response,
       keep_alive_check, reset_context, can_transition

const LIB = "libproven_httpd"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""HTTP methods matching the Zig ABI tag values."""
@enum HttpMethod::UInt8 begin
    METHOD_GET     = 0
    METHOD_HEAD    = 1
    METHOD_POST    = 2
    METHOD_PUT     = 3
    METHOD_DELETE  = 4
    METHOD_CONNECT = 5
    METHOD_OPTIONS = 6
    METHOD_TRACE   = 7
    METHOD_PATCH   = 8
end

"""HTTP request lifecycle phases matching the Zig ABI."""
@enum RequestPhase::UInt8 begin
    PHASE_IDLE           = 0
    PHASE_RECEIVING      = 1
    PHASE_HEADERS_PARSED = 2
    PHASE_BODY_RECEIVING = 3
    PHASE_COMPLETE       = 4
    PHASE_RESPONDING     = 5
    PHASE_SENT           = 6
end

"""HTTP protocol versions."""
@enum HttpVersion::UInt8 begin
    HTTP_1_0 = 0
    HTTP_1_1 = 1
end

"""HTTP status code tags."""
@enum StatusCode::UInt8 begin
    STATUS_200_OK           = 0
    STATUS_201_CREATED      = 1
    STATUS_204_NO_CONTENT   = 2
    STATUS_301_MOVED        = 3
    STATUS_302_FOUND        = 4
    STATUS_304_NOT_MODIFIED = 5
    STATUS_400_BAD_REQUEST  = 6
    STATUS_401_UNAUTHORIZED = 7
    STATUS_403_FORBIDDEN    = 8
    STATUS_404_NOT_FOUND    = 9
    STATUS_405_NOT_ALLOWED  = 10
    STATUS_500_INTERNAL     = 11
    STATUS_502_BAD_GATEWAY  = 12
    STATUS_503_UNAVAILABLE  = 13
end

"""Parse result codes."""
@enum ParseResult::UInt8 begin
    PARSE_COMPLETE  = 0
    PARSE_REJECTED  = 1
    PARSE_NEED_MORE = 2
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_httpd."""
function abi_version()::UInt32
    ccall((:http_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new HTTP context in the Idle phase. Throws on pool exhaustion.
"""
function create_context()::SlotId
    raw = ccall((:http_create_context, LIB), Cint, ())
    check_slot(raw)
end

"""
    destroy_context(slot::SlotId)

Release the given HTTP context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:http_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    parse_request(slot::SlotId, data::Vector{UInt8}) -> ParseResult

Feed raw HTTP data into a context for parsing.
"""
function parse_request(slot::SlotId, data::Vector{UInt8})::ParseResult
    raw = ccall((:http_parse_request, LIB), UInt8,
                (Cint, Ptr{UInt8}, UInt32),
                slot, data, UInt32(length(data)))
    ParseResult(raw)
end

"""
    get_method(slot::SlotId) -> Union{HttpMethod, Nothing}

Get the HTTP method of the parsed request. Returns nothing if not yet parsed.
"""
function get_method(slot::SlotId)::Union{HttpMethod, Nothing}
    tag = ccall((:http_get_method, LIB), UInt8, (Cint,), slot)
    tag == 0xff ? nothing : HttpMethod(tag)
end

"""
    get_phase(slot::SlotId) -> Union{RequestPhase, Nothing}

Get the current request processing phase.
"""
function get_phase(slot::SlotId)::Union{RequestPhase, Nothing}
    tag = ccall((:http_get_phase, LIB), UInt8, (Cint,), slot)
    tag > UInt8(PHASE_SENT) ? nothing : RequestPhase(tag)
end

"""
    get_version(slot::SlotId) -> Union{HttpVersion, Nothing}

Get the HTTP version of the parsed request.
"""
function get_version(slot::SlotId)::Union{HttpVersion, Nothing}
    tag = ccall((:http_get_version, LIB), UInt8, (Cint,), slot)
    tag > UInt8(HTTP_1_1) ? nothing : HttpVersion(tag)
end

"""
    set_status(slot::SlotId, status::StatusCode)

Set the response status code. Throws on invalid state.
"""
function set_status(slot::SlotId, status::StatusCode)::Nothing
    raw = ccall((:http_set_status, LIB), UInt8,
                (Cint, UInt8), slot, UInt8(status))
    check_status(raw)
end

"""
    send_response(slot::SlotId)

Send the response, transitioning Responding -> Sent. Throws on invalid state.
"""
function send_response(slot::SlotId)::Nothing
    raw = ccall((:http_send_response, LIB), UInt8, (Cint,), slot)
    check_status(raw)
end

"""
    keep_alive_check(slot::SlotId) -> Bool

Check if the connection uses keep-alive.
"""
function keep_alive_check(slot::SlotId)::Bool
    ccall((:http_keep_alive_check, LIB), UInt8, (Cint,), slot) == 0x01
end

"""
    reset_context(slot::SlotId)

Reset the context for keep-alive reuse (Sent -> Idle). Throws on invalid state.
"""
function reset_context(slot::SlotId)::Nothing
    raw = ccall((:http_reset_context, LIB), UInt8, (Cint,), slot)
    check_status(raw)
end

"""
    can_transition(from::RequestPhase, to::RequestPhase) -> Bool

Stateless query: check whether a lifecycle transition is valid.
"""
function can_transition(from::RequestPhase, to::RequestPhase)::Bool
    ccall((:http_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Httpd
