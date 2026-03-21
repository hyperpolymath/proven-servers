// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Build configuration for proven-kms FFI.
//
// Produces both a C-ABI-compatible shared library (libproven_kms.so /
// libproven_kms.dylib / proven_kms.dll) and a static library
// (libproven_kms.a) from the same source.
//
// Build targets:
//   zig build         -- build shared + static libraries
//   zig build test    -- run FFI integration tests
//
// Requires Zig 0.15+ (uses the createModule / addLibrary API).

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // -- Library source module (shared between static and shared builds) --
    const lib_module = b.createModule(.{
        .root_source_file = b.path("src/kms.zig"),
        .target = target,
        .optimize = optimize,
    });

    // -- Shared library (.so / .dylib / .dll) --
    const shared_lib = b.addLibrary(.{
        .name = "proven_kms",
        .root_module = lib_module,
        .linkage = .dynamic,
    });
    b.installArtifact(shared_lib);

    // -- Static library (.a) --
    const static_mod = b.createModule(.{
        .root_source_file = b.path("src/kms.zig"),
        .target = target,
        .optimize = optimize,
    });
    const static_lib = b.addLibrary(.{
        .name = "proven_kms",
        .root_module = static_mod,
        .linkage = .static,
    });
    b.installArtifact(static_lib);

    // -- Importable module for tests --
    const kms_module = b.createModule(.{
        .root_source_file = b.path("src/kms.zig"),
        .target = target,
        .optimize = optimize,
    });

    // -- Unit / integration tests --
    const test_module = b.createModule(.{
        .root_source_file = b.path("test/kms_test.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "kms", .module = kms_module },
        },
    });
    const tests = b.addTest(.{
        .root_module = test_module,
    });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run FFI unit tests");
    test_step.dependOn(&run_tests.step);
}
