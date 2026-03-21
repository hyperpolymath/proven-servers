// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-virt FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - VM lifecycle (create/destroy)
//   - Start from Creating and Stopped
//   - Stop from Running
//   - Pause / Resume
//   - Suspend from Running
//   - Restart from Running
//   - Migration begin/complete
//   - Delete from Stopped/Crashed
//   - Resource queries (vCPU, memory, disk format)
//   - Stateless operation validity table
//   - Invalid slot safety
//   - Session count tracking
//   - Impossibility (invalid operations)

const std = @import("std");
const virt = @import("virt");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), virt.virt_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "VMState encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(virt.VMState.creating));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(virt.VMState.running));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(virt.VMState.paused));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(virt.VMState.suspended));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(virt.VMState.shutting_down));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(virt.VMState.stopped));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(virt.VMState.crashed));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(virt.VMState.migrating));
}

test "Operation encoding matches Types.idr (11 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(virt.Operation.create));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(virt.Operation.start));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(virt.Operation.stop));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(virt.Operation.restart));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(virt.Operation.pause));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(virt.Operation.resume_));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(virt.Operation.suspend_));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(virt.Operation.migrate));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(virt.Operation.snapshot));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(virt.Operation.clone));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(virt.Operation.delete));
}

test "DiskFormat encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(virt.DiskFormat.raw));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(virt.DiskFormat.qcow2));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(virt.DiskFormat.vdi));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(virt.DiskFormat.vmdk));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(virt.DiskFormat.vhd));
}

test "NetworkType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(virt.NetworkType.nat));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(virt.NetworkType.bridged));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(virt.NetworkType.internal));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(virt.NetworkType.host_only));
}

test "BootDevice encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(virt.BootDevice.hard_disk));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(virt.BootDevice.cdrom));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(virt.BootDevice.network));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(virt.BootDevice.usb));
}

// =========================================================================
// VM lifecycle
// =========================================================================

test "create returns valid slot in Creating state" {
    const name = "test-vm";
    const slot = virt.virt_create(name.ptr, name.len, 2, 1024, 1, 0, 0);
    try std.testing.expect(slot >= 0);
    defer virt.virt_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), virt.virt_state(slot)); // Creating
}

test "create rejects empty name" {
    const name = "x";
    try std.testing.expectEqual(@as(c_int, -1), virt.virt_create(name.ptr, 0, 2, 1024, 1, 0, 0));
}

test "create rejects zero vcpus" {
    const name = "bad-vm";
    try std.testing.expectEqual(@as(c_int, -1), virt.virt_create(name.ptr, name.len, 0, 1024, 1, 0, 0));
}

test "create rejects zero memory" {
    const name = "bad-vm";
    try std.testing.expectEqual(@as(c_int, -1), virt.virt_create(name.ptr, name.len, 2, 0, 1, 0, 0));
}

test "create rejects invalid disk format" {
    const name = "bad-vm";
    try std.testing.expectEqual(@as(c_int, -1), virt.virt_create(name.ptr, name.len, 2, 1024, 99, 0, 0));
}

test "destroy is safe with invalid slot" {
    virt.virt_destroy(-1);
    virt.virt_destroy(999);
}

// =========================================================================
// Start / Stop
// =========================================================================

test "start transitions Creating -> Running" {
    const name = "start-vm";
    const slot = virt.virt_create(name.ptr, name.len, 4, 2048, 1, 0, 0);
    defer virt.virt_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), virt.virt_start(slot));
    try std.testing.expectEqual(@as(u8, 1), virt.virt_state(slot)); // Running
}

test "stop transitions Running -> Stopped" {
    const name = "stop-vm";
    const slot = virt.virt_create(name.ptr, name.len, 2, 1024, 1, 0, 0);
    defer virt.virt_destroy(slot);

    _ = virt.virt_start(slot);
    try std.testing.expectEqual(@as(u8, 0), virt.virt_stop(slot));
    try std.testing.expectEqual(@as(u8, 5), virt.virt_state(slot)); // Stopped
}

test "start from Stopped (restart cycle)" {
    const name = "restart-vm";
    const slot = virt.virt_create(name.ptr, name.len, 2, 1024, 1, 0, 0);
    defer virt.virt_destroy(slot);

    _ = virt.virt_start(slot);
    _ = virt.virt_stop(slot);
    try std.testing.expectEqual(@as(u8, 0), virt.virt_start(slot));
    try std.testing.expectEqual(@as(u8, 1), virt.virt_state(slot)); // Running
}

