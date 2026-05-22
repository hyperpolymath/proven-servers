// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// virt.zig -- Zig FFI implementation of proven-virt.
//
// Implements the virtualization management state machine with:
//   - 64-slot mutex-protected VM session pool
//   - VM lifecycle state machine with transition validation
//   - Disk, network, and boot device configuration
//   - Resource tracking (vCPUs, memory)
//   - Operation validation against current VM state
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching VirtABI.Types exactly.

const std = @import("std");

// =========================================================================
// Enums (matching VirtABI.Types tag assignments)
// =========================================================================

/// VM lifecycle states (ABI tags 0-7).
pub const VMState = enum(u8) {
    creating = 0,
    running = 1,
    paused = 2,
    suspended = 3,
    shutting_down = 4,
    stopped = 5,
    crashed = 6,
    migrating = 7,
};

/// VM operations (ABI tags 0-10).
pub const Operation = enum(u8) {
    create = 0,
    start = 1,
    stop = 2,
    restart = 3,
    pause = 4,
    resume_ = 5,
    suspend_ = 6,
    migrate = 7,
    snapshot = 8,
    clone = 9,
    delete = 10,
};

/// Disk image formats (ABI tags 0-4).
pub const DiskFormat = enum(u8) {
    raw = 0,
    qcow2 = 1,
    vdi = 2,
    vmdk = 3,
    vhd = 4,
};

/// Virtual network types (ABI tags 0-3).
pub const NetworkType = enum(u8) {
    nat = 0,
    bridged = 1,
    internal = 2,
    host_only = 3,
};

/// Boot devices (ABI tags 0-3).
pub const BootDevice = enum(u8) {
    hard_disk = 0,
    cdrom = 1,
    network = 2,
    usb = 3,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent VM sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum VM name length.
const MAX_NAME_LEN: usize = 256;

/// Maximum migration destination length.
const MAX_DEST_LEN: usize = 512;

/// A virtual machine session.
const Session = struct {
    /// Current VM lifecycle state.
    state: VMState,
    /// VM name.
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    /// Number of virtual CPUs.
    vcpus: u16,
    /// Memory in megabytes.
    memory_mb: u32,
    /// Disk format.
    disk_format: DiskFormat,
    /// Network type.
    net_type: NetworkType,
    /// Boot device.
    boot_device: BootDevice,
    /// Migration destination (valid only during migration).
    migrate_dest: [MAX_DEST_LEN]u8,
    migrate_dest_len: u32,
    /// Number of snapshots taken.
    snapshot_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .stopped,
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .vcpus = 1,
    .memory_mb = 512,
    .disk_format = .qcow2,
    .net_type = .nat,
    .boot_device = .hard_disk,
    .migrate_dest = [_]u8{0} ** MAX_DEST_LEN,
    .migrate_dest_len = 0,
    .snapshot_count = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

/// Returns the ABI version number.
pub export fn virt_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new VM. Returns slot index (>=0) or -1 on failure.
pub export fn virt_create(
    name_ptr: [*]const u8,
    name_len: u32,
    vcpus: u16,
    memory_mb: u32,
    disk_fmt: u8,
    net_type: u8,
    boot_dev: u8,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (name_len == 0 or name_len > MAX_NAME_LEN) return -1;
    if (vcpus == 0) return -1;
    if (memory_mb == 0) return -1;
    if (disk_fmt > 4) return -1;
    if (net_type > 3) return -1;
    if (boot_dev > 3) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.name[0..name_len], name_ptr[0..name_len]);
            s.name_len = name_len;
            s.vcpus = vcpus;
            s.memory_mb = memory_mb;
            s.disk_format = @enumFromInt(disk_fmt);
            s.net_type = @enumFromInt(net_type);
            s.boot_device = @enumFromInt(boot_dev);
            s.state = .creating;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a VM slot.
pub export fn virt_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current VMState tag for a VM.
pub export fn virt_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 5; // stopped fallback
    return @intFromEnum(sessions[idx].state);
}

/// Start a VM. Returns 0 on success, 1 on rejection.
/// Valid from Creating or Stopped.
pub export fn virt_start(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .creating or state == .stopped) {
        sessions[idx].state = .running;
        return 0;
    }
    return 1;
}

