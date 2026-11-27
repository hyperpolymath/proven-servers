// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Build configuration for proven-amqp FFI.
// Requires Zig 0.15+ (uses createModule / addLibrary API).

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // -- Shared library -------------------------------------------------------
    // Shared uniform-connector dispatcher (repository-level ffi/zig/connector).
    const ps_connector = b.createModule(.{
        .root_source_file = b.path("../../../../ffi/zig/connector/ps_connector.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib_module = b.createModule(.{
        .root_source_file = b.path("src/amqp.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "ps_connector", .module = ps_connector }},
    });
    const shared_lib = b.addLibrary(.{
        .name = "proven_amqp",
        .root_module = lib_module,
        .linkage = .dynamic,
    });
    b.installArtifact(shared_lib);

    // -- Static library -------------------------------------------------------
    const static_mod = b.createModule(.{
        .root_source_file = b.path("src/amqp.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "ps_connector", .module = ps_connector }},
    });
    const static_lib = b.addLibrary(.{
        .name = "proven_amqp",
        .root_module = static_mod,
        .linkage = .static,
    });
    b.installArtifact(static_lib);

    // -- Tests ----------------------------------------------------------------
    const amqp_module = b.createModule(.{
        .root_source_file = b.path("src/amqp.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "ps_connector", .module = ps_connector }},
    });
    const test_module = b.createModule(.{
        .root_source_file = b.path("test/amqp_test.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{.{ .name = "amqp", .module = amqp_module }},
    });
    const tests = b.addTest(.{ .root_module = test_module });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run FFI unit tests");
    test_step.dependOn(&run_tests.step);
}
