// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ftp_test.zig -- Integration tests for proven-ftp FFI.
//
// Tests cover:
//   - ABI version
//   - Enum encoding seams (all 6 enum types)
//   - Session lifecycle (create/destroy)
//   - Authentication flow (USER/PASS)
//   - State machine transitions (valid and invalid)
//   - Directory navigation (CWD/CDUP)
//   - Transfer parameter setting (TYPE/PASV/PORT)
//   - Data transfer lifecycle (begin/bytes/complete/abort)
//   - Rename sequence (RNFR/RNTO)
//   - Stateless transition table
//   - Invalid slot safety
//   - Quit from every state

const std = @import("std");
const ftp = @import("ftp");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ftp.ftp_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "SessionState encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ftp.SessionState.connected));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ftp.SessionState.user_ok));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ftp.SessionState.authenticated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ftp.SessionState.renaming));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ftp.SessionState.quit));
}

test "TransferType encoding matches Layout.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ftp.TransferType.ascii));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ftp.TransferType.binary));
}

test "DataModeTag encoding matches Layout.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ftp.DataModeTag.active));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ftp.DataModeTag.passive));
}

test "TransferStateTag encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ftp.TransferStateTag.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ftp.TransferStateTag.in_progress));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ftp.TransferStateTag.completed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ftp.TransferStateTag.aborted));
}

test "CommandTag encoding matches Layout.idr (23 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ftp.CommandTag.user));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ftp.CommandTag.quit));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(ftp.CommandTag.retr));
    try std.testing.expectEqual(@as(u8, 15), @intFromEnum(ftp.CommandTag.list));
    try std.testing.expectEqual(@as(u8, 20), @intFromEnum(ftp.CommandTag.rnfr));
    try std.testing.expectEqual(@as(u8, 22), @intFromEnum(ftp.CommandTag.size));
}

test "ReplyCategory encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ftp.ReplyCategory.preliminary));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ftp.ReplyCategory.completion));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ftp.ReplyCategory.intermediate));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ftp.ReplyCategory.transient_neg));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ftp.ReplyCategory.permanent_neg));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create returns valid slot in Connected state" {
    const slot = ftp.ftp_create();
    try std.testing.expect(slot >= 0);
    defer ftp.ftp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_state(slot)); // connected
}

test "create sets initial values" {
    const slot = ftp.ftp_create();
    try std.testing.expect(slot >= 0);
    defer ftp.ftp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_transfer_type(slot)); // ascii
    try std.testing.expectEqual(@as(u8, 255), ftp.ftp_data_mode(slot)); // not set
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_transfer_state(slot)); // idle
    try std.testing.expectEqual(@as(u64, 0), ftp.ftp_bytes_transferred(slot));
    try std.testing.expectEqual(@as(u32, 0), ftp.ftp_file_count(slot));
    try std.testing.expectEqual(@as(u16, 220), ftp.ftp_last_reply_code(slot)); // ServiceReady
}

test "create sets CWD to root" {
    const slot = ftp.ftp_create();
    try std.testing.expect(slot >= 0);
    defer ftp.ftp_destroy(slot);
    var buf: [4096]u8 = undefined;
    const len = ftp.ftp_cwd(slot, &buf, 4096);
    try std.testing.expectEqual(@as(u32, 1), len);
    try std.testing.expectEqual(@as(u8, '/'), buf[0]);
}

test "destroy is safe with invalid slot" {
    ftp.ftp_destroy(-1);
    ftp.ftp_destroy(999);
}

// =========================================================================
// Authentication flow
// =========================================================================

test "USER transitions Connected -> UserOk" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    const name = "alice";
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_user(slot, name, 5));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_state(slot)); // user_ok
    try std.testing.expectEqual(@as(u16, 331), ftp.ftp_last_reply_code(slot));
}

test "PASS transitions UserOk -> Authenticated" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    const pw = "secret";
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_pass(slot, pw, 6));
    try std.testing.expectEqual(@as(u8, 2), ftp.ftp_state(slot)); // authenticated
    try std.testing.expectEqual(@as(u16, 230), ftp.ftp_last_reply_code(slot));
}

test "PASS rejected from Connected" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_pass(slot, "pw", 2));
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_state(slot)); // still connected
}

test "re-USER from UserOk stays in UserOk" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_user(slot, "bob", 3));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_state(slot)); // still user_ok
}

test "re-USER from Authenticated goes to UserOk" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_user(slot, "bob", 3));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_state(slot)); // user_ok
}

// =========================================================================
// QUIT from every state
// =========================================================================

test "QUIT from Connected" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_quit(slot));
    try std.testing.expectEqual(@as(u8, 4), ftp.ftp_state(slot)); // quit
    try std.testing.expectEqual(@as(u16, 221), ftp.ftp_last_reply_code(slot));
}

