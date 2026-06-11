// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// ldp_test.zig — Integration tests for the proven-ldp FFI.
//
// Tests cover:
//   - ABI version check
//   - Resource lifecycle (create, destroy, queries)
//   - Container child management
//   - Preference setting
//   - Constraint violation checking
//   - Edge cases (invalid slots, invalid params, etc.)

const std = @import("std");
const ldp = @import("ldp");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ── ABI Version ─────────────────────────────────────────────────────────

test "abi version returns 1" {
    try expectEqual(@as(u32, 1), ldp.ldp_abi_version());
}

// ── Create and Destroy ──────────────────────────────────────────────────

test "create returns valid slot" {
    const slot = ldp.ldp_create(0, 0, 0); // RDFSource, Basic, LDPR
    try expect(slot >= 0);
    ldp.ldp_destroy(slot);
}

test "create container resource" {
    const slot = ldp.ldp_create(2, 0, 1); // Container, Basic, LDPC
    try expect(slot >= 0);
    ldp.ldp_destroy(slot);
}

test "create with invalid resource type returns -1" {
    try expectEqual(@as(c_int, -1), ldp.ldp_create(99, 0, 0));
}

test "create with invalid container type returns -1" {
    try expectEqual(@as(c_int, -1), ldp.ldp_create(0, 99, 0));
}

test "create with invalid interaction model returns -1" {
    try expectEqual(@as(c_int, -1), ldp.ldp_create(0, 0, 99));
}

test "destroy invalid slot is safe" {
    ldp.ldp_destroy(-1);
    ldp.ldp_destroy(999);
}

test "double destroy is safe" {
    const slot = ldp.ldp_create(0, 0, 0);
    ldp.ldp_destroy(slot);
    ldp.ldp_destroy(slot);
}

// ── State Queries ───────────────────────────────────────────────────────

test "fresh resource has correct resource type" {
    const slot = ldp.ldp_create(1, 0, 0); // NonRDFSource
    defer ldp.ldp_destroy(slot);
    try expectEqual(@as(u8, 1), ldp.ldp_get_resource_type(slot));
}

test "fresh resource has correct container type" {
    const slot = ldp.ldp_create(2, 2, 1); // Container, Indirect, LDPC
    defer ldp.ldp_destroy(slot);
    try expectEqual(@as(u8, 2), ldp.ldp_get_container_type(slot));
}

test "fresh resource has correct interaction model" {
    const slot = ldp.ldp_create(2, 0, 2); // Container, Basic, LDPBasicContainer
    defer ldp.ldp_destroy(slot);
    try expectEqual(@as(u8, 2), ldp.ldp_get_interaction_model(slot));
}

test "fresh resource has minimal preference" {
    const slot = ldp.ldp_create(0, 0, 0);
    defer ldp.ldp_destroy(slot);
    try expectEqual(@as(u8, 0), ldp.ldp_get_preference(slot));
}

test "fresh resource has zero children" {
    const slot = ldp.ldp_create(2, 0, 1);
    defer ldp.ldp_destroy(slot);
    try expectEqual(@as(u32, 0), ldp.ldp_get_child_count(slot));
}

test "fresh resource has no error (255)" {
    const slot = ldp.ldp_create(0, 0, 0);
    defer ldp.ldp_destroy(slot);
    try expectEqual(@as(u8, 255), ldp.ldp_get_last_error(slot));
}

// ── Queries on Invalid Slot ─────────────────────────────────────────────

test "get_resource_type on invalid slot returns 0" {
    try expectEqual(@as(u8, 0), ldp.ldp_get_resource_type(-1));
}

test "get_last_error on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), ldp.ldp_get_last_error(-1));
}

// ── Preference Setting ──────────────────────────────────────────────────

test "set preference to include containment" {
    const slot = ldp.ldp_create(2, 0, 1);
    defer ldp.ldp_destroy(slot);
    try expectEqual(@as(u8, 0), ldp.ldp_set_preference(slot, 1)); // IncludeContainment
    try expectEqual(@as(u8, 1), ldp.ldp_get_preference(slot));
}

