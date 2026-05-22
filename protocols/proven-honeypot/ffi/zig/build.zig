// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{}); const optimize = b.standardOptimizeOption(.{});
    const lib_mod = b.createModule(.{ .root_source_file = b.path("src/honeypot.zig"), .target = target, .optimize = optimize });
    b.installArtifact(b.addLibrary(.{ .name = "proven_honeypot", .root_module = lib_mod, .linkage = .dynamic }));
    const static_mod = b.createModule(.{ .root_source_file = b.path("src/honeypot.zig"), .target = target, .optimize = optimize });
    b.installArtifact(b.addLibrary(.{ .name = "proven_honeypot", .root_module = static_mod, .linkage = .static }));
    const src_mod = b.createModule(.{ .root_source_file = b.path("src/honeypot.zig"), .target = target, .optimize = optimize });
    const test_mod = b.createModule(.{ .root_source_file = b.path("test/integration_test.zig"), .target = target, .optimize = optimize, .imports = &.{.{ .name = "honeypot", .module = src_mod }} });
    const test_step = b.step("test", "Run FFI unit tests");
    test_step.dependOn(&b.addRunArtifact(b.addTest(.{ .root_module = test_mod })).step);
}
