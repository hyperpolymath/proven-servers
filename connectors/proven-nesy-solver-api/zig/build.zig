// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Build configuration for proven-nesy-solver-api Zig HTTP server.
//
// Replaces the V vweb server in v/server.v + v/rgtv_client.v with a
// single statically-linked Zig binary.
//
// Targets:
//   zig build            — build nesy_server binary
//   zig build run        — build and run (reads env vars for config)
//   zig build test       — run unit tests
//
// Requires Zig 0.15.2+.

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target   = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // -------------------------------------------------------------------------
    // Main server binary
    // -------------------------------------------------------------------------
    const rgtv_mod = b.createModule(.{
        .root_source_file = b.path("src/rgtv.zig"),
        .target           = target,
        .optimize         = optimize,
    });

    const main_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target           = target,
        .optimize         = optimize,
    });
    main_mod.addImport("rgtv", rgtv_mod);

    const exe = b.addExecutable(.{
        .name        = "nesy_server",
        .root_module = main_mod,
    });
    b.installArtifact(exe);

    // zig build run
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);
    const run_step = b.step("run", "Run the nesy-solver-api server");
    run_step.dependOn(&run_cmd.step);

    // -------------------------------------------------------------------------
    // Tests
    // -------------------------------------------------------------------------
    const test_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target           = target,
        .optimize         = optimize,
    });
    test_mod.addImport("rgtv", rgtv_mod);

    const unit_tests = b.addTest(.{ .root_module = test_mod });
    const run_tests  = b.addRunArtifact(unit_tests);
    const test_step  = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);
}
