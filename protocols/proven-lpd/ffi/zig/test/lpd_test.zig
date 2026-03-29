// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// lpd_test.zig — Integration tests for the proven-lpd FFI.
//
// Tests cover:
//   - ABI version check
//   - Queue lifecycle (create, destroy, queries)
//   - Job enqueue and dequeue
//   - Job status transitions (pending, printing, complete, failed)
//   - Queue pause and resume
//   - Queue depth and job size limits
//   - Command code parsing (RFC 1179)
//   - Edge cases (invalid slots, full queue, etc.)

const std = @import("std");
const lpd = @import("lpd");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ── ABI Version ─────────────────────────────────────────────────────────

test "abi version returns 1" {
    try expectEqual(@as(u32, 1), lpd.lpd_abi_version());
}

// ── Create and Destroy ──────────────────────────────────────────────────

test "create returns valid slot" {
    const slot = lpd.lpd_create(100, 1048576);
    try expect(slot >= 0);
    lpd.lpd_destroy(slot);
}

test "create with zero max_depth returns -1" {
    try expectEqual(@as(c_int, -1), lpd.lpd_create(0, 1048576));
}

test "create with zero max_job_size returns -1" {
    try expectEqual(@as(c_int, -1), lpd.lpd_create(100, 0));
}

test "destroy invalid slot is safe" {
    lpd.lpd_destroy(-1);
    lpd.lpd_destroy(999);
}

test "double destroy is safe" {
    const slot = lpd.lpd_create(100, 1048576);
    lpd.lpd_destroy(slot);
    lpd.lpd_destroy(slot);
}

// ── State Queries ───────────────────────────────────────────────────────

test "fresh queue has zero jobs" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    try expectEqual(@as(u32, 0), lpd.lpd_get_job_count(slot));
}

test "fresh queue has correct max depth" {
    const slot = lpd.lpd_create(50, 1048576);
    defer lpd.lpd_destroy(slot);
    try expectEqual(@as(u32, 50), lpd.lpd_get_max_depth(slot));
}

test "fresh queue is accepting" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    try expectEqual(@as(u8, 1), lpd.lpd_is_accepting(slot));
}

test "fresh queue has zero submitted and completed" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    try expectEqual(@as(u32, 0), lpd.lpd_get_total_submitted(slot));
    try expectEqual(@as(u32, 0), lpd.lpd_get_total_completed(slot));
}

test "fresh queue has no error (255)" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    try expectEqual(@as(u8, 255), lpd.lpd_get_last_error(slot));
}

// ── Queries on Invalid Slot ─────────────────────────────────────────────

test "get_job_count on invalid slot returns 0" {
    try expectEqual(@as(u32, 0), lpd.lpd_get_job_count(-1));
}

test "get_last_error on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), lpd.lpd_get_last_error(-1));
}

// ── Job Enqueue ─────────────────────────────────────────────────────────

test "enqueue returns job id" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    const job_id = lpd.lpd_enqueue(slot, 1024);
    try expect(job_id >= 0);
    try expectEqual(@as(u32, 1), lpd.lpd_get_job_count(slot));
    try expectEqual(@as(u32, 1), lpd.lpd_get_total_submitted(slot));
}

test "enqueue multiple jobs" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    const j1 = lpd.lpd_enqueue(slot, 100);
    const j2 = lpd.lpd_enqueue(slot, 200);
    try expect(j1 >= 0);
    try expect(j2 >= 0);
    try expect(j1 != j2);
    try expectEqual(@as(u32, 2), lpd.lpd_get_job_count(slot));
}

test "enqueue on full queue fails" {
    const slot = lpd.lpd_create(2, 1048576); // max 2 jobs
    defer lpd.lpd_destroy(slot);
    _ = lpd.lpd_enqueue(slot, 100);
    _ = lpd.lpd_enqueue(slot, 100);
    try expectEqual(@as(c_int, -1), lpd.lpd_enqueue(slot, 100));
}

test "enqueue on paused queue fails" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    _ = lpd.lpd_pause_queue(slot);
    try expectEqual(@as(c_int, -1), lpd.lpd_enqueue(slot, 100));
}

test "enqueue oversized job fails" {
    const slot = lpd.lpd_create(100, 1000); // max 1000 bytes
    defer lpd.lpd_destroy(slot);
    try expectEqual(@as(c_int, -1), lpd.lpd_enqueue(slot, 2000));
}

// ── Job Dequeue ─────────────────────────────────────────────────────────

test "dequeue returns first pending job" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    const j1 = lpd.lpd_enqueue(slot, 100);
    const dequeued = lpd.lpd_dequeue(slot);
    try expectEqual(j1, dequeued);
}

test "dequeue marks job as printing" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    const j_id = lpd.lpd_enqueue(slot, 100);
    _ = lpd.lpd_dequeue(slot);
    try expectEqual(@as(u8, 1), lpd.lpd_get_job_status(slot, @intCast(j_id))); // Printing
}