test "stop rejected from Paused" {
    const name = "paused-vm";
    const slot = virt.virt_create(name.ptr, name.len, 2, 1024, 1, 0, 0);
    defer virt.virt_destroy(slot);

    _ = virt.virt_start(slot);
    _ = virt.virt_pause(slot);
    try std.testing.expectEqual(@as(u8, 1), virt.virt_stop(slot));
}

// =========================================================================
// Pause / Resume
// =========================================================================

test "pause transitions Running -> Paused" {
    const name = "pause-vm";
    const slot = virt.virt_create(name.ptr, name.len, 2, 1024, 1, 0, 0);
    defer virt.virt_destroy(slot);

    _ = virt.virt_start(slot);
    try std.testing.expectEqual(@as(u8, 0), virt.virt_pause(slot));
    try std.testing.expectEqual(@as(u8, 2), virt.virt_state(slot)); // Paused
}

test "resume transitions Paused -> Running" {
    const name = "resume-vm";
    const slot = virt.virt_create(name.ptr, name.len, 2, 1024, 1, 0, 0);
    defer virt.virt_destroy(slot);

    _ = virt.virt_start(slot);
    _ = virt.virt_pause(slot);
    try std.testing.expectEqual(@as(u8, 0), virt.virt_resume(slot));
    try std.testing.expectEqual(@as(u8, 1), virt.virt_state(slot)); // Running
}

test "resume rejected from Running" {
    const name = "running-vm";
    const slot = virt.virt_create(name.ptr, name.len, 2, 1024, 1, 0, 0);
    defer virt.virt_destroy(slot);

    _ = virt.virt_start(slot);
    try std.testing.expectEqual(@as(u8, 1), virt.virt_resume(slot));
}

// =========================================================================
// Suspend
// =========================================================================

test "suspend transitions Running -> Suspended" {
    const name = "suspend-vm";
    const slot = virt.virt_create(name.ptr, name.len, 2, 1024, 1, 0, 0);
    defer virt.virt_destroy(slot);

    _ = virt.virt_start(slot);
    try std.testing.expectEqual(@as(u8, 0), virt.virt_suspend(slot));
    try std.testing.expectEqual(@as(u8, 3), virt.virt_state(slot)); // Suspended
}

// =========================================================================
// Restart
// =========================================================================

test "restart from Running" {
    const name = "restart-running";
    const slot = virt.virt_create(name.ptr, name.len, 2, 1024, 1, 0, 0);
    defer virt.virt_destroy(slot);

    _ = virt.virt_start(slot);
    try std.testing.expectEqual(@as(u8, 0), virt.virt_restart(slot));
    try std.testing.expectEqual(@as(u8, 1), virt.virt_state(slot)); // Running
}

test "restart rejected from Stopped" {
    const name = "stopped-vm";
    const slot = virt.virt_create(name.ptr, name.len, 2, 1024, 1, 0, 0);
    defer virt.virt_destroy(slot);

    _ = virt.virt_start(slot);
    _ = virt.virt_stop(slot);
    try std.testing.expectEqual(@as(u8, 1), virt.virt_restart(slot));
}

// =========================================================================
// Migration
// =========================================================================

test "migration lifecycle Running -> Migrating -> Running" {
    const name = "migrate-vm";
    const slot = virt.virt_create(name.ptr, name.len, 4, 4096, 1, 1, 0);
    defer virt.virt_destroy(slot);

    _ = virt.virt_start(slot);

    const dest = "host2.example.com";
    try std.testing.expectEqual(@as(u8, 0), virt.virt_migrate_begin(slot, dest.ptr, dest.len));
    try std.testing.expectEqual(@as(u8, 7), virt.virt_state(slot)); // Migrating

    try std.testing.expectEqual(@as(u8, 0), virt.virt_migrate_complete(slot));
    try std.testing.expectEqual(@as(u8, 1), virt.virt_state(slot)); // Running
}

test "migrate_begin rejected from Stopped" {
    const name = "stopped-vm";
    const slot = virt.virt_create(name.ptr, name.len, 2, 1024, 1, 0, 0);
    defer virt.virt_destroy(slot);

    _ = virt.virt_start(slot);
    _ = virt.virt_stop(slot);

    const dest = "host2";
    try std.testing.expectEqual(@as(u8, 1), virt.virt_migrate_begin(slot, dest.ptr, dest.len));
}

// =========================================================================
// Delete
// =========================================================================

test "delete from Stopped" {
    const name = "delete-vm";
    const slot = virt.virt_create(name.ptr, name.len, 2, 1024, 1, 0, 0);

    _ = virt.virt_start(slot);
    _ = virt.virt_stop(slot);
    try std.testing.expectEqual(@as(u8, 0), virt.virt_delete(slot));
}

