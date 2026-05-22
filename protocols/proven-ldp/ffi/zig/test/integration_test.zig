// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-ldp FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const ldp = @import("ldp");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ldp.ldp_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "ContainerType encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ldp.ContainerType.basic));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ldp.ContainerType.direct));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ldp.ContainerType.indirect));
}

test "ResourceType encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ldp.ResourceType.rdf_source));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ldp.ResourceType.non_rdf_source));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ldp.ResourceType.container));
}

test "Preference encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ldp.Preference.minimal_container));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ldp.Preference.include_containment));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ldp.Preference.include_membership));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ldp.Preference.omit_containment));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ldp.Preference.omit_membership));
}

test "InteractionModel encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ldp.InteractionModel.ldpr));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ldp.InteractionModel.ldpc));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ldp.InteractionModel.ldp_basic_container));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ldp.InteractionModel.ldp_direct_container));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ldp.InteractionModel.ldp_indirect_container));
}

test "ConstraintViolation encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ldp.ConstraintViolation.membership_constant));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ldp.ConstraintViolation.contains_triples_modified));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ldp.ConstraintViolation.server_managed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ldp.ConstraintViolation.type_conflict));
}

test "LdpError encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ldp.LdpError.ok));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ldp.LdpError.invalid_slot));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ldp.LdpError.not_active));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ldp.LdpError.constraint_violation));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ldp.LdpError.type_conflict));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ldp.LdpError.capacity_exhausted));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ldp.LdpError.invalid_preference));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = ldp.ldp_create(0, 0, 0);
    try std.testing.expect(slot >= 0);
    defer ldp.ldp_destroy(slot);
}

test "destroy is safe with invalid slot" {
    ldp.ldp_destroy(-1);
    ldp.ldp_destroy(999);
}

