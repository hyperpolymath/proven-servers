# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-objectstore protocol (S3-compatible object store).
#
# Wraps the C-ABI functions from protocols/proven-objectstore/ffi/zig/src/objectstore.zig
# via ccall into libproven_objectstore.so.

module Objectstore

using ..ProvenServers: check_status, check_slot, SlotId

export OBJECTSTORE_PORT,
       ObjOperation,
       StorageClass,
       Acl,
       ObjErrorCode,
       ObjSessionState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_objectstore"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""OBJECTSTORE_PORT: protocol constant."""
const OBJECTSTORE_PORT = UInt16(9000)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Object store operations."""
@enum ObjOperation::UInt8 begin
    OP_PUT_OBJECT = 0
    OP_GET_OBJECT = 1
    OP_DELETE_OBJECT = 2
    OP_LIST_OBJECTS = 3
    OP_HEAD_OBJECT = 4
    OP_COPY_OBJECT = 5
    OP_CREATE_BUCKET = 6
    OP_DELETE_BUCKET = 7
    OP_LIST_BUCKETS = 8
    OP_INIT_MULTIPART_UPLOAD = 9
    OP_UPLOAD_PART = 10
    OP_COMPLETE_MULTIPART_UPLOAD = 11
end

"""Object storage classes."""
@enum StorageClass::UInt8 begin
    SC_STANDARD = 0
    SC_INFREQUENT_ACCESS = 1
    SC_GLACIER = 2
    SC_DEEP_ARCHIVE = 3
    SC_ONE_ZONE = 4
end

"""Object ACL policies."""
@enum Acl::UInt8 begin
    ACL_PRIVATE = 0
    ACL_PUBLIC_READ = 1
    ACL_PUBLIC_READ_WRITE = 2
    ACL_AUTHENTICATED_READ = 3
end

"""Object store error codes."""
@enum ObjErrorCode::UInt8 begin
    ERR_NO_SUCH_BUCKET = 0
    ERR_NO_SUCH_KEY = 1
    ERR_BUCKET_ALREADY_EXISTS = 2
    ERR_BUCKET_NOT_EMPTY = 3
    ERR_ACCESS_DENIED = 4
    ERR_ENTITY_TOO_LARGE = 5
    ERR_INVALID_PART = 6
    ERR_INCOMPLETE_BODY = 7
end

"""Object store session states."""
@enum ObjSessionState::UInt8 begin
    STATE_IDLE = 0
    STATE_READY = 1
    STATE_BUCKET_ACTIVE = 2
    STATE_UPLOADING = 3
    STATE_CLOSING = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_objectstore."""
function abi_version()::UInt32
    ccall((:objectstore_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Objectstore context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:objectstore_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Objectstore context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:objectstore_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ObjSessionState

Get the current Objectstore lifecycle state.
"""
function get_state(slot::SlotId)::ObjSessionState
    ObjSessionState(ccall((:objectstore_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ObjSessionState, to::ObjSessionState) -> Bool

Check whether a Objectstore state transition is valid.
"""
function can_transition(from::ObjSessionState, to::ObjSessionState)::Bool
    ccall((:objectstore_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Objectstore
