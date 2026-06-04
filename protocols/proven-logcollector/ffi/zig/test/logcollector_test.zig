// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// logcollector_test.zig — Integration tests for the proven-logcollector FFI.
//
// Tests cover:
//   - ABI version check
//   - Pipeline lifecycle (create, destroy, queries)
//   - Log ingestion with level filtering
//   - Pipeline stage advancement
//   - Filter operation tracking
//   - Minimum level configuration
//   - Edge cases (invalid slots, invalid params, etc.)

const std = @import("std");
const lc = @import("lc");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ── ABI Version ─────────────────────────────────────────────────────────

test "abi version returns 1" {
    try expectEqual(@as(u32, 1), lc.lc_abi_version());
}

// ── Create and Destroy ──────────────────────────────────────────────────

test "create returns valid slot" {
    const slot = lc.lc_create(0, 0, 0); // JSON, File, Trace
    try expect(slot >= 0);
    lc.lc_destroy(slot);
}

test "create with invalid input format returns -1" {
    try expectEqual(@as(c_int, -1), lc.lc_create(99, 0, 0));
}

test "create with invalid output target returns -1" {
    try expectEqual(@as(c_int, -1), lc.lc_create(0, 99, 0));
}

test "create with invalid min level returns -1" {
    try expectEqual(@as(c_int, -1), lc.lc_create(0, 0, 99));
}

test "destroy invalid slot is safe" {
    lc.lc_destroy(-1);
    lc.lc_destroy(999);
}

test "double destroy is safe" {
    const slot = lc.lc_create(0, 0, 0);
    lc.lc_destroy(slot);
    lc.lc_destroy(slot);
}

// ── State Queries ───────────────────────────────────────────────────────

test "fresh pipeline has correct input format" {
    const slot = lc.lc_create(2, 0, 0); // Syslog
    defer lc.lc_destroy(slot);
    try expectEqual(@as(u8, 2), lc.lc_get_input_format(slot));
}

test "fresh pipeline has correct output target" {
    const slot = lc.lc_create(0, 3, 0); // Kafka
    defer lc.lc_destroy(slot);
    try expectEqual(@as(u8, 3), lc.lc_get_output_target(slot));
}

test "fresh pipeline has correct min level" {
    const slot = lc.lc_create(0, 0, 3); // Warn
    defer lc.lc_destroy(slot);
    try expectEqual(@as(u8, 3), lc.lc_get_min_level(slot));
}

test "fresh pipeline starts at Input stage" {
    const slot = lc.lc_create(0, 0, 0);
    defer lc.lc_destroy(slot);
    try expectEqual(@as(u8, 0), lc.lc_get_current_stage(slot)); // Input
}

test "fresh pipeline has zero entries processed" {
    const slot = lc.lc_create(0, 0, 0);
    defer lc.lc_destroy(slot);
    try expectEqual(@as(u32, 0), lc.lc_get_entries_processed(slot));
}

test "fresh pipeline has zero entries dropped" {
    const slot = lc.lc_create(0, 0, 0);
    defer lc.lc_destroy(slot);
    try expectEqual(@as(u32, 0), lc.lc_get_entries_dropped(slot));
}

test "fresh pipeline has no error (255)" {
    const slot = lc.lc_create(0, 0, 0);
    defer lc.lc_destroy(slot);
    try expectEqual(@as(u8, 255), lc.lc_get_last_error(slot));
}

// ── Queries on Invalid Slot ─────────────────────────────────────────────

test "get_input_format on invalid slot returns 0" {
    try expectEqual(@as(u8, 0), lc.lc_get_input_format(-1));
}

test "get_last_error on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), lc.lc_get_last_error(-1));
}

// ── Log Ingestion ───────────────────────────────────────────────────────

test "ingest at or above min level succeeds" {
    const slot = lc.lc_create(0, 0, 2); // min_level = Info (2)
    defer lc.lc_destroy(slot);
    try expectEqual(@as(u8, 0), lc.lc_ingest(slot, 2)); // Info: Ok
    try expectEqual(@as(u8, 0), lc.lc_ingest(slot, 4)); // Error: Ok
    try expectEqual(@as(u32, 2), lc.lc_get_entries_processed(slot));
}

test "ingest below min level is dropped" {
    const slot = lc.lc_create(0, 0, 3); // min_level = Warn (3)
    defer lc.lc_destroy(slot);
    try expectEqual(@as(u8, 4), lc.lc_ingest(slot, 0)); // Trace: BelowThreshold
    try expectEqual(@as(u8, 4), lc.lc_ingest(slot, 1)); // Debug: BelowThreshold
    try expectEqual(@as(u8, 4), lc.lc_ingest(slot, 2)); // Info: BelowThreshold
    try expectEqual(@as(u32, 0), lc.lc_get_entries_processed(slot));
    try expectEqual(@as(u32, 3), lc.lc_get_entries_dropped(slot));
}

