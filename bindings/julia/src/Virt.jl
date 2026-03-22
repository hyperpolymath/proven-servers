# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-virt protocol (Virtualization manager).
#
# Wraps the C-ABI functions from protocols/proven-virt/ffi/zig/src/virt.zig
# via ccall into libproven_virt.so.

module Virt

using ..ProvenServers: check_status, check_slot, SlotId

export VmState,
       VirtOperation,
       DiskFormat,
       NetworkType,
       BootDevice,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_virt"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Virtual machine states."""
@enum VmState::UInt8 begin
    VM_CREATING = 0
    VM_RUNNING = 1
    VM_PAUSED = 2
    VM_SUSPENDED = 3
    VM_SHUTTING_DOWN = 4
    VM_STOPPED = 5
    VM_CRASHED = 6
    VM_MIGRATING = 7
end

"""Virtualization operations."""
@enum VirtOperation::UInt8 begin
    OP_CREATE = 0
    OP_START = 1
    OP_STOP = 2
    OP_RESTART = 3
    OP_PAUSE = 4
    OP_RESUME = 5
    OP_SUSPEND = 6
    OP_MIGRATE = 7
    OP_SNAPSHOT = 8
    OP_CLONE = 9
    OP_DELETE = 10
end

"""Virtual disk formats."""
@enum DiskFormat::UInt8 begin
    DISK_RAW = 0
    DISK_QCOW2 = 1
    DISK_VDI = 2
    DISK_VMDK = 3
    DISK_VHD = 4
end

"""Virtual network types."""
@enum NetworkType::UInt8 begin
    NET_NAT = 0
    NET_BRIDGED = 1
    NET_INTERNAL = 2
    NET_HOST_ONLY = 3
end

"""Virtual machine boot devices."""
@enum BootDevice::UInt8 begin
    BOOT_HARD_DISK = 0
    BOOT_CDROM = 1
    BOOT_NETWORK = 2
    BOOT_USB = 3
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_virt."""
function abi_version()::UInt32
    ccall((:virt_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Virt context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:virt_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Virt context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:virt_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> VmState

Get the current Virt lifecycle state.
"""
function get_state(slot::SlotId)::VmState
    VmState(ccall((:virt_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::VmState, to::VmState) -> Bool

Check whether a Virt state transition is valid.
"""
function can_transition(from::VmState, to::VmState)::Bool
    ccall((:virt_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Virt