test "delete rejected from Running" {
    const name = "running-vm";
    const slot = virt.virt_create(name.ptr, name.len, 2, 1024, 1, 0, 0);
    defer virt.virt_destroy(slot);

    _ = virt.virt_start(slot);
    try std.testing.expectEqual(@as(u8, 1), virt.virt_delete(slot));
}

// =========================================================================
// Resource queries
// =========================================================================

test "vcpu_count returns configured vCPUs" {
    const name = "resource-vm";
    const slot = virt.virt_create(name.ptr, name.len, 8, 16384, 0, 1, 2);
    defer virt.virt_destroy(slot);

    try std.testing.expectEqual(@as(u16, 8), virt.virt_vcpu_count(slot));
}

test "memory_mb returns configured memory" {
    const name = "mem-vm";
    const slot = virt.virt_create(name.ptr, name.len, 4, 32768, 1, 0, 0);
    defer virt.virt_destroy(slot);

    try std.testing.expectEqual(@as(u32, 32768), virt.virt_memory_mb(slot));
}

test "disk_format returns configured format" {
    const name = "disk-vm";
    const slot = virt.virt_create(name.ptr, name.len, 2, 1024, 3, 0, 0); // vmdk
    defer virt.virt_destroy(slot);

    try std.testing.expectEqual(@as(u8, 3), virt.virt_disk_format(slot)); // vmdk
}

// =========================================================================
// Stateless operation validity table
// =========================================================================

test "virt_can_transition matches Types.idr" {
    // Start valid from Creating(0) and Stopped(5)
    try std.testing.expectEqual(@as(u8, 1), virt.virt_can_transition(0, 1));
    try std.testing.expectEqual(@as(u8, 1), virt.virt_can_transition(5, 1));

    // Stop, Restart, Pause, Suspend, Migrate valid from Running(1)
    try std.testing.expectEqual(@as(u8, 1), virt.virt_can_transition(1, 2)); // Stop
    try std.testing.expectEqual(@as(u8, 1), virt.virt_can_transition(1, 3)); // Restart
    try std.testing.expectEqual(@as(u8, 1), virt.virt_can_transition(1, 4)); // Pause
    try std.testing.expectEqual(@as(u8, 1), virt.virt_can_transition(1, 6)); // Suspend
    try std.testing.expectEqual(@as(u8, 1), virt.virt_can_transition(1, 7)); // Migrate

    // Resume valid from Paused(2)
    try std.testing.expectEqual(@as(u8, 1), virt.virt_can_transition(2, 5));

    // Snapshot valid from Running(1), Paused(2), Stopped(5)
    try std.testing.expectEqual(@as(u8, 1), virt.virt_can_transition(1, 8));
    try std.testing.expectEqual(@as(u8, 1), virt.virt_can_transition(2, 8));
    try std.testing.expectEqual(@as(u8, 1), virt.virt_can_transition(5, 8));

    // Clone valid from Stopped(5)
    try std.testing.expectEqual(@as(u8, 1), virt.virt_can_transition(5, 9));

    // Delete valid from Stopped(5) and Crashed(6)
    try std.testing.expectEqual(@as(u8, 1), virt.virt_can_transition(5, 10));
    try std.testing.expectEqual(@as(u8, 1), virt.virt_can_transition(6, 10));

    // Invalid: Stop from Paused
    try std.testing.expectEqual(@as(u8, 0), virt.virt_can_transition(2, 2));
    // Invalid: Start from Running
    try std.testing.expectEqual(@as(u8, 0), virt.virt_can_transition(1, 1));
    // Invalid: Delete from Running
    try std.testing.expectEqual(@as(u8, 0), virt.virt_can_transition(1, 10));
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 5), virt.virt_state(-1)); // stopped fallback
    try std.testing.expectEqual(@as(u16, 0), virt.virt_vcpu_count(-1));
    try std.testing.expectEqual(@as(u32, 0), virt.virt_memory_mb(-1));
    try std.testing.expectEqual(@as(u8, 0), virt.virt_disk_format(-1));
    try std.testing.expectEqual(@as(u8, 1), virt.virt_start(-1));
    try std.testing.expectEqual(@as(u8, 1), virt.virt_stop(-1));
}

// =========================================================================
// Session count
// =========================================================================

test "session_count tracks active sessions" {
    const initial = virt.virt_session_count();
    const name = "count-vm";
    const slot = virt.virt_create(name.ptr, name.len, 2, 1024, 1, 0, 0);
    try std.testing.expectEqual(initial + 1, virt.virt_session_count());
    virt.virt_destroy(slot);
    try std.testing.expectEqual(initial, virt.virt_session_count());
}
