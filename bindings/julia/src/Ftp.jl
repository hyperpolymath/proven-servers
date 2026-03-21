# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-ftp protocol (FTP server).
#
# Wraps the C-ABI functions from protocols/proven-ftp/ffi/zig/src/ftp.zig
# via ccall into libproven_ftp.so.

module Ftp

using ..ProvenServers: check_status, check_slot, SlotId

export FtpSessionState, TransferType, DataMode, TransferState,
       abi_version, create, destroy, get_state, user_cmd, pass_cmd,
       quit, cwd_cmd, cdup, set_type, set_passive, set_active,
       begin_transfer, complete_transfer, abort_transfer,
       begin_rename, complete_rename, bytes_transferred,
       can_transfer, can_transition

const LIB = "libproven_ftp"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""FTP session states matching SessionState in ftp.zig."""
@enum FtpSessionState::UInt8 begin
    STATE_CONNECTED     = 0
    STATE_USER_OK       = 1
    STATE_AUTHENTICATED = 2
    STATE_RENAMING      = 3
    STATE_QUIT          = 4
end

"""FTP transfer types."""
@enum TransferType::UInt8 begin
    TYPE_ASCII  = 0
    TYPE_BINARY = 1
end

"""FTP data connection modes."""
@enum DataMode::UInt8 begin
    MODE_NONE    = 0
    MODE_PASSIVE = 1
    MODE_ACTIVE  = 2
end

"""FTP data transfer states."""
@enum TransferState::UInt8 begin
    TRANSFER_IDLE        = 0
    TRANSFER_IN_PROGRESS = 1
    TRANSFER_COMPLETE    = 2
    TRANSFER_ABORTED     = 3
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_ftp."""
function abi_version()::UInt32
    ccall((:ftp_abi_version, LIB), UInt32, ())
end

"""
    create() -> SlotId

Create a new FTP session. Throws on pool exhaustion.
"""
function create()::SlotId
    check_slot(ccall((:ftp_create, LIB), Cint, ()))
end

"""
    destroy(slot::SlotId)

Release the given FTP context slot.
"""
function destroy(slot::SlotId)::Nothing
    ccall((:ftp_destroy, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> FtpSessionState

Get the current FTP session state.
"""
function get_state(slot::SlotId)::FtpSessionState
    FtpSessionState(ccall((:ftp_state, LIB), UInt8, (Cint,), slot))
end

"""
    user_cmd(slot::SlotId, name::String)

Send USER command. Throws on invalid state.
"""
function user_cmd(slot::SlotId, name::String)::Nothing
    data = Vector{UInt8}(name)
    check_status(ccall((:ftp_user, LIB), UInt8,
                       (Cint, Ptr{UInt8}, UInt32),
                       slot, data, UInt32(length(data))))
end

"""
    pass_cmd(slot::SlotId, password::String)

Send PASS command. Throws on invalid state.
"""
function pass_cmd(slot::SlotId, password::String)::Nothing
    data = Vector{UInt8}(password)
    check_status(ccall((:ftp_pass, LIB), UInt8,
                       (Cint, Ptr{UInt8}, UInt32),
                       slot, data, UInt32(length(data))))
end

"""
    quit(slot::SlotId)

Send QUIT command. Throws on invalid state.
"""
function quit(slot::SlotId)::Nothing
    check_status(ccall((:ftp_quit, LIB), UInt8, (Cint,), slot))
end

"""
    cwd_cmd(slot::SlotId, path::String)

Change working directory. Throws on invalid state.
"""
function cwd_cmd(slot::SlotId, path::String)::Nothing
    data = Vector{UInt8}(path)
    check_status(ccall((:ftp_cwd_cmd, LIB), UInt8,
                       (Cint, Ptr{UInt8}, UInt32),
                       slot, data, UInt32(length(data))))
end

"""
    cdup(slot::SlotId)

Change to parent directory. Throws on invalid state.
"""
function cdup(slot::SlotId)::Nothing
    check_status(ccall((:ftp_cdup, LIB), UInt8, (Cint,), slot))
end

"""
    set_type(slot::SlotId, t::TransferType)

Set transfer type (ASCII/Binary). Throws on invalid state.
"""
function set_type(slot::SlotId, t::TransferType)::Nothing
    check_status(ccall((:ftp_set_type, LIB), UInt8,
                       (Cint, UInt8), slot, UInt8(t)))
end

"""
    set_passive(slot::SlotId)

Enter passive mode. Throws on invalid state.
"""
function set_passive(slot::SlotId)::Nothing
    check_status(ccall((:ftp_set_passive, LIB), UInt8, (Cint,), slot))
end

"""
    set_active(slot::SlotId, port::UInt16)

Enter active mode with given port. Throws on invalid state.
"""
function set_active(slot::SlotId, port::UInt16)::Nothing
    check_status(ccall((:ftp_set_active, LIB), UInt8,
                       (Cint, UInt16), slot, port))
end

"""
    begin_transfer(slot::SlotId)

Begin a data transfer. Throws on invalid state.
"""
function begin_transfer(slot::SlotId)::Nothing
    check_status(ccall((:ftp_begin_transfer, LIB), UInt8, (Cint,), slot))
end

"""
    complete_transfer(slot::SlotId)

Complete a data transfer. Throws on invalid state.
"""
function complete_transfer(slot::SlotId)::Nothing
    check_status(ccall((:ftp_complete_transfer, LIB), UInt8, (Cint,), slot))
end

"""
    abort_transfer(slot::SlotId)

Abort a data transfer. Throws on invalid state.
"""
function abort_transfer(slot::SlotId)::Nothing
    check_status(ccall((:ftp_abort_transfer, LIB), UInt8, (Cint,), slot))
end

"""
    begin_rename(slot::SlotId)

Begin a rename operation (RNFR). Throws on invalid state.
"""
function begin_rename(slot::SlotId)::Nothing
    check_status(ccall((:ftp_begin_rename, LIB), UInt8, (Cint,), slot))
end

"""
    complete_rename(slot::SlotId)

Complete a rename operation (RNTO). Throws on invalid state.
"""
function complete_rename(slot::SlotId)::Nothing
    check_status(ccall((:ftp_complete_rename, LIB), UInt8, (Cint,), slot))
end

"""
    bytes_transferred(slot::SlotId) -> UInt64

Get the number of bytes transferred in the current/last transfer.
"""
function bytes_transferred(slot::SlotId)::UInt64
    ccall((:ftp_bytes_transferred, LIB), UInt64, (Cint,), slot)
end

"""
    can_transfer(state::FtpSessionState) -> Bool

Check if the given session state allows data transfer.
"""
function can_transfer(state::FtpSessionState)::Bool
    ccall((:ftp_can_transfer, LIB), UInt8, (UInt8,), UInt8(state)) == 0x01
end

"""
    can_transition(from::FtpSessionState, to::FtpSessionState) -> Bool

Check whether an FTP state transition is valid.
"""
function can_transition(from::FtpSessionState, to::FtpSessionState)::Bool
    ccall((:ftp_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Ftp
