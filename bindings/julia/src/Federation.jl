# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-federation protocol (ActivityPub federation).
#
# Wraps the C-ABI functions from protocols/proven-federation/ffi/zig/src/federation.zig
# via ccall into libproven_federation.so.

module Federation

using ..ProvenServers: check_status, check_slot, SlotId

export ActivityType, ActorType, DeliveryStatus, TrustLevel, ObjectType, ServerState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_federation"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""ActivityPub activity types.  Matches `ActivityType` in `FederationABI.Types`."""
@enum ActivityType::UInt8 begin
    CREATE = 0
    UPDATE = 1
    DELETE = 2
    FOLLOW = 3
    ACCEPT = 4
    REJECT = 5
    ANNOUNCE = 6
    LIKE = 7
    UNDO = 8
    BLOCK = 9
    FLAG = 10
end


"""ActivityPub actor types.  Matches `ActorType` in `FederationABI.Types`."""
@enum ActorType::UInt8 begin
    PERSON = 0
    SERVICE = 1
    APPLICATION = 2
    GROUP = 3
    ORGANIZATION = 4
end


"""Federation delivery statuses.  Matches `DeliveryStatus` in `FederationABI.Types`."""
@enum DeliveryStatus::UInt8 begin
    PENDING = 0
    DELIVERED = 1
    FAILED = 2
    REJECTED = 3
    DEFERRED = 4
end


"""Federation trust levels.  Matches `TrustLevel` in `FederationABI.Types`."""
@enum TrustLevel::UInt8 begin
    SELF_SIGNED = 0
    PEER_VERIFIED = 1
    FEDERATION_TRUSTED = 2
    REVOKED = 3
    UNKNOWN = 4
end


"""ActivityPub object types.  Matches `ObjectType` in `FederationABI.Types`."""
@enum ObjectType::UInt8 begin
    NOTE = 0
    ARTICLE = 1
    IMAGE = 2
    VIDEO = 3
    AUDIO = 4
    DOCUMENT = 5
    EVENT = 6
    COLLECTION = 7
    ORDERED_COLLECTION = 8
end


"""Federation server states.  Matches `ServerState` in `FederationABI.Types`."""
@enum ServerState::UInt8 begin
    IDLE = 0
    ACTIVE = 1
    PROCESSING = 2
    DELIVERING = 3
    SHUTDOWN = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_federation."""
function abi_version()::UInt32
    ccall((:federation_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new ActivityPub federation context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:federation_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given ActivityPub federation context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:federation_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ServerState

Get the current ActivityPub federation lifecycle state.
"""
function get_state(slot::SlotId)::ServerState
    ServerState(ccall((:federation_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ServerState, to::ServerState) -> Bool

Check whether a ActivityPub federation state transition is valid.
"""
function can_transition(from::ServerState, to::ServerState)::Bool
    ccall((:federation_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Federation
