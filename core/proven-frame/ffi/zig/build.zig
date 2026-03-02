// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Build configuration for proven-frame FFI.
//
// Produces both a C-ABI-compatible shared library (libproven_frame.so /
// libproven_frame.dylib / proven_frame.dll) and a static library
// (libproven_frame.a) from the same source.
//
// Build targets:
//   zig build         -- build shared + static libraries
//   zig build test    -- run FFI integration tests
//
// The libraries export C-ABI functions matching the header at
// generated/abi/frame.h and the Idris2 ABI specifications at
// src/FrameABI/.
//
// Requires Zig 0.14+ (uses the root_module / addLibrary API).

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // -- Library source module (shared between static and shared builds) --
    const lib_module = b.createModule(.{
        .root_source_file = b.path("src/frame.zig"),
        .target = target,
        .optimize = optimize,
    });

    // -- Shared library (.so / .dylib / .dll) --
    const shared_lib = b.addLibrary(.{
        .name = "proven_frame",
        .root_module = lib_module,
        .linkage = .dynamic,
    });
    b.installArtifact(shared_lib);

    // -- Static library (.a) --
    const static_mod = b.createModule(.{
        .root_source_file = b.path("src/frame.zig"),
        .target = target,
        .optimize = optimize,
    });
    const static_lib = b.addLibrary(.{
        .name = "proven_frame",
        .root_module = static_mod,
        .linkage = .static,
    });
    b.installArtifact(static_lib);

    // -- Importable frame module for tests --
    const frame_module = b.createModule(.{
        .root_source_file = b.path("src/frame.zig"),
        .target = target,
        .optimize = optimize,
    });

    // -- Unit / integration tests --
    const test_module = b.createModule(.{
        .root_source_file = b.path("test/frame_test.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "frame", .module = frame_module },
        },
    });
    const tests = b.addTest(.{
        .root_module = test_module,
    });
    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run FFI unit tests");
    test_step.dependOn(&run_tests.step);
}
