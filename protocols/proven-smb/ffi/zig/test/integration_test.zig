// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-smb FFI.
//
// Tests cover (32 tests):
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Authentication
//   - Tree connection management (connect/disconnect/count)
//   - File handle management (open/close/count/read/write)
//   - Command validation against session state
//   - Dialect queries and encryption requirement
//   - Disconnect / Cleanup
//   - Transition table validation
//   - Invalid slot safety
//   - Impossibility tests

const std = @import("std");
const smb = @import("smb");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), smb.smb_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Command encoding matches Types.idr (16 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(smb.Command.negotiate));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(smb.Command.session_setup));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(smb.Command.logoff));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(smb.Command.tree_connect));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(smb.Command.tree_disconnect));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(smb.Command.create));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(smb.Command.close));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(smb.Command.read));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(smb.Command.write));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(smb.Command.lock));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(smb.Command.ioctl));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(smb.Command.cancel));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(smb.Command.query_directory));
    try std.testing.expectEqual(@as(u8, 13), @intFromEnum(smb.Command.change_notify));
    try std.testing.expectEqual(@as(u8, 14), @intFromEnum(smb.Command.query_info));
    try std.testing.expectEqual(@as(u8, 15), @intFromEnum(smb.Command.set_info));
}

test "Dialect encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(smb.Dialect.smb2_0_2));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(smb.Dialect.smb2_1));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(smb.Dialect.smb3_0));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(smb.Dialect.smb3_0_2));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(smb.Dialect.smb3_1_1));
}

test "ShareType encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(smb.ShareType.disk));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(smb.ShareType.pipe));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(smb.ShareType.print));
}

test "SessionState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(smb.SessionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(smb.SessionState.negotiated));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(smb.SessionState.authenticated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(smb.SessionState.tree_connected));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(smb.SessionState.file_open));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(smb.SessionState.disconnecting));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Negotiated state" {
    const slot = smb.smb_create(4); // SMB 3.1.1
    try std.testing.expect(slot >= 0);
    defer smb.smb_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), smb.smb_state(slot)); // Negotiated
}

test "create rejects invalid dialect" {
    try std.testing.expectEqual(@as(c_int, -1), smb.smb_create(99));
}

test "destroy is safe with invalid slot" {
    smb.smb_destroy(-1);
    smb.smb_destroy(999);
}

// =========================================================================
// Authentication
// =========================================================================

test "authenticate transitions Negotiated -> Authenticated" {
    const slot = smb.smb_create(4);
    defer smb.smb_destroy(slot);
    const user = "DOMAIN\\admin";
    try std.testing.expectEqual(@as(u8, 0), smb.smb_authenticate(slot, user.ptr, user.len));
    try std.testing.expectEqual(@as(u8, 2), smb.smb_state(slot)); // Authenticated
}

test "authenticate rejects empty username" {
    const slot = smb.smb_create(4);
    defer smb.smb_destroy(slot);
    const user = "x";
    try std.testing.expectEqual(@as(u8, 1), smb.smb_authenticate(slot, user.ptr, 0));
}

// =========================================================================
// Tree connection management
// =========================================================================

test "tree_connect transitions Authenticated -> TreeConnected" {
    const slot = smb.smb_create(4);
    defer smb.smb_destroy(slot);
    const user = "admin";
    _ = smb.smb_authenticate(slot, user.ptr, user.len);

    const share = "\\\\server\\share";
    try std.testing.expectEqual(@as(u8, 0), smb.smb_tree_connect(slot, share.ptr, share.len, 0)); // Disk
    try std.testing.expectEqual(@as(u8, 3), smb.smb_state(slot)); // TreeConnected
    try std.testing.expectEqual(@as(u16, 1), smb.smb_tree_count(slot));
}

test "tree_disconnect last tree transitions TreeConnected -> Authenticated" {
    const slot = smb.smb_create(4);
    defer smb.smb_destroy(slot);
    const user = "admin";
    _ = smb.smb_authenticate(slot, user.ptr, user.len);
    const share = "\\\\server\\share";
    _ = smb.smb_tree_connect(slot, share.ptr, share.len, 0);

    // Tree ID is 1 (first allocated)
    try std.testing.expectEqual(@as(u8, 0), smb.smb_tree_disconnect(slot, 1));
    try std.testing.expectEqual(@as(u8, 2), smb.smb_state(slot)); // Authenticated
    try std.testing.expectEqual(@as(u16, 0), smb.smb_tree_count(slot));
}

test "tree_connect rejects invalid share type" {
    const slot = smb.smb_create(4);
    defer smb.smb_destroy(slot);
    const user = "admin";
    _ = smb.smb_authenticate(slot, user.ptr, user.len);
    const share = "\\\\server\\share";
    try std.testing.expectEqual(@as(u8, 1), smb.smb_tree_connect(slot, share.ptr, share.len, 99));
}

// =========================================================================
// File handle management
// =========================================================================

