// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-tftp FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Read transfer: DATA reception and completion
//   - Write transfer: ACK reception
//   - Error reception and propagation
//   - Retry counting and exhaustion
//   - Block number tracking
//   - Byte count tracking
//   - Transfer mode queries
//   - Stateless transition table
//   - Terminal state detection
//   - Invalid slot safety
//   - Session count tracking

const std = @import("std");
const tftp = @import("tftp");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), tftp.tftp_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Opcode encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tftp.Opcode.rrq));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(tftp.Opcode.wrq));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(tftp.Opcode.data));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(tftp.Opcode.ack));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(tftp.Opcode.err));
}

test "TransferMode encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tftp.TransferMode.netascii));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(tftp.TransferMode.octet));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(tftp.TransferMode.mail));
}

test "TFTPError encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tftp.TFTPError.not_defined));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(tftp.TFTPError.file_not_found));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(tftp.TFTPError.access_violation));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(tftp.TFTPError.disk_full));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(tftp.TFTPError.illegal_operation));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(tftp.TFTPError.unknown_tid));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(tftp.TFTPError.file_exists));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(tftp.TFTPError.no_such_user));
}

test "TransferState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(tftp.TransferState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(tftp.TransferState.reading));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(tftp.TransferState.writing));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(tftp.TransferState.in_error));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(tftp.TransferState.complete));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create read session starts in Reading state" {
    const filename = "config.txt";
    const slot = tftp.tftp_create(filename.ptr, filename.len, 1, 1); // octet, read
    try std.testing.expect(slot >= 0);
    defer tftp.tftp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), tftp.tftp_state(slot)); // Reading
    try std.testing.expectEqual(@as(u8, 1), tftp.tftp_mode(slot)); // octet
}

test "create write session starts in Writing state" {
    const filename = "upload.bin";
    const slot = tftp.tftp_create(filename.ptr, filename.len, 1, 0); // octet, write
    try std.testing.expect(slot >= 0);
    defer tftp.tftp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 2), tftp.tftp_state(slot)); // Writing
}

test "create rejects empty filename" {
    const filename = "x";
    try std.testing.expectEqual(@as(c_int, -1), tftp.tftp_create(filename.ptr, 0, 1, 1));
}

test "create rejects invalid mode" {
    const filename = "test.txt";
    try std.testing.expectEqual(@as(c_int, -1), tftp.tftp_create(filename.ptr, filename.len, 99, 1));
}

test "destroy is safe with invalid slot" {
    tftp.tftp_destroy(-1);
    tftp.tftp_destroy(999);
}

// =========================================================================
// Read transfer
// =========================================================================

test "recv_data updates block number and byte count" {
    const filename = "data.bin";
    const slot = tftp.tftp_create(filename.ptr, filename.len, 1, 1);
    defer tftp.tftp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), tftp.tftp_recv_data(slot, 1, 512, 0));
    try std.testing.expectEqual(@as(u16, 1), tftp.tftp_current_block(slot));
    try std.testing.expectEqual(@as(u32, 512), tftp.tftp_bytes_transferred(slot));
}

test "recv_data last block transitions Reading -> Complete" {
    const filename = "small.txt";
    const slot = tftp.tftp_create(filename.ptr, filename.len, 0, 1); // netascii, read
    defer tftp.tftp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), tftp.tftp_recv_data(slot, 1, 100, 1)); // last block
    try std.testing.expectEqual(@as(u8, 4), tftp.tftp_state(slot)); // Complete
}

test "multi-block read transfer" {
    const filename = "large.bin";
    const slot = tftp.tftp_create(filename.ptr, filename.len, 1, 1);
    defer tftp.tftp_destroy(slot);

    _ = tftp.tftp_recv_data(slot, 1, 512, 0);
    _ = tftp.tftp_recv_data(slot, 2, 512, 0);
    _ = tftp.tftp_recv_data(slot, 3, 256, 1); // last
    try std.testing.expectEqual(@as(u8, 4), tftp.tftp_state(slot)); // Complete
    try std.testing.expectEqual(@as(u32, 1280), tftp.tftp_bytes_transferred(slot));
    try std.testing.expectEqual(@as(u16, 3), tftp.tftp_current_block(slot));
}

// =========================================================================
// Write transfer
// =========================================================================

test "recv_ack updates block number during write" {
    const filename = "upload.bin";
    const slot = tftp.tftp_create(filename.ptr, filename.len, 1, 0);
    defer tftp.tftp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), tftp.tftp_recv_ack(slot, 0)); // ACK for WRQ
    try std.testing.expectEqual(@as(u16, 0), tftp.tftp_current_block(slot));
}

// =========================================================================
// Error handling
// =========================================================================

test "recv_error transitions to InError" {
    const filename = "missing.txt";
    const slot = tftp.tftp_create(filename.ptr, filename.len, 1, 1);
    defer tftp.tftp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), tftp.tftp_recv_error(slot, 1)); // file not found
    try std.testing.expectEqual(@as(u8, 3), tftp.tftp_state(slot)); // InError
    try std.testing.expectEqual(@as(u8, 1), tftp.tftp_last_error(slot)); // file_not_found
}

