# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-cache protocol (cache server (Redis/Memcached)).
#
# Wraps the C-ABI functions from protocols/proven-cache/ffi/zig/src/cache.zig
# via ccall into libproven_cache.so.

module Cache

using ..ProvenServers: check_status, check_slot, SlotId

export Command, EvictionPolicy, DataType, ErrorCode, ReplicationMode,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_cache"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Cache server commands.  Matches `Command` in `CacheABI.Types`."""
@enum Command::UInt8 begin
    GET = 0
    SET = 1
    DELETE = 2
    EXISTS = 3
    EXPIRE = 4
    TTL = 5
    KEYS = 6
    FLUSH = 7
    INCR = 8
    DECR = 9
    APPEND = 10
    PREPEND = 11
    CAS = 12
end


"""Cache eviction policy strategies.  Matches `EvictionPolicy` in `CacheABI.Types`."""
@enum EvictionPolicy::UInt8 begin
    LRU = 0
    LFU = 1
    RANDOM = 2
    EVICT_TTL = 3
    NO_EVICTION = 4
end


"""Cache stored value types.  Matches `DataType` in `CacheABI.Types`."""
@enum DataType::UInt8 begin
    STRING_VAL = 0
    INT_VAL = 1
    LIST_VAL = 2
    SET_VAL = 3
    HASH_VAL = 4
end


"""Cache error codes.  Matches `ErrorCode` in `CacheABI.Types`."""
@enum ErrorCode::UInt8 begin
    NOT_FOUND = 0
    TYPE_MISMATCH = 1
    OUT_OF_MEMORY = 2
    KEY_TOO_LONG = 3
    VALUE_TOO_LARGE = 4
    CAS_CONFLICT = 5
end


"""Cache replication topology roles.  Matches `ReplicationMode` in `CacheABI.Types`."""
@enum ReplicationMode::UInt8 begin
    NONE = 0
    PRIMARY = 1
    REPLICA = 2
    SENTINEL = 3
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_cache."""
function abi_version()::UInt32
    ccall((:cache_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new cache server (Redis/Memcached) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:cache_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given cache server (Redis/Memcached) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:cache_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ReplicationMode

Get the current cache server (Redis/Memcached) lifecycle state.
"""
function get_state(slot::SlotId)::ReplicationMode
    ReplicationMode(ccall((:cache_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ReplicationMode, to::ReplicationMode) -> Bool

Check whether a cache server (Redis/Memcached) state transition is valid.
"""
function can_transition(from::ReplicationMode, to::ReplicationMode)::Bool
    ccall((:cache_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Cache
