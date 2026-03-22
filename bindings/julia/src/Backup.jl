# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-backup protocol (backup/restore server).
#
# Wraps the C-ABI functions from protocols/proven-backup/ffi/zig/src/backup.zig
# via ccall into libproven_backup.so.

module Backup

using ..ProvenServers: check_status, check_slot, SlotId

export BackupType, ScheduleFreq, CompressionAlg, EncryptionAlg, BackupState, RetentionPolicy,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_backup"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Backup types.  Matches `BackupType` in `BackupABI.Types`."""
@enum BackupType::UInt8 begin
    FULL = 0
    INCREMENTAL = 1
    DIFFERENTIAL = 2
    SNAPSHOT = 3
    MIRROR = 4
end


"""Backup schedule frequencies.  Matches `ScheduleFreq` in `BackupABI.Types`."""
@enum ScheduleFreq::UInt8 begin
    HOURLY = 0
    DAILY = 1
    WEEKLY = 2
    MONTHLY = 3
    ON_DEMAND = 4
end


"""Backup compression algorithms.  Matches `CompressionAlg` in `BackupABI.Types`."""
@enum CompressionAlg::UInt8 begin
    NONE = 0
    GZIP = 1
    ZSTD = 2
    LZ4 = 3
    XZ = 4
end


"""Backup encryption algorithms.  Matches `EncryptionAlg` in `BackupABI.Types`."""
@enum EncryptionAlg::UInt8 begin
    NO_ENCRYPTION = 0
    AES256_GCM = 1
    CHA_CHA20_POLY1305 = 2
end


"""Backup job states.  Matches `BackupState` in `BackupABI.Types`."""
@enum BackupState::UInt8 begin
    IDLE = 0
    RUNNING = 1
    VERIFYING = 2
    COMPLETE = 3
    FAILED = 4
    CANCELLED = 5
end


"""Backup retention policies.  Matches `RetentionPolicy` in `BackupABI.Types`."""
@enum RetentionPolicy::UInt8 begin
    KEEP_ALL = 0
    KEEP_LAST = 1
    KEEP_DAILY = 2
    KEEP_WEEKLY = 3
    KEEP_MONTHLY = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_backup."""
function abi_version()::UInt32
    ccall((:backup_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new backup/restore server context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:backup_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given backup/restore server context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:backup_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> BackupState

Get the current backup/restore server lifecycle state.
"""
function get_state(slot::SlotId)::BackupState
    BackupState(ccall((:backup_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::BackupState, to::BackupState) -> Bool

Check whether a backup/restore server state transition is valid.
"""
function can_transition(from::BackupState, to::BackupState)::Bool
    ccall((:backup_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Backup