test "file_open transitions TreeConnected -> FileOpen" {
    const slot = smb.smb_create(4);
    defer smb.smb_destroy(slot);
    const user = "admin";
    _ = smb.smb_authenticate(slot, user.ptr, user.len);
    const share = "\\\\server\\share";
    _ = smb.smb_tree_connect(slot, share.ptr, share.len, 0);

    const fname = "document.txt";
    try std.testing.expectEqual(@as(u8, 0), smb.smb_file_open(slot, 1, fname.ptr, fname.len));
    try std.testing.expectEqual(@as(u8, 4), smb.smb_state(slot)); // FileOpen
    try std.testing.expectEqual(@as(u16, 1), smb.smb_file_count(slot));
}

test "file_close last file transitions FileOpen -> TreeConnected" {
    const slot = smb.smb_create(4);
    defer smb.smb_destroy(slot);
    const user = "admin";
    _ = smb.smb_authenticate(slot, user.ptr, user.len);
    const share = "\\\\server\\share";
    _ = smb.smb_tree_connect(slot, share.ptr, share.len, 0);
    const fname = "document.txt";
    _ = smb.smb_file_open(slot, 1, fname.ptr, fname.len);

    // File ID is 1
    try std.testing.expectEqual(@as(u8, 0), smb.smb_file_close(slot, 1));
    try std.testing.expectEqual(@as(u8, 3), smb.smb_state(slot)); // TreeConnected
    try std.testing.expectEqual(@as(u16, 0), smb.smb_file_count(slot));
}

test "file_read succeeds from FileOpen" {
    const slot = smb.smb_create(4);
    defer smb.smb_destroy(slot);
    const user = "admin";
    _ = smb.smb_authenticate(slot, user.ptr, user.len);
    const share = "\\\\server\\share";
    _ = smb.smb_tree_connect(slot, share.ptr, share.len, 0);
    const fname = "data.bin";
    _ = smb.smb_file_open(slot, 1, fname.ptr, fname.len);

    try std.testing.expectEqual(@as(u8, 0), smb.smb_file_read(slot, 1, 0, 4096));
}

test "file_write succeeds from FileOpen" {
    const slot = smb.smb_create(4);
    defer smb.smb_destroy(slot);
    const user = "admin";
    _ = smb.smb_authenticate(slot, user.ptr, user.len);
    const share = "\\\\server\\share";
    _ = smb.smb_tree_connect(slot, share.ptr, share.len, 0);
    const fname = "data.bin";
    _ = smb.smb_file_open(slot, 1, fname.ptr, fname.len);

    try std.testing.expectEqual(@as(u8, 0), smb.smb_file_write(slot, 1, 0, 1024));
}

test "file_open rejects nonexistent tree" {
    const slot = smb.smb_create(4);
    defer smb.smb_destroy(slot);
    const user = "admin";
    _ = smb.smb_authenticate(slot, user.ptr, user.len);
    const share = "\\\\server\\share";
    _ = smb.smb_tree_connect(slot, share.ptr, share.len, 0);
    const fname = "file.txt";
    try std.testing.expectEqual(@as(u8, 1), smb.smb_file_open(slot, 999, fname.ptr, fname.len));
}

// =========================================================================
// Command validation
// =========================================================================

test "can_command validates commands against state" {
    const slot = smb.smb_create(4);
    defer smb.smb_destroy(slot);

    // Negotiated state: only session_setup allowed
    try std.testing.expectEqual(@as(u8, 1), smb.smb_can_command(slot, 1)); // session_setup
    try std.testing.expectEqual(@as(u8, 0), smb.smb_can_command(slot, 5)); // create

    const user = "admin";
    _ = smb.smb_authenticate(slot, user.ptr, user.len);
    // Authenticated: tree_connect allowed, create not yet
    try std.testing.expectEqual(@as(u8, 1), smb.smb_can_command(slot, 3)); // tree_connect
    try std.testing.expectEqual(@as(u8, 0), smb.smb_can_command(slot, 5)); // create

    const share = "\\\\server\\share";
    _ = smb.smb_tree_connect(slot, share.ptr, share.len, 0);
    // TreeConnected: create allowed
    try std.testing.expectEqual(@as(u8, 1), smb.smb_can_command(slot, 5)); // create
}

// =========================================================================
// Dialect and encryption
// =========================================================================

test "dialect returns negotiated dialect" {
    const slot = smb.smb_create(4); // SMB 3.1.1
    defer smb.smb_destroy(slot);
    try std.testing.expectEqual(@as(u8, 4), smb.smb_dialect(slot));
}

test "encryption_required true for SMB 3.0+" {
    const slot_30 = smb.smb_create(2); // SMB 3.0
    defer smb.smb_destroy(slot_30);
    try std.testing.expectEqual(@as(u8, 1), smb.smb_encryption_required(slot_30));

    const slot_21 = smb.smb_create(1); // SMB 2.1
    defer smb.smb_destroy(slot_21);
    try std.testing.expectEqual(@as(u8, 0), smb.smb_encryption_required(slot_21));
}

// =========================================================================
// Tree disconnect closes files
// =========================================================================

