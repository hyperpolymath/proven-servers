// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath)

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Shared library (for FFI from Idris2 / other languages)
    const lib = b.addSharedLibrary(.{
        .name = "typed_frame_router",
        .root_source_file = b.path("src/typed_frame_router.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    // Static library (for embedding)
    const static_lib = b.addStaticLibrary(.{
        .name = "typed_frame_router",
        .root_source_file = b.path("src/typed_frame_router.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(static_lib);

    // Standalone executable
    const exe = b.addExecutable(.{
        .name = "typed-frame-router",
        .root_source_file = b.path("src/typed_frame_router.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    // Tests
    const tests = b.addTest(.{
        .root_source_file = b.path("test/typed_frame_router_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run typed-frame-router tests");
    test_step.dependOn(&run_tests.step);
}
