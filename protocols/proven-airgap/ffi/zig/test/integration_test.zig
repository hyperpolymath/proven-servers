// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-airgap FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Transfer lifecycle (create/destroy)
//   - Scanning pipeline (start_scan/submit_scan_result)
//   - Transfer execution (begin/complete/fail)
//   - Validation checks (add/count)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const airgap = @import("airgap");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), airgap.airgap_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "TransferDirection encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(airgap.TransferDirection.import_));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(airgap.TransferDirection.export_));
}

test "MediaType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(airgap.MediaType.usb));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(airgap.MediaType.optical_disc));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(airgap.MediaType.tape_cartridge));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(airgap.MediaType.diode_link));
}

test "ScanResult encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(airgap.ScanResult.clean));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(airgap.ScanResult.suspicious));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(airgap.ScanResult.malicious));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(airgap.ScanResult.unscannable));
}

test "TransferState encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(airgap.TransferState.pending));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(airgap.TransferState.scanning));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(airgap.TransferState.approved));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(airgap.TransferState.rejected));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(airgap.TransferState.in_progress));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(airgap.TransferState.complete));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(airgap.TransferState.failed));
}

test "ValidationCheck encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(airgap.ValidationCheck.hash_verify));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(airgap.ValidationCheck.signature_verify));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(airgap.ValidationCheck.format_check));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(airgap.ValidationCheck.content_inspection));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(airgap.ValidationCheck.malware_scan));
}

// =========================================================================
// Transfer lifecycle
// =========================================================================

test "create returns valid slot in Pending state" {
    const slot = airgap.airgap_create(0, 0); // Import, USB
    try std.testing.expect(slot >= 0);
    defer airgap.airgap_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_state(slot)); // Pending
}

test "create sets direction and media" {
    const slot = airgap.airgap_create(1, 2); // Export, TapeCartridge
    try std.testing.expect(slot >= 0);
    defer airgap.airgap_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), airgap.airgap_direction(slot)); // Export
    try std.testing.expectEqual(@as(u8, 2), airgap.airgap_media(slot)); // TapeCartridge
}

test "create rejects invalid direction" {
    const slot = airgap.airgap_create(5, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects invalid media" {
    const slot = airgap.airgap_create(0, 10);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    airgap.airgap_destroy(-1);
    airgap.airgap_destroy(999);
}

// =========================================================================
// Scanning pipeline
// =========================================================================

test "start_scan transitions Pending -> Scanning" {
    const slot = airgap.airgap_create(0, 0);
    defer airgap.airgap_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_start_scan(slot));
    try std.testing.expectEqual(@as(u8, 1), airgap.airgap_state(slot)); // Scanning
}

test "submit_scan_result clean transitions Scanning -> Approved" {
    const slot = airgap.airgap_create(0, 0);
    defer airgap.airgap_destroy(slot);

    _ = airgap.airgap_start_scan(slot);
    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_submit_scan_result(slot, 0)); // Clean
    try std.testing.expectEqual(@as(u8, 2), airgap.airgap_state(slot)); // Approved
}

test "submit_scan_result malicious transitions Scanning -> Rejected" {
    const slot = airgap.airgap_create(0, 0);
    defer airgap.airgap_destroy(slot);

    _ = airgap.airgap_start_scan(slot);
    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_submit_scan_result(slot, 2)); // Malicious
    try std.testing.expectEqual(@as(u8, 3), airgap.airgap_state(slot)); // Rejected
}

test "submit_scan_result suspicious transitions Scanning -> Rejected" {
    const slot = airgap.airgap_create(0, 0);
    defer airgap.airgap_destroy(slot);

    _ = airgap.airgap_start_scan(slot);
    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_submit_scan_result(slot, 1)); // Suspicious
    try std.testing.expectEqual(@as(u8, 3), airgap.airgap_state(slot)); // Rejected
}

test "submit_scan_result rejects invalid result tag" {
    const slot = airgap.airgap_create(0, 0);
    defer airgap.airgap_destroy(slot);

    _ = airgap.airgap_start_scan(slot);
    try std.testing.expectEqual(@as(u8, 1), airgap.airgap_submit_scan_result(slot, 99));
}

// =========================================================================
// Transfer execution
// =========================================================================

