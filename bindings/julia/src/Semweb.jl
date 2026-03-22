# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-semweb protocol (Semantic Web / Linked Data server).
#
# Wraps the C-ABI functions from protocols/proven-semweb/ffi/zig/src/semweb.zig
# via ccall into libproven_semweb.so.

module Semweb

using ..ProvenServers: check_status, check_slot, SlotId

export RdfFormat,
       SemwebResourceType,
       SemwebHttpMethod,
       ContentNegotiation,
       SemwebErrorCode,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_semweb"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""RDF serialization formats."""
@enum RdfFormat::UInt8 begin
    FMT_RDF_XML = 0
    FMT_TURTLE = 1
    FMT_NTRIPLES = 2
    FMT_NQUADS = 3
    FMT_JSONLD = 4
    FMT_TRIG = 5
end

"""Semantic web resource types."""
@enum SemwebResourceType::UInt8 begin
    RES_CLASS = 0
    RES_PROPERTY = 1
    RES_INDIVIDUAL = 2
    RES_ONTOLOGY = 3
    RES_NAMED_GRAPH = 4
end

"""Semantic web HTTP methods."""
@enum SemwebHttpMethod::UInt8 begin
    HTTP_GET = 0
    HTTP_POST = 1
    HTTP_PUT = 2
    HTTP_PATCH = 3
    HTTP_DELETE = 4
end

"""Content negotiation formats."""
@enum ContentNegotiation::UInt8 begin
    NEG_RDF_XML = 0
    NEG_TURTLE = 1
    NEG_JSONLD = 2
    NEG_HTML = 3
end

"""Semantic web error codes."""
@enum SemwebErrorCode::UInt8 begin
    ERR_NOT_FOUND = 0
    ERR_INVALID_URI = 1
    ERR_MALFORMED_RDF = 2
    ERR_UNSUPPORTED_FORMAT = 3
    ERR_CONFLICTING_TRIPLES = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_semweb."""
function abi_version()::UInt32
    ccall((:semweb_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Semweb context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:semweb_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Semweb context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:semweb_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SemwebErrorCode

Get the current Semweb lifecycle state.
"""
function get_state(slot::SlotId)::SemwebErrorCode
    SemwebErrorCode(ccall((:semweb_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SemwebErrorCode, to::SemwebErrorCode) -> Bool

Check whether a Semweb state transition is valid.
"""
function can_transition(from::SemwebErrorCode, to::SemwebErrorCode)::Bool
    ccall((:semweb_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Semweb
