// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// build.zig — Zig build configuration for proven-storageconn FFI.

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_module = b.createModule(.{
        .root_source_file = b.path("src/storageconn.zig"),
        .target = target,
        .optimize = optimize,
    });

    const shared_lib = b.addLibrary(.{
        .name = "proven_storageconn",
        .root_module = lib_module,
        .linkage = .dynamic,
    });
    b.installArtifact(shared_lib);

    const static_mod = b.createModule(.{
        .root_source_file = b.path("src/storageconn.zig"),
        .target = target,
        .optimize = optimize,
    });

    const static_lib = b.addLibrary(.{
        .name = "proven_storageconn",
        .root_module = static_mod,
        .linkage = .static,
    });
    b.installArtifact(static_lib);

    const test_module = b.createModule(.{
        .root_source_file = b.path("test/storageconn_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_module.addImport("storageconn", lib_module);

    const test_exe = b.addTest(.{ .root_module = test_module });
    const run_tests = b.addRunArtifact(test_exe);
    const test_step = b.step("test", "Run proven-storageconn integration tests");
    test_step.dependOn(&run_tests.step);
}