test "begin_transfer transitions Approved -> InProgress" {
    const slot = airgap.airgap_create(0, 0);
    defer airgap.airgap_destroy(slot);

    _ = airgap.airgap_start_scan(slot);
    _ = airgap.airgap_submit_scan_result(slot, 0); // Clean -> Approved
    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_begin_transfer(slot));
    try std.testing.expectEqual(@as(u8, 4), airgap.airgap_state(slot)); // InProgress
}

test "complete_transfer transitions InProgress -> Complete" {
    const slot = airgap.airgap_create(0, 0);
    defer airgap.airgap_destroy(slot);

    _ = airgap.airgap_start_scan(slot);
    _ = airgap.airgap_submit_scan_result(slot, 0);
    _ = airgap.airgap_begin_transfer(slot);
    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_complete_transfer(slot));
    try std.testing.expectEqual(@as(u8, 5), airgap.airgap_state(slot)); // Complete
}

test "fail_transfer transitions InProgress -> Failed" {
    const slot = airgap.airgap_create(0, 0);
    defer airgap.airgap_destroy(slot);

    _ = airgap.airgap_start_scan(slot);
    _ = airgap.airgap_submit_scan_result(slot, 0);
    _ = airgap.airgap_begin_transfer(slot);
    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_fail_transfer(slot));
    try std.testing.expectEqual(@as(u8, 6), airgap.airgap_state(slot)); // Failed
}

// =========================================================================
// Validation checks
// =========================================================================

test "add_validation increments count" {
    const slot = airgap.airgap_create(0, 0);
    defer airgap.airgap_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_add_validation(slot, 0)); // HashVerify
    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_add_validation(slot, 4)); // MalwareScan
    try std.testing.expectEqual(@as(u32, 2), airgap.airgap_validation_count(slot));
}

test "add_validation rejects invalid check tag" {
    const slot = airgap.airgap_create(0, 0);
    defer airgap.airgap_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), airgap.airgap_add_validation(slot, 99));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "airgap_can_transition matches Types.idr" {
    // Valid forward transitions
    try std.testing.expectEqual(@as(u8, 1), airgap.airgap_can_transition(0, 1)); // Pending -> Scanning
    try std.testing.expectEqual(@as(u8, 1), airgap.airgap_can_transition(1, 2)); // Scanning -> Approved
    try std.testing.expectEqual(@as(u8, 1), airgap.airgap_can_transition(1, 3)); // Scanning -> Rejected
    try std.testing.expectEqual(@as(u8, 1), airgap.airgap_can_transition(2, 4)); // Approved -> InProgress
    try std.testing.expectEqual(@as(u8, 1), airgap.airgap_can_transition(4, 5)); // InProgress -> Complete
    try std.testing.expectEqual(@as(u8, 1), airgap.airgap_can_transition(4, 6)); // InProgress -> Failed

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_can_transition(0, 2)); // Pending -/-> Approved
    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_can_transition(3, 4)); // Rejected -/-> InProgress
    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_can_transition(5, 0)); // Complete -/-> Pending
    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_can_transition(6, 0)); // Failed -/-> Pending
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_state(-1));
    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_direction(-1));
    try std.testing.expectEqual(@as(u8, 0), airgap.airgap_media(-1));
    try std.testing.expectEqual(@as(u32, 0), airgap.airgap_validation_count(-1));
    try std.testing.expectEqual(@as(u8, 1), airgap.airgap_start_scan(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot begin transfer from Pending" {
    const slot = airgap.airgap_create(0, 0);
    defer airgap.airgap_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), airgap.airgap_begin_transfer(slot));
}

test "cannot complete transfer from Scanning" {
    const slot = airgap.airgap_create(0, 0);
    defer airgap.airgap_destroy(slot);

    _ = airgap.airgap_start_scan(slot);
    try std.testing.expectEqual(@as(u8, 1), airgap.airgap_complete_transfer(slot));
}

test "cannot start scan twice" {
    const slot = airgap.airgap_create(0, 0);
    defer airgap.airgap_destroy(slot);

    _ = airgap.airgap_start_scan(slot);
    try std.testing.expectEqual(@as(u8, 1), airgap.airgap_start_scan(slot));
}
