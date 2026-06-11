// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Build configuration for proven-voip FFI.
// Requires Zig 0.15+ (uses createModule / addLibrary API).

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // -- Shared library -------------------------------------------------------
    const lib_module = b.createModule(.{
        .root_source_file = b.path("src/voip.zig"),
        .target = target,
        .optimize = optimize,
    });
    const shared_lib = b.addLibrary(.{
        .name = "proven_voip",
        .root_module = lib_module,
        .linkage = .dynamic,
    });
    b.installArtifact(shared_lib);

    // -- Static library -------------------------------------------------------
    const static_mod = b.createModule(.{
        .root_source_file = b.path("src/voip.zig"),
        .target = target,
        .optimize = optimize,
    });
    const static_lib = b.addLibrary(.{
        .name = "proven_voip",
        .root_module = static_mod,
        .linkage = .static,
    });
    b.installArtifact(static_lib);

    // -- Tests ----------------------------------------------------------------
    const voip_module = b.createModule(.{
        .root_source_file = b.path("src/voip.zig"),
        .target = target,
        .optimize = optimize,
    });
    const test_module = b.createModule(.{
        .root_source_file = b.path("test/integration_test.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "voip", .module = voip_module }},
    });
    const tests = b.addTest(.{ .root_module = test_module });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run FFI unit tests");
    test_step.dependOn(&run_tests.step);
}