/// Stop a VM. Returns 0 on success, 1 on rejection.
/// Valid from Running.
pub export fn virt_stop(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .running) return 1;
    sessions[idx].state = .stopped;
    return 0;
}

/// Pause a VM. Returns 0 on success, 1 on rejection.
/// Valid from Running.
pub export fn virt_pause(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .running) return 1;
    sessions[idx].state = .paused;
    return 0;
}

/// Resume a paused VM. Returns 0 on success, 1 on rejection.
/// Valid from Paused.
pub export fn virt_resume(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .paused) return 1;
    sessions[idx].state = .running;
    return 0;
}

/// Suspend a VM to disk. Returns 0 on success, 1 on rejection.
/// Valid from Running.
pub export fn virt_suspend(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .running) return 1;
    sessions[idx].state = .suspended;
    return 0;
}

/// Restart a running VM. Returns 0 on success, 1 on rejection.
/// Valid from Running (transitions Running -> Running).
pub export fn virt_restart(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .running) return 1;
    // Restart: remains running (simulated stop+start)
    return 0;
}

/// Begin live migration. Returns 0 on success, 1 on rejection.
/// Valid from Running.
pub export fn virt_migrate_begin(
    slot: c_int,
    dest_ptr: [*]const u8,
    dest_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .running) return 1;
    if (dest_len == 0 or dest_len > MAX_DEST_LEN) return 1;

    @memcpy(sessions[idx].migrate_dest[0..dest_len], dest_ptr[0..dest_len]);
    sessions[idx].migrate_dest_len = dest_len;
    sessions[idx].state = .migrating;
    return 0;
}

/// Complete migration. Returns 0 on success, 1 on rejection.
/// Transitions Migrating -> Running.
pub export fn virt_migrate_complete(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .migrating) return 1;

    sessions[idx].migrate_dest_len = 0;
    sessions[idx].state = .running;
    return 0;
}

/// Delete a VM. Returns 0 on success, 1 on rejection.
/// Valid from Stopped or Crashed.
pub export fn virt_delete(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .stopped or state == .crashed) {
        sessions[idx] = empty_session;
        return 0;
    }
    return 1;
}

/// Check if an operation is valid from the given VM state.
/// Returns 1 if valid, 0 if not.
pub export fn virt_can_transition(from: u8, op: u8) callconv(.c) u8 {
    // from=VMState tag, op=Operation tag
    if (op == 1) { // Start
        if (from == 0 or from == 5) return 1; // Creating/Stopped
    }
    if (op == 2) { // Stop
        if (from == 1) return 1; // Running
    }
    if (op == 3) { // Restart
        if (from == 1) return 1; // Running
    }
    if (op == 4) { // Pause
        if (from == 1) return 1; // Running
    }
    if (op == 5) { // Resume
        if (from == 2) return 1; // Paused
    }
    if (op == 6) { // Suspend
        if (from == 1) return 1; // Running
    }
    if (op == 7) { // Migrate
        if (from == 1) return 1; // Running
    }
    if (op == 8) { // Snapshot
        if (from == 1 or from == 2 or from == 5) return 1; // Running/Paused/Stopped
    }
    if (op == 9) { // Clone
        if (from == 5) return 1; // Stopped
    }
    if (op == 10) { // Delete
        if (from == 5 or from == 6) return 1; // Stopped/Crashed
    }
    return 0;
}

/// Returns vCPU count for a VM.
pub export fn virt_vcpu_count(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].vcpus;
}

/// Returns memory (MB) for a VM.
pub export fn virt_memory_mb(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].memory_mb;
}

/// Returns disk format tag for a VM.
pub export fn virt_disk_format(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].disk_format);
}

/// Returns number of active VM sessions.
pub export fn virt_session_count() callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    var count: u32 = 0;
    for (&sessions) |*s| {
        if (s.active) count += 1;
    }
    return count;
}
