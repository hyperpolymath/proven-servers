// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// build.zig: Build recipe for the proven-nesy FFI shared library.
// Produces libnesy_ffi.so / .dylib / .dll for consumption by the
// V-lang triple adapter and any other language binding.

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // --- Shared library (for FFI consumers) ---
    const lib = b.addSharedLibrary(.{
        .name = "nesy_ffi",
        .root_source_file = b.path("nesy_ffi.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    // --- Static library (for embedding) ---
    const static_lib = b.addStaticLibrary(.{
        .name = "nesy_ffi",
        .root_source_file = b.path("nesy_ffi.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(static_lib);

    // --- C header generation ---
    const install_header = b.addInstallHeaderFile(
        b.path("nesy_ffi.h"),
        "nesy_ffi.h",
    );
    b.getInstallStep().dependOn(&install_header.step);

    // --- Tests ---
    const unit_tests = b.addTest(.{
        .root_source_file = b.path("nesy_ffi.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run FFI unit tests");
    test_step.dependOn(&run_tests.step);
}
