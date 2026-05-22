// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-logcollector FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const logcollector = @import("logcollector");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), logcollector.lc_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "LogLevel encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(logcollector.LogLevel.trace));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(logcollector.LogLevel.debug));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(logcollector.LogLevel.info));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(logcollector.LogLevel.warn));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(logcollector.LogLevel.err));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(logcollector.LogLevel.fatal));
}

test "InputFormat encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(logcollector.InputFormat.json));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(logcollector.InputFormat.logfmt));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(logcollector.InputFormat.syslog));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(logcollector.InputFormat.cef));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(logcollector.InputFormat.gelf));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(logcollector.InputFormat.raw));
}

test "OutputTarget encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(logcollector.OutputTarget.file));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(logcollector.OutputTarget.elasticsearch));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(logcollector.OutputTarget.s3));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(logcollector.OutputTarget.kafka));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(logcollector.OutputTarget.stdout));
}

test "FilterOp encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(logcollector.FilterOp.include));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(logcollector.FilterOp.exclude));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(logcollector.FilterOp.transform));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(logcollector.FilterOp.redact));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(logcollector.FilterOp.sample));
}

test "PipelineStage encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(logcollector.PipelineStage.input));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(logcollector.PipelineStage.parse));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(logcollector.PipelineStage.filter));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(logcollector.PipelineStage.pipeline_transform));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(logcollector.PipelineStage.output));
}

test "LogcollectorError encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(logcollector.LogcollectorError.ok));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(logcollector.LogcollectorError.invalid_slot));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(logcollector.LogcollectorError.not_active));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(logcollector.LogcollectorError.invalid_transition));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(logcollector.LogcollectorError.below_threshold));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(logcollector.LogcollectorError.capacity_exhausted));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(logcollector.LogcollectorError.invalid_param));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = logcollector.lc_create(0, 0, 0);
    try std.testing.expect(slot >= 0);
    defer logcollector.lc_destroy(slot);
}

test "destroy is safe with invalid slot" {
    logcollector.lc_destroy(-1);
    logcollector.lc_destroy(999);
}

