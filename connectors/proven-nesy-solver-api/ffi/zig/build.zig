// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Build configuration for proven-nesy-solver-api FFI.
//
// Produces libproven_nesy_solver_api.so (shared) + .a (static) from the
// same source.  E3 adds a real echidna HTTP forwarder; E2 ships a
// skeleton with typed stubs.
//
// Build targets:
//   zig build         -- shared + static libraries
//   zig build test    -- FFI integration tests
//
// Requires Zig 0.14+.

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_module = b.createModule(.{
        .root_source_file = b.path("src/nesy_solver_api.zig"),
        .target = target,
        .optimize = optimize,
    });

    const shared_lib = b.addLibrary(.{
        .name = "proven_nesy_solver_api",
        .root_module = lib_module,
        .linkage = .dynamic,
    });
    b.installArtifact(shared_lib);

    const static_lib = b.addLibrary(.{
        .name = "proven_nesy_solver_api",
        .root_module = lib_module,
        .linkage = .static,
    });
    b.installArtifact(static_lib);

    // -- Tests --
    const test_module = b.createModule(.{
        .root_source_file = b.path("test/integration_test.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_module.addImport("nesy_solver_api", lib_module);

    const test_exe = b.addTest(.{
        .root_module = test_module,
    });

    const run_test = b.addRunArtifact(test_exe);
    const test_step = b.step("test", "Run FFI integration tests");
    test_step.dependOn(&run_test.step);
}
