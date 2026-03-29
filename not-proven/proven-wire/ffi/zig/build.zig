// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Build configuration for proven-wire FFI.
// Requires Zig 0.15+ (uses createModule / addLibrary API).

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_module = b.createModule(.{
        .root_source_file = b.path("src/wire.zig"),
        .target = target, .optimize = optimize,
    });
    const shared_lib = b.addLibrary(.{
        .name = "proven_wire", .root_module = lib_module, .linkage = .dynamic,
    });
    b.installArtifact(shared_lib);

    const static_mod = b.createModule(.{
        .root_source_file = b.path("src/wire.zig"),
        .target = target, .optimize = optimize,
    });
    const static_lib = b.addLibrary(.{
        .name = "proven_wire", .root_module = static_mod, .linkage = .static,
    });
    b.installArtifact(static_lib);

    const wire_module = b.createModule(.{
        .root_source_file = b.path("src/wire.zig"),
        .target = target, .optimize = optimize,
    });
    const test_module = b.createModule(.{
        .root_source_file = b.path("test/wire_test.zig"),
        .target = target, .optimize = optimize,
        .imports = &.{ .{ .name = "wire", .module = wire_module } },
    });
    const tests = b.addTest(.{ .root_module = test_module });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run FFI unit tests");
    test_step.dependOn(&run_tests.step);
}