test "tree_disconnect closes all files on that tree" {
    const slot = smb.smb_create(4);
    defer smb.smb_destroy(slot);
    const user = "admin";
    _ = smb.smb_authenticate(slot, user.ptr, user.len);
    const share = "\\\\server\\docs";
    _ = smb.smb_tree_connect(slot, share.ptr, share.len, 0);
    const f1 = "a.txt";
    const f2 = "b.txt";
    _ = smb.smb_file_open(slot, 1, f1.ptr, f1.len);
    _ = smb.smb_file_open(slot, 1, f2.ptr, f2.len);
    try std.testing.expectEqual(@as(u16, 2), smb.smb_file_count(slot));

    _ = smb.smb_tree_disconnect(slot, 1);
    try std.testing.expectEqual(@as(u16, 0), smb.smb_file_count(slot));
    try std.testing.expectEqual(@as(u8, 2), smb.smb_state(slot)); // Authenticated
}

// =========================================================================
// Disconnect / Cleanup
// =========================================================================

test "disconnect transitions Negotiated -> Disconnecting" {
    const slot = smb.smb_create(4);
    defer smb.smb_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), smb.smb_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 5), smb.smb_state(slot));
}

test "cleanup transitions Disconnecting -> Idle and clears state" {
    const slot = smb.smb_create(4);
    defer smb.smb_destroy(slot);
    const user = "admin";
    _ = smb.smb_authenticate(slot, user.ptr, user.len);
    const share = "\\\\server\\share";
    _ = smb.smb_tree_connect(slot, share.ptr, share.len, 0);
    _ = smb.smb_disconnect(slot);
    try std.testing.expectEqual(@as(u8, 0), smb.smb_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), smb.smb_state(slot)); // Idle
    try std.testing.expectEqual(@as(u16, 0), smb.smb_tree_count(slot));
    try std.testing.expectEqual(@as(u16, 0), smb.smb_file_count(slot));
}

// =========================================================================
// Transition table
// =========================================================================

test "smb_can_transition matches expected transitions" {
    try std.testing.expectEqual(@as(u8, 1), smb.smb_can_transition(0, 1)); // Idle -> Negotiated
    try std.testing.expectEqual(@as(u8, 1), smb.smb_can_transition(1, 2)); // Negotiated -> Authenticated
    try std.testing.expectEqual(@as(u8, 1), smb.smb_can_transition(2, 3)); // Authenticated -> TreeConnected
    try std.testing.expectEqual(@as(u8, 1), smb.smb_can_transition(3, 4)); // TreeConnected -> FileOpen
    try std.testing.expectEqual(@as(u8, 1), smb.smb_can_transition(4, 3)); // FileOpen -> TreeConnected
    try std.testing.expectEqual(@as(u8, 1), smb.smb_can_transition(3, 2)); // TreeConnected -> Authenticated
    try std.testing.expectEqual(@as(u8, 1), smb.smb_can_transition(4, 5)); // FileOpen -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), smb.smb_can_transition(5, 0)); // Disconnecting -> Idle
    // Invalid
    try std.testing.expectEqual(@as(u8, 0), smb.smb_can_transition(0, 3)); // Idle -/-> TreeConnected
    try std.testing.expectEqual(@as(u8, 0), smb.smb_can_transition(5, 1)); // Disconnecting -/-> Negotiated
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot authenticate from TreeConnected" {
    const slot = smb.smb_create(4);
    defer smb.smb_destroy(slot);
    const user = "admin";
    _ = smb.smb_authenticate(slot, user.ptr, user.len);
    const share = "\\\\server\\share";
    _ = smb.smb_tree_connect(slot, share.ptr, share.len, 0);
    try std.testing.expectEqual(@as(u8, 1), smb.smb_authenticate(slot, user.ptr, user.len));
}

test "cannot open file from Authenticated (no tree)" {
    const slot = smb.smb_create(4);
    defer smb.smb_destroy(slot);
    const user = "admin";
    _ = smb.smb_authenticate(slot, user.ptr, user.len);
    const fname = "file.txt";
    try std.testing.expectEqual(@as(u8, 1), smb.smb_file_open(slot, 1, fname.ptr, fname.len));
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), smb.smb_state(-1));
    try std.testing.expectEqual(@as(u16, 0), smb.smb_tree_count(-1));
    try std.testing.expectEqual(@as(u16, 0), smb.smb_file_count(-1));
    try std.testing.expectEqual(@as(u8, 1), smb.smb_disconnect(-1));
    try std.testing.expectEqual(@as(u8, 1), smb.smb_cleanup(-1));
    try std.testing.expectEqual(@as(u8, 0), smb.smb_can_command(-1, 0));
}

// =========================================================================
// Active count
// =========================================================================

test "active_count tracks sessions" {
    const before = smb.smb_active_count();
    const slot = smb.smb_create(0);
    try std.testing.expectEqual(before + 1, smb.smb_active_count());
    smb.smb_destroy(slot);
    try std.testing.expectEqual(before, smb.smb_active_count());
}
