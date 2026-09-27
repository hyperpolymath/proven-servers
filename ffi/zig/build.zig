// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Build configuration for the root-level C-ABI prototype.
// This example API is not a protocol server or a repository-wide binding.

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const shared_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const shared_lib = b.addLibrary(.{
        .name = "proven_servers",
        .root_module = shared_module,
        .linkage = .dynamic,
    });
    b.installArtifact(shared_lib);

    const static_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const static_lib = b.addLibrary(.{
        .name = "proven_servers",
        .root_module = static_module,
        .linkage = .static,
    });
    b.installArtifact(static_lib);

    const api_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const test_module = b.createModule(.{
        .root_source_file = b.path("test/integration_test.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "proven_servers", .module = api_module }},
    });
    const tests = b.addTest(.{ .root_module = test_module });
    const run_tests = b.addRunArtifact(tests);
    b.step("test", "Run root C-ABI prototype tests").dependOn(&run_tests.step);
}