test "QUIT from UserOk" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_quit(slot));
    try std.testing.expectEqual(@as(u8, 4), ftp.ftp_state(slot));
}

test "QUIT from Authenticated" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_quit(slot));
    try std.testing.expectEqual(@as(u8, 4), ftp.ftp_state(slot));
}

test "QUIT from Renaming" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);
    _ = ftp.ftp_begin_rename(slot);
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_quit(slot));
    try std.testing.expectEqual(@as(u8, 4), ftp.ftp_state(slot));
}

test "QUIT rejected from Quit (terminal)" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_quit(slot);
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_quit(slot)); // rejected
}

// =========================================================================
// Directory navigation
// =========================================================================

test "CWD changes directory when authenticated" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);
    const path = "/pub/files";
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_cwd_cmd(slot, path, 10));
    try std.testing.expectEqual(@as(u16, 250), ftp.ftp_last_reply_code(slot));
    var buf: [4096]u8 = undefined;
    const len = ftp.ftp_cwd(slot, &buf, 4096);
    try std.testing.expectEqual(@as(u32, 10), len);
    try std.testing.expectEqualSlices(u8, "/pub/files", buf[0..10]);
}

test "CWD rejected before authentication" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_cwd_cmd(slot, "/pub", 4));
    try std.testing.expectEqual(@as(u16, 530), ftp.ftp_last_reply_code(slot));
}

test "CWD rejects traversal attack" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);
    const evil = "../../etc/passwd";
    try std.testing.expectEqual(@as(u8, 2), ftp.ftp_cwd_cmd(slot, evil, 16)); // bad path
    try std.testing.expectEqual(@as(u16, 550), ftp.ftp_last_reply_code(slot));
}

test "CDUP goes to parent directory" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);
    _ = ftp.ftp_cwd_cmd(slot, "/pub/files", 10);
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_cdup(slot));
    var buf: [4096]u8 = undefined;
    const len = ftp.ftp_cwd(slot, &buf, 4096);
    try std.testing.expectEqual(@as(u32, 4), len);
    try std.testing.expectEqualSlices(u8, "/pub", buf[0..4]);
}

test "CDUP from root stays at root" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_cdup(slot));
    var buf: [4096]u8 = undefined;
    const len = ftp.ftp_cwd(slot, &buf, 4096);
    try std.testing.expectEqual(@as(u32, 1), len);
    try std.testing.expectEqual(@as(u8, '/'), buf[0]);
}

// =========================================================================
// Transfer parameters
// =========================================================================

test "TYPE sets transfer type to binary" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_set_type(slot, 1)); // binary
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_transfer_type(slot));
    try std.testing.expectEqual(@as(u16, 200), ftp.ftp_last_reply_code(slot));
}

test "TYPE rejects invalid type tag" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_set_type(slot, 99));
    try std.testing.expectEqual(@as(u16, 504), ftp.ftp_last_reply_code(slot));
}

test "PASV sets passive mode" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_set_passive(slot));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_data_mode(slot)); // passive
    try std.testing.expectEqual(@as(u16, 227), ftp.ftp_last_reply_code(slot));
}

test "PORT sets active mode" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_set_active(slot, 12345));
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_data_mode(slot)); // active
    try std.testing.expectEqual(@as(u16, 200), ftp.ftp_last_reply_code(slot));
}

// =========================================================================
// Data transfer lifecycle
// =========================================================================

test "full transfer: begin -> add_bytes -> complete" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);
    _ = ftp.ftp_set_passive(slot);

    // Begin transfer
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_begin_transfer(slot));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_transfer_state(slot)); // in_progress
    try std.testing.expectEqual(@as(u16, 150), ftp.ftp_last_reply_code(slot));

    // Add bytes
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_add_bytes(slot, 1024));
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_add_bytes(slot, 2048));
    try std.testing.expectEqual(@as(u64, 3072), ftp.ftp_bytes_transferred(slot));

    // Complete
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_complete_transfer(slot));
    try std.testing.expectEqual(@as(u8, 2), ftp.ftp_transfer_state(slot)); // completed
    try std.testing.expectEqual(@as(u32, 1), ftp.ftp_file_count(slot));
    try std.testing.expectEqual(@as(u16, 226), ftp.ftp_last_reply_code(slot));
}

test "transfer abort" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);
    _ = ftp.ftp_set_passive(slot);
    _ = ftp.ftp_begin_transfer(slot);
    _ = ftp.ftp_add_bytes(slot, 512);

    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_abort_transfer(slot));
    try std.testing.expectEqual(@as(u8, 3), ftp.ftp_transfer_state(slot)); // aborted
    try std.testing.expectEqual(@as(u16, 426), ftp.ftp_last_reply_code(slot));
    try std.testing.expectEqual(@as(u32, 0), ftp.ftp_file_count(slot)); // not counted
}