test "dequeue on empty queue returns -1" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    try expectEqual(@as(c_int, -1), lpd.lpd_dequeue(slot));
}

// ── Job Status ──────────────────────────────────────────────────────────

test "fresh job is pending" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    const j_id = lpd.lpd_enqueue(slot, 100);
    try expectEqual(@as(u8, 0), lpd.lpd_get_job_status(slot, @intCast(j_id))); // Pending
}

test "complete job" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    const j_id = lpd.lpd_enqueue(slot, 100);
    try expectEqual(@as(u8, 0), lpd.lpd_complete_job(slot, @intCast(j_id))); // Ok
    try expectEqual(@as(u8, 2), lpd.lpd_get_job_status(slot, @intCast(j_id))); // Complete
    try expectEqual(@as(u32, 1), lpd.lpd_get_total_completed(slot));
}

test "fail job" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    const j_id = lpd.lpd_enqueue(slot, 100);
    try expectEqual(@as(u8, 0), lpd.lpd_fail_job(slot, @intCast(j_id))); // Ok
    try expectEqual(@as(u8, 3), lpd.lpd_get_job_status(slot, @intCast(j_id))); // Failed
}

test "complete nonexistent job returns JobNotFound" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    try expectEqual(@as(u8, 5), lpd.lpd_complete_job(slot, 999)); // JobNotFound
}

test "get status of nonexistent job returns 255" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    try expectEqual(@as(u8, 255), lpd.lpd_get_job_status(slot, 999));
}

// ── Queue Control ───────────────────────────────────────────────────────

test "pause queue stops accepting" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    try expectEqual(@as(u8, 0), lpd.lpd_pause_queue(slot)); // Ok
    try expectEqual(@as(u8, 0), lpd.lpd_is_accepting(slot));
}

test "resume queue starts accepting" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);
    _ = lpd.lpd_pause_queue(slot);
    try expectEqual(@as(u8, 0), lpd.lpd_resume_queue(slot)); // Ok
    try expectEqual(@as(u8, 1), lpd.lpd_is_accepting(slot));
}

test "pause on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), lpd.lpd_pause_queue(-1));
}

// ── Command Parsing ─────────────────────────────────────────────────────

test "parse valid command codes" {
    try expectEqual(@as(u8, 1), lpd.lpd_parse_command(1)); // PrintJob
    try expectEqual(@as(u8, 2), lpd.lpd_parse_command(2)); // ReceiveJob
    try expectEqual(@as(u8, 3), lpd.lpd_parse_command(3)); // ShortQueue
    try expectEqual(@as(u8, 4), lpd.lpd_parse_command(4)); // LongQueue
    try expectEqual(@as(u8, 5), lpd.lpd_parse_command(5)); // RemoveJobs
}

test "parse invalid command code returns 255" {
    try expectEqual(@as(u8, 255), lpd.lpd_parse_command(0));
    try expectEqual(@as(u8, 255), lpd.lpd_parse_command(6));
    try expectEqual(@as(u8, 255), lpd.lpd_parse_command(99));
}

// ── Full Lifecycle ──────────────────────────────────────────────────────

test "full lifecycle: enqueue, dequeue, print, complete" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);

    // Enqueue jobs
    const j1 = lpd.lpd_enqueue(slot, 1024);
    const j2 = lpd.lpd_enqueue(slot, 2048);
    try expect(j1 >= 0);
    try expect(j2 >= 0);
    try expectEqual(@as(u32, 2), lpd.lpd_get_job_count(slot));

    // Dequeue first job (starts printing)
    const dequeued = lpd.lpd_dequeue(slot);
    try expectEqual(j1, dequeued);
    try expectEqual(@as(u8, 1), lpd.lpd_get_job_status(slot, @intCast(j1))); // Printing

    // Complete first job
    try expectEqual(@as(u8, 0), lpd.lpd_complete_job(slot, @intCast(j1)));
    try expectEqual(@as(u32, 1), lpd.lpd_get_total_completed(slot));

    // Dequeue and fail second job
    const dequeued2 = lpd.lpd_dequeue(slot);
    try expectEqual(j2, dequeued2);
    try expectEqual(@as(u8, 0), lpd.lpd_fail_job(slot, @intCast(j2)));
    try expectEqual(@as(u8, 3), lpd.lpd_get_job_status(slot, @intCast(j2))); // Failed
}

test "pause-resume cycle with enqueue" {
    const slot = lpd.lpd_create(100, 1048576);
    defer lpd.lpd_destroy(slot);

    _ = lpd.lpd_enqueue(slot, 100);
    _ = lpd.lpd_pause_queue(slot);
    try expectEqual(@as(c_int, -1), lpd.lpd_enqueue(slot, 200)); // Rejected
    _ = lpd.lpd_resume_queue(slot);
    const j = lpd.lpd_enqueue(slot, 300);
    try expect(j >= 0); // Accepted again
    try expectEqual(@as(u32, 2), lpd.lpd_get_total_submitted(slot));
}