test "recv_error rejects invalid error code" {
    const filename = "test.txt";
    const slot = tftp.tftp_create(filename.ptr, filename.len, 1, 1);
    defer tftp.tftp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), tftp.tftp_recv_error(slot, 99));
}

test "no error initially" {
    const filename = "test.txt";
    const slot = tftp.tftp_create(filename.ptr, filename.len, 1, 1);
    defer tftp.tftp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 255), tftp.tftp_last_error(slot)); // no error
}

// =========================================================================
// Retry management
// =========================================================================

test "retry increments counter" {
    const filename = "retry.txt";
    const slot = tftp.tftp_create(filename.ptr, filename.len, 1, 1);
    defer tftp.tftp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), tftp.tftp_retry(slot)); // ok
    try std.testing.expectEqual(@as(u8, 0), tftp.tftp_retry(slot)); // ok
}

test "retry exhaustion transitions to InError" {
    const filename = "timeout.txt";
    const slot = tftp.tftp_create(filename.ptr, filename.len, 1, 1);
    defer tftp.tftp_destroy(slot);

    // 5 retries should be ok, 6th should exhaust
    _ = tftp.tftp_retry(slot); // 1
    _ = tftp.tftp_retry(slot); // 2
    _ = tftp.tftp_retry(slot); // 3
    _ = tftp.tftp_retry(slot); // 4
    _ = tftp.tftp_retry(slot); // 5
    try std.testing.expectEqual(@as(u8, 1), tftp.tftp_retry(slot)); // exhausted
    try std.testing.expectEqual(@as(u8, 3), tftp.tftp_state(slot)); // InError
}

test "recv_data resets retry count" {
    const filename = "recover.txt";
    const slot = tftp.tftp_create(filename.ptr, filename.len, 1, 1);
    defer tftp.tftp_destroy(slot);

    _ = tftp.tftp_retry(slot);
    _ = tftp.tftp_retry(slot);
    _ = tftp.tftp_recv_data(slot, 1, 512, 0); // resets retries
    // Should be able to retry again without exhaustion
    try std.testing.expectEqual(@as(u8, 0), tftp.tftp_retry(slot));
}

// =========================================================================
// Stateless helpers
// =========================================================================

test "tftp_can_transition matches Types.idr" {
    try std.testing.expectEqual(@as(u8, 1), tftp.tftp_can_transition(0, 1)); // Idle -> Reading
    try std.testing.expectEqual(@as(u8, 1), tftp.tftp_can_transition(0, 2)); // Idle -> Writing
    try std.testing.expectEqual(@as(u8, 1), tftp.tftp_can_transition(1, 4)); // Reading -> Complete
    try std.testing.expectEqual(@as(u8, 1), tftp.tftp_can_transition(2, 4)); // Writing -> Complete
    try std.testing.expectEqual(@as(u8, 1), tftp.tftp_can_transition(1, 3)); // Reading -> InError
    try std.testing.expectEqual(@as(u8, 1), tftp.tftp_can_transition(2, 3)); // Writing -> InError

    try std.testing.expectEqual(@as(u8, 0), tftp.tftp_can_transition(0, 4)); // Idle -/-> Complete
    try std.testing.expectEqual(@as(u8, 0), tftp.tftp_can_transition(3, 1)); // InError -/-> Reading
    try std.testing.expectEqual(@as(u8, 0), tftp.tftp_can_transition(4, 0)); // Complete -/-> Idle
}

test "tftp_is_terminal detects terminal states" {
    try std.testing.expectEqual(@as(u8, 0), tftp.tftp_is_terminal(0)); // Idle
    try std.testing.expectEqual(@as(u8, 0), tftp.tftp_is_terminal(1)); // Reading
    try std.testing.expectEqual(@as(u8, 0), tftp.tftp_is_terminal(2)); // Writing
    try std.testing.expectEqual(@as(u8, 1), tftp.tftp_is_terminal(3)); // InError
    try std.testing.expectEqual(@as(u8, 1), tftp.tftp_is_terminal(4)); // Complete
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), tftp.tftp_state(-1));
    try std.testing.expectEqual(@as(u16, 0), tftp.tftp_current_block(-1));
    try std.testing.expectEqual(@as(u32, 0), tftp.tftp_bytes_transferred(-1));
    try std.testing.expectEqual(@as(u8, 255), tftp.tftp_last_error(-1));
}

// =========================================================================
// Session count
// =========================================================================

test "session_count tracks active sessions" {
    const initial = tftp.tftp_session_count();
    const filename = "count.txt";
    const slot = tftp.tftp_create(filename.ptr, filename.len, 1, 1);
    try std.testing.expectEqual(initial + 1, tftp.tftp_session_count());
    tftp.tftp_destroy(slot);
    try std.testing.expectEqual(initial, tftp.tftp_session_count());
}
