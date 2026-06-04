// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Integration tests for proven-nesy-solver-api FFI.
// Tests the full session lifecycle through the C ABI.

const std = @import("std");
const api = @import("nesy_solver_api");

test "integration: full session lifecycle" {
    const s = api.nesy_session_open() orelse return error.OutOfMemory;
    defer api.nesy_session_close(s);

    try std.testing.expectEqual(
        @intFromEnum(api.SessionStateTag.idle),
        api.nesy_session_state(s),
    );

    const content = "(assert (= x 1)) (check-sat)";
    const d = api.nesy_dispatch_begin(
        s,
        @intFromEnum(api.ProverTag.z3),
        @intFromEnum(api.LanguageTag.smtlib),
        @intFromEnum(api.ClassTag.safety),
        content.ptr,
        content.len,
    ) orelse return error.OutOfMemory;
    defer api.nesy_dispatch_end(d);

    try std.testing.expectEqual(
        @intFromEnum(api.SessionStateTag.dispatching),
        api.nesy_session_state(s),
    );
}

test "integration: tag values match C header" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(api.ProverTag.z3));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(api.ProverTag.idris2));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(api.ProverTag.fstar));
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(api.ClassTag.safety));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(api.ClassTag.other));
    try std.testing.expectEqual(@as(u8, 15), @intFromEnum(api.SurfaceTag.verisimdb));
}