test "begin_transfer rejected without data mode" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);
    // No PASV/PORT set
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_begin_transfer(slot));
    try std.testing.expectEqual(@as(u16, 425), ftp.ftp_last_reply_code(slot));
}

test "begin_transfer rejected before authentication" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_begin_transfer(slot));
    try std.testing.expectEqual(@as(u16, 530), ftp.ftp_last_reply_code(slot));
}

test "cannot begin second transfer while in progress" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);
    _ = ftp.ftp_set_passive(slot);
    _ = ftp.ftp_begin_transfer(slot);
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_begin_transfer(slot));
}

// =========================================================================
// Rename sequence
// =========================================================================

test "RNFR then RNTO completes rename" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);

    // RNFR -> Renaming
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_begin_rename(slot));
    try std.testing.expectEqual(@as(u8, 3), ftp.ftp_state(slot)); // renaming
    try std.testing.expectEqual(@as(u16, 350), ftp.ftp_last_reply_code(slot));

    // RNTO -> Authenticated
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_complete_rename(slot));
    try std.testing.expectEqual(@as(u8, 2), ftp.ftp_state(slot)); // authenticated
    try std.testing.expectEqual(@as(u16, 250), ftp.ftp_last_reply_code(slot));
}

test "RNFR rejected before authentication" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_begin_rename(slot));
}

test "RNTO rejected without RNFR" {
    const slot = ftp.ftp_create();
    defer ftp.ftp_destroy(slot);
    _ = ftp.ftp_user(slot, "alice", 5);
    _ = ftp.ftp_pass(slot, "pw", 2);
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_complete_rename(slot));
    try std.testing.expectEqual(@as(u16, 503), ftp.ftp_last_reply_code(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "ftp_can_transition matches Transitions.idr" {
    // Valid forward transitions
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_can_transition(0, 1)); // Connected -> UserOk
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_can_transition(1, 2)); // UserOk -> Authenticated
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_can_transition(1, 1)); // UserOk -> UserOk (ReUser)
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_can_transition(2, 2)); // Authenticated -> Authenticated
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_can_transition(2, 3)); // Authenticated -> Renaming
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_can_transition(3, 2)); // Renaming -> Authenticated
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_can_transition(3, 3)); // Renaming -> Renaming
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_can_transition(2, 1)); // Authenticated -> UserOk

    // Quit edges
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_can_transition(0, 4)); // Connected -> Quit
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_can_transition(1, 4)); // UserOk -> Quit
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_can_transition(2, 4)); // Authenticated -> Quit
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_can_transition(3, 4)); // Renaming -> Quit

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_can_transition(4, 0)); // Quit -> Connected (terminal!)
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_can_transition(4, 2)); // Quit -> Authenticated
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_can_transition(0, 2)); // Connected -> Authenticated (skip!)
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_can_transition(0, 3)); // Connected -> Renaming
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_can_transition(3, 1)); // Renaming -> UserOk
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_can_transition(3, 0)); // Renaming -> Connected
}

test "ftp_can_transfer only true for Authenticated" {
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_can_transfer(0)); // Connected
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_can_transfer(1)); // UserOk
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_can_transfer(2)); // Authenticated
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_can_transfer(3)); // Renaming
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_can_transfer(4)); // Quit
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 4), ftp.ftp_state(-1)); // quit fallback
    try std.testing.expectEqual(@as(u8, 255), ftp.ftp_transfer_type(-1));
    try std.testing.expectEqual(@as(u8, 255), ftp.ftp_data_mode(-1));
    try std.testing.expectEqual(@as(u8, 255), ftp.ftp_transfer_state(-1));
    try std.testing.expectEqual(@as(u64, 0), ftp.ftp_bytes_transferred(-1));
    try std.testing.expectEqual(@as(u32, 0), ftp.ftp_file_count(-1));
    try std.testing.expectEqual(@as(u16, 0), ftp.ftp_last_reply_code(-1));
}

test "CWD query safe on invalid slot" {
    var buf: [64]u8 = undefined;
    try std.testing.expectEqual(@as(u32, 0), ftp.ftp_cwd(-1, &buf, 64));
}

// =========================================================================
// Commands rejected on invalid slots
// =========================================================================

test "commands rejected on invalid slot" {
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_user(-1, "a", 1));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_pass(-1, "a", 1));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_quit(-1));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_cwd_cmd(-1, "/", 1));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_cdup(-1));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_set_type(-1, 0));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_set_passive(-1));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_set_active(-1, 0));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_begin_transfer(-1));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_add_bytes(-1, 0));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_complete_transfer(-1));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_abort_transfer(-1));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_begin_rename(-1));
    try std.testing.expectEqual(@as(u8, 1), ftp.ftp_complete_rename(-1));
}