test "set preference with invalid value fails" {
    const slot = ldp.ldp_create(0, 0, 0);
    defer ldp.ldp_destroy(slot);
    try expectEqual(@as(u8, 6), ldp.ldp_set_preference(slot, 99)); // InvalidPreference
}

test "set preference on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), ldp.ldp_set_preference(-1, 0)); // InvalidSlot
}

// ── Container Child Management ──────────────────────────────────────────

test "add child to container increments count" {
    const slot = ldp.ldp_create(2, 0, 1); // Container
    defer ldp.ldp_destroy(slot);
    try expectEqual(@as(u8, 0), ldp.ldp_add_child(slot, 0)); // RDFSource child
    try expectEqual(@as(u32, 1), ldp.ldp_get_child_count(slot));
    try expectEqual(@as(u8, 0), ldp.ldp_add_child(slot, 1)); // NonRDFSource child
    try expectEqual(@as(u32, 2), ldp.ldp_get_child_count(slot));
}

test "add child to non-container fails with TypeConflict" {
    const slot = ldp.ldp_create(0, 0, 0); // RDFSource, not a container
    defer ldp.ldp_destroy(slot);
    try expectEqual(@as(u8, 4), ldp.ldp_add_child(slot, 0)); // TypeConflict
}

test "add child with invalid type fails" {
    const slot = ldp.ldp_create(2, 0, 1); // Container
    defer ldp.ldp_destroy(slot);
    try expectEqual(@as(u8, 4), ldp.ldp_add_child(slot, 99)); // TypeConflict
}

// ── Constraint Checking ─────────────────────────────────────────────────

test "modify membership on basic container is violation" {
    const slot = ldp.ldp_create(2, 0, 1); // Container, Basic
    defer ldp.ldp_destroy(slot);
    try expectEqual(@as(u8, 0), ldp.ldp_check_constraint(slot, 0)); // MembershipConstant
}

test "modify membership on direct container is allowed" {
    const slot = ldp.ldp_create(2, 1, 3); // Container, Direct
    defer ldp.ldp_destroy(slot);
    try expectEqual(@as(u8, 255), ldp.ldp_check_constraint(slot, 0)); // No violation
}

test "modify containment triples is always violation" {
    const slot = ldp.ldp_create(2, 1, 3); // Container, Direct
    defer ldp.ldp_destroy(slot);
    try expectEqual(@as(u8, 1), ldp.ldp_check_constraint(slot, 1)); // ContainsTriplesModified
}

test "modify server-managed props is violation" {
    const slot = ldp.ldp_create(0, 0, 0);
    defer ldp.ldp_destroy(slot);
    try expectEqual(@as(u8, 2), ldp.ldp_check_constraint(slot, 2)); // ServerManaged
}

test "normal operation has no violation" {
    const slot = ldp.ldp_create(0, 0, 0);
    defer ldp.ldp_destroy(slot);
    try expectEqual(@as(u8, 255), ldp.ldp_check_constraint(slot, 5)); // No violation
}

test "constraint check on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), ldp.ldp_check_constraint(-1, 0));
}

// ── Full Lifecycle ──────────────────────────────────────────────────────

test "full container lifecycle: create, configure, add children, destroy" {
    const slot = ldp.ldp_create(2, 1, 3); // Container, Direct, LDPDirectContainer
    defer ldp.ldp_destroy(slot);

    // Set preference
    try expectEqual(@as(u8, 0), ldp.ldp_set_preference(slot, 1)); // IncludeContainment

    // Add children
    try expectEqual(@as(u8, 0), ldp.ldp_add_child(slot, 0)); // RDFSource
    try expectEqual(@as(u8, 0), ldp.ldp_add_child(slot, 1)); // NonRDFSource
    try expectEqual(@as(u8, 0), ldp.ldp_add_child(slot, 2)); // Container
    try expectEqual(@as(u32, 3), ldp.ldp_get_child_count(slot));

    // Verify state
    try expectEqual(@as(u8, 2), ldp.ldp_get_resource_type(slot)); // Container
    try expectEqual(@as(u8, 1), ldp.ldp_get_container_type(slot)); // Direct
    try expectEqual(@as(u8, 3), ldp.ldp_get_interaction_model(slot)); // LDPDirectContainer
}