test "ingest with invalid level fails" {
    const slot = lc.lc_create(0, 0, 0);
    defer lc.lc_destroy(slot);
    try expectEqual(@as(u8, 6), lc.lc_ingest(slot, 99)); // InvalidParam
}

test "ingest on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), lc.lc_ingest(-1, 2));
}

// ── Filter Operations ───────────────────────────────────────────────────

test "apply filter succeeds" {
    const slot = lc.lc_create(0, 0, 0);
    defer lc.lc_destroy(slot);
    try expectEqual(@as(u8, 0), lc.lc_apply_filter(slot, 0)); // Include
    try expectEqual(@as(u8, 0), lc.lc_apply_filter(slot, 3)); // Redact
}

test "apply filter with invalid op fails" {
    const slot = lc.lc_create(0, 0, 0);
    defer lc.lc_destroy(slot);
    try expectEqual(@as(u8, 6), lc.lc_apply_filter(slot, 99)); // InvalidParam
}

// ── Pipeline Stage Advancement ──────────────────────────────────────────

test "advance through all stages" {
    const slot = lc.lc_create(0, 0, 0);
    defer lc.lc_destroy(slot);
    try expectEqual(@as(u8, 0), lc.lc_get_current_stage(slot)); // Input
    try expectEqual(@as(u8, 0), lc.lc_advance_stage(slot)); // -> Parse
    try expectEqual(@as(u8, 1), lc.lc_get_current_stage(slot));
    try expectEqual(@as(u8, 0), lc.lc_advance_stage(slot)); // -> Filter
    try expectEqual(@as(u8, 2), lc.lc_get_current_stage(slot));
    try expectEqual(@as(u8, 0), lc.lc_advance_stage(slot)); // -> Transform
    try expectEqual(@as(u8, 3), lc.lc_get_current_stage(slot));
    try expectEqual(@as(u8, 0), lc.lc_advance_stage(slot)); // -> Output
    try expectEqual(@as(u8, 4), lc.lc_get_current_stage(slot));
}

test "advance past Output fails" {
    const slot = lc.lc_create(0, 0, 0);
    defer lc.lc_destroy(slot);
    _ = lc.lc_advance_stage(slot); // -> Parse
    _ = lc.lc_advance_stage(slot); // -> Filter
    _ = lc.lc_advance_stage(slot); // -> Transform
    _ = lc.lc_advance_stage(slot); // -> Output
    try expectEqual(@as(u8, 3), lc.lc_advance_stage(slot)); // InvalidTransition
}

test "advance on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), lc.lc_advance_stage(-1));
}

// ── Configuration ───────────────────────────────────────────────────────

test "set min level" {
    const slot = lc.lc_create(0, 0, 0); // Trace
    defer lc.lc_destroy(slot);
    try expectEqual(@as(u8, 0), lc.lc_set_min_level(slot, 3)); // Warn
    try expectEqual(@as(u8, 3), lc.lc_get_min_level(slot));
}

test "set min level with invalid value fails" {
    const slot = lc.lc_create(0, 0, 0);
    defer lc.lc_destroy(slot);
    try expectEqual(@as(u8, 6), lc.lc_set_min_level(slot, 99)); // InvalidParam
}

// ── Full Lifecycle ──────────────────────────────────────────────────────

test "full pipeline lifecycle: create, ingest, filter, advance, destroy" {
    const slot = lc.lc_create(2, 1, 2); // Syslog, Elasticsearch, Info
    defer lc.lc_destroy(slot);

    // Ingest entries
    try expectEqual(@as(u8, 4), lc.lc_ingest(slot, 0)); // Trace: dropped
    try expectEqual(@as(u8, 4), lc.lc_ingest(slot, 1)); // Debug: dropped
    try expectEqual(@as(u8, 0), lc.lc_ingest(slot, 2)); // Info: processed
    try expectEqual(@as(u8, 0), lc.lc_ingest(slot, 4)); // Error: processed
    try expectEqual(@as(u8, 0), lc.lc_ingest(slot, 5)); // Fatal: processed

    try expectEqual(@as(u32, 3), lc.lc_get_entries_processed(slot));
    try expectEqual(@as(u32, 2), lc.lc_get_entries_dropped(slot));

    // Apply filters
    try expectEqual(@as(u8, 0), lc.lc_apply_filter(slot, 3)); // Redact
    try expectEqual(@as(u8, 0), lc.lc_apply_filter(slot, 0)); // Include

    // Advance through pipeline
    _ = lc.lc_advance_stage(slot); // -> Parse
    _ = lc.lc_advance_stage(slot); // -> Filter
    _ = lc.lc_advance_stage(slot); // -> Transform
    _ = lc.lc_advance_stage(slot); // -> Output
    try expectEqual(@as(u8, 4), lc.lc_get_current_stage(slot)); // Output
}
