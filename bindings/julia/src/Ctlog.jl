# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-ctlog protocol (Certificate Transparency log (RFC 6962)).
#
# Wraps the C-ABI functions from protocols/proven-ctlog/ffi/zig/src/ctlog.zig
# via ccall into libproven_ctlog.so.

module Ctlog

using ..ProvenServers: check_status, check_slot, SlotId

export LogEntryType, SignatureType, MerkleLeafType, SubmissionStatus, VerificationResult, ServerState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_ctlog"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""CT log entry types.  Matches `LogEntryType` in `CtlogABI.Types`."""
@enum LogEntryType::UInt8 begin
    X509_ENTRY = 0
    PRECERT_ENTRY = 1
end


"""CT signature types.  Matches `SignatureType` in `CtlogABI.Types`."""
@enum SignatureType::UInt8 begin
    CERTIFICATE_TIMESTAMP = 0
    TREE_HASH = 1
end


"""Merkle tree leaf types.  Matches `MerkleLeafType` in `CtlogABI.Types`."""
@enum MerkleLeafType::UInt8 begin
    TIMESTAMPED_ENTRY = 0
end


"""Certificate submission status.  Matches `SubmissionStatus` in `CtlogABI.Types`."""
@enum SubmissionStatus::UInt8 begin
    ACCEPTED = 0
    DUPLICATE = 1
    RATE_LIMITED = 2
    REJECTED = 3
    INVALID_CHAIN = 4
    UNKNOWN_ANCHOR = 5
end


"""Proof verification results.  Matches `VerificationResult` in `CtlogABI.Types`."""
@enum VerificationResult::UInt8 begin
    VALID_PROOF = 0
    INVALID_PROOF = 1
    INCONSISTENT_TREE = 2
    STALE_STH = 3
end


"""CT log server states.  Matches `ServerState` in `CtlogABI.Types`."""
@enum ServerState::UInt8 begin
    IDLE = 0
    ACTIVE = 1
    MERGING = 2
    SIGNING = 3
    SHUTDOWN = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_ctlog."""
function abi_version()::UInt32
    ccall((:ctlog_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Certificate Transparency log (RFC 6962) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:ctlog_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Certificate Transparency log (RFC 6962) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:ctlog_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ServerState

Get the current Certificate Transparency log (RFC 6962) lifecycle state.
"""
function get_state(slot::SlotId)::ServerState
    ServerState(ccall((:ctlog_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ServerState, to::ServerState) -> Bool

Check whether a Certificate Transparency log (RFC 6962) state transition is valid.
"""
function can_transition(from::ServerState, to::ServerState)::Bool
    ccall((:ctlog_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Ctlog
