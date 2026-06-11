// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-netconf FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Datastore lock/unlock
//   - Edit-config, commit, discard
//   - Get-config, validate
//   - Close-session, kill-session
//   - Stateless transition table
//   - Invalid slot safety

const std = @import("std");
const netconf = @import("netconf");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), netconf.netconf_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Operation encoding matches Types.idr (12 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(netconf.Operation.get));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(netconf.Operation.get_config));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(netconf.Operation.edit_config));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(netconf.Operation.commit));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(netconf.Operation.discard_changes));
}

test "Datastore encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(netconf.Datastore.running));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(netconf.Datastore.startup));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(netconf.Datastore.candidate));
}

test "EditOperation encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(netconf.EditOperation.merge));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(netconf.EditOperation.replace));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(netconf.EditOperation.create));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(netconf.EditOperation.delete));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(netconf.EditOperation.remove));
}

test "NetconfState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(netconf.NetconfState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(netconf.NetconfState.connected));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(netconf.NetconfState.locked));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(netconf.NetconfState.editing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(netconf.NetconfState.closing));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(netconf.NetconfState.terminated));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Connected state" {
    const host = "192.168.1.1";
    const slot = netconf.netconf_create(host.ptr, host.len, 830);
    try std.testing.expect(slot >= 0);
    defer netconf.netconf_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_state(slot)); // Connected
}

test "create rejects empty host" {
    const host = "x";
    const slot = netconf.netconf_create(host.ptr, 0, 830);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects zero port" {
    const host = "router";
    const slot = netconf.netconf_create(host.ptr, host.len, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    netconf.netconf_destroy(-1);
    netconf.netconf_destroy(999);
}

// =========================================================================
// Lock / Unlock
// =========================================================================

test "lock transitions Connected -> Locked" {
    const host = "router1";
    const slot = netconf.netconf_create(host.ptr, host.len, 830);
    defer netconf.netconf_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), netconf.netconf_lock(slot, 0)); // Running
    try std.testing.expectEqual(@as(u8, 2), netconf.netconf_state(slot)); // Locked
}

test "unlock transitions Locked -> Connected" {
    const host = "router2";
    const slot = netconf.netconf_create(host.ptr, host.len, 830);
    defer netconf.netconf_destroy(slot);

    _ = netconf.netconf_lock(slot, 0);
    try std.testing.expectEqual(@as(u8, 0), netconf.netconf_unlock(slot, 0));
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_state(slot)); // Connected
}

test "unlock rejects wrong datastore" {
    const host = "router3";
    const slot = netconf.netconf_create(host.ptr, host.len, 830);
    defer netconf.netconf_destroy(slot);

    _ = netconf.netconf_lock(slot, 0); // Lock running
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_unlock(slot, 1)); // Try unlock startup
}

test "lock rejects invalid datastore" {
    const host = "router4";
    const slot = netconf.netconf_create(host.ptr, host.len, 830);
    defer netconf.netconf_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_lock(slot, 99));
}

// =========================================================================
// Edit-config / Commit / Discard
// =========================================================================

test "edit_config transitions to Editing" {
    const host = "switch1";
    const slot = netconf.netconf_create(host.ptr, host.len, 830);
    defer netconf.netconf_destroy(slot);

    const xpath = "/interfaces/interface";
    try std.testing.expectEqual(@as(u8, 0), netconf.netconf_edit_config(
        slot, 2, 0, xpath.ptr, xpath.len,
    )); // candidate, merge
    try std.testing.expectEqual(@as(u8, 3), netconf.netconf_state(slot)); // Editing
}

test "commit transitions Editing -> Connected" {
    const host = "switch2";
    const slot = netconf.netconf_create(host.ptr, host.len, 830);
    defer netconf.netconf_destroy(slot);

    const xpath = "/system/hostname";
    _ = netconf.netconf_edit_config(slot, 2, 1, xpath.ptr, xpath.len);
    try std.testing.expectEqual(@as(u8, 0), netconf.netconf_commit(slot));
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_state(slot)); // Connected
}

