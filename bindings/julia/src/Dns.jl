# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the bounded proven-dns message-builder FFI.
# It accepts exact 17-byte standard root-question queries and caps responses
# at 512 bytes; it is not a general resolver. DNSSEC crypto fails closed.
#
# Wraps the C-ABI functions from protocols/proven-dns/ffi/zig/src/dns.zig
# via ccall into libproven_dns.so.

module Dns

using ..ProvenServers: check_status, check_slot, SlotId

export DnsState, DnssecState, Rcode, RecordType, RecordClass, DnssecAlgorithm,
       abi_version, create_context, destroy_context, get_state,
       parse_query, begin_lookup, begin_response, set_rcode,
       enable_dnssec, sign_response, validate_dnssec,
       can_transition, can_dnssec_transition

const LIB = "libproven_dns"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""DNS query lifecycle states matching DnsState in dns.zig."""
@enum DnsState::UInt8 begin
    STATE_IDLE              = 0
    STATE_QUERY_RECEIVED    = 1
    STATE_LOOKUP            = 2
    STATE_RESPONSE_BUILDING = 3
    STATE_SENT              = 4
end

"""DNSSEC ABI/model states; key loading, signing, and validation are unavailable."""
@enum DnssecState::UInt8 begin
    DNSSEC_DISABLED   = 0
    DNSSEC_ENABLED    = 1
    DNSSEC_KEY_LOADED = 2
    DNSSEC_VALIDATED  = 3
end

"""DNS response codes."""
@enum Rcode::UInt8 begin
    RCODE_NOERROR  = 0
    RCODE_FORMERR  = 1
    RCODE_SERVFAIL = 2
    RCODE_NXDOMAIN = 3
    RCODE_NOTIMP   = 4
    RCODE_REFUSED  = 5
end

"""DNS record types (subset)."""
@enum RecordType::UInt8 begin
    RTYPE_A     = 0
    RTYPE_AAAA  = 1
    RTYPE_CNAME = 2
    RTYPE_MX    = 3
    RTYPE_NS    = 4
    RTYPE_PTR   = 5
    RTYPE_SOA   = 6
    RTYPE_SRV   = 7
    RTYPE_TXT   = 8
end

"""DNS record class."""
@enum RecordClass::UInt8 begin
    CLASS_IN  = 0
    CLASS_CH  = 1
    CLASS_HS  = 2
    CLASS_ANY = 3
end

"""DNSSEC algorithm identifiers."""
@enum DnssecAlgorithm::UInt8 begin
    ALGO_RSASHA256  = 0
    ALGO_RSASHA512  = 1
    ALGO_ECDSAP256  = 2
    ALGO_ECDSAP384  = 3
    ALGO_ED25519    = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_dns."""
function abi_version()::UInt32
    ccall((:dns_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new DNS context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:dns_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given DNS context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:dns_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> DnsState

Get the current DNS lifecycle state.
"""
function get_state(slot::SlotId)::DnsState
    DnsState(ccall((:dns_state, LIB), UInt8, (Cint,), slot))
end

"""
    parse_query(slot::SlotId, data::Vector{UInt8})

Parse only the exact 17-byte standard query with one root-name question.
"""
function parse_query(slot::SlotId, data::Vector{UInt8})::Nothing
    length(data) == 17 || throw(ArgumentError("DNS query must be exactly 17 bytes"))
    raw = ccall((:dns_parse_query, LIB), UInt8,
                (Cint, Ptr{UInt8}, UInt16),
                slot, data, UInt16(length(data)))
    check_status(raw)
end

"""
    begin_lookup(slot::SlotId)

Transition to lookup phase. Throws on invalid state.
"""
function begin_lookup(slot::SlotId)::Nothing
    check_status(ccall((:dns_begin_lookup, LIB), UInt8, (Cint,), slot))
end

"""
    begin_response(slot::SlotId)

Transition to response building phase. Throws on invalid state.
"""
function begin_response(slot::SlotId)::Nothing
    check_status(ccall((:dns_begin_response, LIB), UInt8, (Cint,), slot))
end

"""
    set_rcode(slot::SlotId, code::Rcode)

Set the DNS response code. Throws on invalid state.
"""
function set_rcode(slot::SlotId, code::Rcode)::Nothing
    check_status(ccall((:dns_set_rcode, LIB), UInt8,
                       (Cint, UInt8), slot, UInt8(code)))
end

"""
    enable_dnssec(slot::SlotId)

Enable DNSSEC mode only; response construction then rejects without a signer.
"""
function enable_dnssec(slot::SlotId)::Nothing
    check_status(ccall((:dns_enable_dnssec, LIB), UInt8, (Cint,), slot))
end

"""
    sign_response(slot::SlotId)

Always fails closed because no DNSSEC signing backend is available.
"""
function sign_response(slot::SlotId)::Nothing
    check_status(ccall((:dns_sign_response, LIB), UInt8, (Cint,), slot))
end

"""
    validate_dnssec(slot::SlotId)

Always returns false because no DNSSEC validator is available.
"""
function validate_dnssec(slot::SlotId)::Bool
    ccall((:dns_validate_dnssec, LIB), UInt8, (Cint,), slot) == 0x00
end

"""
    can_transition(from::DnsState, to::DnsState) -> Bool

Check whether a DNS lifecycle transition is valid.
"""
function can_transition(from::DnsState, to::DnsState)::Bool
    ccall((:dns_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

"""
    can_dnssec_transition(from::DnssecState, to::DnssecState) -> Bool

Check the abstract DNSSEC state model only; this does not imply crypto availability.
"""
function can_dnssec_transition(from::DnssecState, to::DnssecState)::Bool
    ccall((:dns_can_dnssec_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Dns
