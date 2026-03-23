// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath)

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Shared library (for FFI from Idris2 / other languages)
    const lib = b.addSharedLibrary(.{
        .name = "groove_proxy",
        .root_source_file = b.path("src/groove_proxy.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    // Static library (for embedding)
    const static_lib = b.addStaticLibrary(.{
        .name = "groove_proxy",
        .root_source_file = b.path("src/groove_proxy.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(static_lib);

    // Standalone executable (for running the proxy independently)
    const exe = b.addExecutable(.{
        .name = "groove-proxy",
        .root_source_file = b.path("src/groove_proxy.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(exe);

    // Tests
    const tests = b.addTest(.{
        .root_source_file = b.path("test/groove_proxy_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run groove-proxy tests");
    test_step.dependOn(&run_tests.step);
}