test "discard transitions Editing -> Connected" {
    const host = "switch3";
    const slot = netconf.netconf_create(host.ptr, host.len, 830);
    defer netconf.netconf_destroy(slot);

    const xpath = "/system/ntp";
    _ = netconf.netconf_edit_config(slot, 2, 0, xpath.ptr, xpath.len);
    try std.testing.expectEqual(@as(u8, 0), netconf.netconf_discard(slot));
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_state(slot)); // Connected
}

test "commit with lock returns to Locked" {
    const host = "switch4";
    const slot = netconf.netconf_create(host.ptr, host.len, 830);
    defer netconf.netconf_destroy(slot);

    _ = netconf.netconf_lock(slot, 2); // Lock candidate
    const xpath = "/system/dns";
    _ = netconf.netconf_edit_config(slot, 2, 0, xpath.ptr, xpath.len);
    _ = netconf.netconf_commit(slot);
    try std.testing.expectEqual(@as(u8, 2), netconf.netconf_state(slot)); // Locked
}

test "edit_config rejects invalid edit operation" {
    const host = "switch5";
    const slot = netconf.netconf_create(host.ptr, host.len, 830);
    defer netconf.netconf_destroy(slot);

    const xpath = "/x";
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_edit_config(
        slot, 0, 99, xpath.ptr, xpath.len,
    ));
}

// =========================================================================
// Get-config / Validate
// =========================================================================

test "get_config succeeds from Connected" {
    const host = "fw1";
    const slot = netconf.netconf_create(host.ptr, host.len, 830);
    defer netconf.netconf_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), netconf.netconf_get_config(slot, 0));
}

test "validate succeeds from Connected" {
    const host = "fw2";
    const slot = netconf.netconf_create(host.ptr, host.len, 830);
    defer netconf.netconf_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), netconf.netconf_validate(slot, 2));
}

// =========================================================================
// Close / Kill / Cleanup
// =========================================================================

test "close_session transitions to Closing" {
    const host = "core1";
    const slot = netconf.netconf_create(host.ptr, host.len, 830);
    defer netconf.netconf_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), netconf.netconf_close_session(slot));
    try std.testing.expectEqual(@as(u8, 4), netconf.netconf_state(slot)); // Closing
}

test "cleanup transitions Closing -> Idle" {
    const host = "core2";
    const slot = netconf.netconf_create(host.ptr, host.len, 830);
    defer netconf.netconf_destroy(slot);

    _ = netconf.netconf_close_session(slot);
    try std.testing.expectEqual(@as(u8, 0), netconf.netconf_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), netconf.netconf_state(slot)); // Idle
}

test "cleanup rejected from Connected state" {
    const host = "core3";
    const slot = netconf.netconf_create(host.ptr, host.len, 830);
    defer netconf.netconf_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_cleanup(slot));
}

test "kill_session succeeds from Connected" {
    const host = "core4";
    const slot = netconf.netconf_create(host.ptr, host.len, 830);
    defer netconf.netconf_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), netconf.netconf_kill_session(slot, 42));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "netconf_can_transition matches state machine" {
    // Valid
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_can_transition(0, 1)); // Idle -> Connected
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_can_transition(1, 2)); // Connected -> Locked
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_can_transition(2, 1)); // Locked -> Connected
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_can_transition(1, 3)); // Connected -> Editing
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_can_transition(3, 1)); // Editing -> Connected
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_can_transition(1, 4)); // Connected -> Closing
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_can_transition(4, 0)); // Closing -> Idle
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_can_transition(5, 0)); // Terminated -> Idle

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), netconf.netconf_can_transition(0, 3)); // Idle -/-> Editing
    try std.testing.expectEqual(@as(u8, 0), netconf.netconf_can_transition(4, 1)); // Closing -/-> Connected
    try std.testing.expectEqual(@as(u8, 0), netconf.netconf_can_transition(0, 2)); // Idle -/-> Locked
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), netconf.netconf_state(-1));
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_lock(-1, 0));
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_close_session(-1));
    try std.testing.expectEqual(@as(u8, 1), netconf.netconf_cleanup(-1));
}
