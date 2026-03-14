// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ldap_test.zig -- Integration tests for proven-ldap FFI.
//
// Tests cover:
//   - ABI version
//   - Enum encoding seams (all 4 enum types)
//   - Session lifecycle (create/destroy)
//   - Bind flow (simple bind with success/failure)
//   - State machine transitions (valid and invalid)
//   - Directory operations (search, modify, add, delete, compare)
//   - Abandon operation
//   - Unbind from every state
//   - Stateless transition table
//   - Invalid slot safety
//   - DN tracking
//   - Message ID counter

const std = @import("std");
const ldap = @import("ldap");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ldap.ldap_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "SessionState encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ldap.SessionState.anonymous));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ldap.SessionState.bound));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ldap.SessionState.closed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ldap.SessionState.binding));
}

test "Operation encoding matches Layout.idr (10 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ldap.Operation.bind));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ldap.Operation.unbind));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ldap.Operation.search));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ldap.Operation.delete));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(ldap.Operation.compare));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(ldap.Operation.extended));
}

test "SearchScope encoding matches Layout.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ldap.SearchScope.base_object));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ldap.SearchScope.single_level));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ldap.SearchScope.whole_subtree));
}

test "ResultCode encoding matches Layout.idr (11 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ldap.ResultCode.success));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ldap.ResultCode.protocol_error));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(ldap.ResultCode.invalid_credentials));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(ldap.ResultCode.insufficient_access_rights));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(ldap.ResultCode.unavailable));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create returns valid slot in Anonymous state" {
    const slot = ldap.ldap_create();
    try std.testing.expect(slot >= 0);
    defer ldap.ldap_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_state(slot)); // anonymous
}

test "create sets initial values" {
    const slot = ldap.ldap_create();
    try std.testing.expect(slot >= 0);
    defer ldap.ldap_destroy(slot);
    try std.testing.expectEqual(@as(u8, 255), ldap.ldap_last_result(slot)); // none
    try std.testing.expectEqual(@as(u32, 0), ldap.ldap_message_id(slot));
}

test "create sets empty DN" {
    const slot = ldap.ldap_create();
    try std.testing.expect(slot >= 0);
    defer ldap.ldap_destroy(slot);
    var buf: [2048]u8 = undefined;
    const len = ldap.ldap_bind_dn(slot, &buf, 2048);
    try std.testing.expectEqual(@as(u32, 0), len);
}

test "destroy is safe with invalid slot" {
    ldap.ldap_destroy(-1);
    ldap.ldap_destroy(999);
}

// =========================================================================
// Bind flow
// =========================================================================

test "bind transitions Anonymous -> Binding" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    const dn = "cn=admin,dc=example,dc=com";
    const pw = "secret";
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_bind(slot, dn, 26, pw, 6));
    try std.testing.expectEqual(@as(u8, 3), ldap.ldap_state(slot)); // binding
    try std.testing.expectEqual(@as(u32, 1), ldap.ldap_message_id(slot));
}

test "bind_complete success transitions Binding -> Bound" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    const dn = "cn=admin,dc=example,dc=com";
    _ = ldap.ldap_bind(slot, dn, 26, "pw", 2);
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_bind_complete(slot, 0)); // success
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_state(slot)); // bound
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_last_result(slot)); // success
}

test "bind_complete failure transitions Binding -> Anonymous" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_bind(slot, "cn=admin", 8, "bad", 3);
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_bind_complete(slot, 7)); // invalid_credentials
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_state(slot)); // anonymous
    try std.testing.expectEqual(@as(u8, 7), ldap.ldap_last_result(slot)); // invalid_credentials
}

test "bind_complete clears DN on failure" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_bind(slot, "cn=admin", 8, "bad", 3);
    _ = ldap.ldap_bind_complete(slot, 7); // failure
    var buf: [2048]u8 = undefined;
    const len = ldap.ldap_bind_dn(slot, &buf, 2048);
    try std.testing.expectEqual(@as(u32, 0), len);
}

test "DN is preserved after successful bind" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    const dn = "cn=admin,dc=example,dc=com";
    _ = ldap.ldap_bind(slot, dn, 26, "pw", 2);
    _ = ldap.ldap_bind_complete(slot, 0); // success
    var buf: [2048]u8 = undefined;
    const len = ldap.ldap_bind_dn(slot, &buf, 2048);
    try std.testing.expectEqual(@as(u32, 26), len);
    try std.testing.expectEqualSlices(u8, "cn=admin,dc=example,dc=com", buf[0..26]);
}

test "re-bind from Bound transitions to Binding" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_bind(slot, "cn=admin", 8, "pw", 2);
    _ = ldap.ldap_bind_complete(slot, 0);
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_state(slot)); // bound
    // Re-bind
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_bind(slot, "cn=user", 7, "pw2", 3));
    try std.testing.expectEqual(@as(u8, 3), ldap.ldap_state(slot)); // binding
}

test "bind rejected from Closed" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_unbind(slot);
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_bind(slot, "cn=admin", 8, "pw", 2));
}

test "bind rejected from Binding" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_bind(slot, "cn=admin", 8, "pw", 2);
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_bind(slot, "cn=other", 8, "pw", 2));
}

// =========================================================================
// Unbind from every state
// =========================================================================

test "unbind from Anonymous" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_unbind(slot));
    try std.testing.expectEqual(@as(u8, 2), ldap.ldap_state(slot)); // closed
}

test "unbind from Bound" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_bind(slot, "cn=admin", 8, "pw", 2);
    _ = ldap.ldap_bind_complete(slot, 0);
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_unbind(slot));
    try std.testing.expectEqual(@as(u8, 2), ldap.ldap_state(slot)); // closed
}

test "unbind from Binding" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_bind(slot, "cn=admin", 8, "pw", 2);
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_unbind(slot));
    try std.testing.expectEqual(@as(u8, 2), ldap.ldap_state(slot)); // closed
}

test "unbind rejected from Closed (terminal)" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_unbind(slot);
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_unbind(slot)); // rejected
}

// =========================================================================
// Directory operations
// =========================================================================

test "search from Anonymous succeeds" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    const base = "dc=example,dc=com";
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_search(slot, base, 17, 2)); // wholeSubtree
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_last_result(slot)); // success
    try std.testing.expectEqual(@as(u32, 1), ldap.ldap_message_id(slot));
}

test "search from Bound succeeds" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_bind(slot, "cn=admin", 8, "pw", 2);
    _ = ldap.ldap_bind_complete(slot, 0);
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_search(slot, "dc=example", 10, 0)); // baseObject
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_last_result(slot));
}

test "search rejects invalid scope" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    try std.testing.expectEqual(@as(u8, 2), ldap.ldap_search(slot, "dc=example", 10, 99)); // bad scope
}

test "search rejected from Closed" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_unbind(slot);
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_search(slot, "dc=example", 10, 0));
}

test "search rejected from Binding" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_bind(slot, "cn=admin", 8, "pw", 2);
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_search(slot, "dc=example", 10, 0));
}

test "modify requires Bound" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_bind(slot, "cn=admin", 8, "pw", 2);
    _ = ldap.ldap_bind_complete(slot, 0);
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_modify(slot));
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_last_result(slot));
}

test "modify rejected from Anonymous" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_modify(slot));
    try std.testing.expectEqual(@as(u8, 8), ldap.ldap_last_result(slot)); // insufficient_access_rights
}

test "add requires Bound" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_bind(slot, "cn=admin", 8, "pw", 2);
    _ = ldap.ldap_bind_complete(slot, 0);
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_add(slot));
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_last_result(slot));
}

test "add rejected from Anonymous" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_add(slot));
    try std.testing.expectEqual(@as(u8, 8), ldap.ldap_last_result(slot));
}

test "delete requires Bound" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_bind(slot, "cn=admin", 8, "pw", 2);
    _ = ldap.ldap_bind_complete(slot, 0);
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_delete(slot));
}

test "delete rejected from Anonymous" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_delete(slot));
}

test "compare requires Bound" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_bind(slot, "cn=admin", 8, "pw", 2);
    _ = ldap.ldap_bind_complete(slot, 0);
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_compare(slot));
}

test "compare rejected from Anonymous" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_compare(slot));
}

// =========================================================================
// Abandon
// =========================================================================

test "abandon from Anonymous" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_abandon(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_state(slot)); // still anonymous
}

test "abandon from Bound" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_bind(slot, "cn=admin", 8, "pw", 2);
    _ = ldap.ldap_bind_complete(slot, 0);
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_abandon(slot, 1));
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_state(slot)); // still bound
}

test "abandon rejected from Closed" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    _ = ldap.ldap_unbind(slot);
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_abandon(slot, 1));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "ldap_can_transition matches Transitions.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_can_transition(0, 3)); // Anonymous -> Binding
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_can_transition(0, 0)); // Anonymous -> Anonymous
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_can_transition(0, 2)); // Anonymous -> Closed
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_can_transition(3, 1)); // Binding -> Bound
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_can_transition(3, 0)); // Binding -> Anonymous
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_can_transition(3, 2)); // Binding -> Closed
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_can_transition(1, 3)); // Bound -> Binding
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_can_transition(1, 1)); // Bound -> Bound
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_can_transition(1, 2)); // Bound -> Closed

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_can_transition(2, 0)); // Closed -> Anonymous (terminal!)
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_can_transition(2, 1)); // Closed -> Bound
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_can_transition(2, 3)); // Closed -> Binding
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_can_transition(0, 1)); // Anonymous -> Bound (skip!)
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_can_transition(3, 3)); // Binding -> Binding
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_can_transition(1, 0)); // Bound -> Anonymous
}

test "ldap_can_modify only true for Bound" {
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_can_modify(0)); // Anonymous
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_can_modify(1)); // Bound
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_can_modify(2)); // Closed
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_can_modify(3)); // Binding
}

test "ldap_can_search true for Anonymous and Bound" {
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_can_search(0)); // Anonymous
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_can_search(1)); // Bound
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_can_search(2)); // Closed
    try std.testing.expectEqual(@as(u8, 0), ldap.ldap_can_search(3)); // Binding
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 2), ldap.ldap_state(-1)); // closed fallback
    try std.testing.expectEqual(@as(u8, 255), ldap.ldap_last_result(-1));
    try std.testing.expectEqual(@as(u32, 0), ldap.ldap_message_id(-1));
}

test "DN query safe on invalid slot" {
    var buf: [64]u8 = undefined;
    try std.testing.expectEqual(@as(u32, 0), ldap.ldap_bind_dn(-1, &buf, 64));
}

// =========================================================================
// Commands rejected on invalid slots
// =========================================================================

test "commands rejected on invalid slot" {
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_bind(-1, "a", 1, "b", 1));
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_bind_complete(-1, 0));
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_unbind(-1));
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_search(-1, "dc=x", 4, 0));
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_modify(-1));
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_add(-1));
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_delete(-1));
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_compare(-1));
    try std.testing.expectEqual(@as(u8, 1), ldap.ldap_abandon(-1, 0));
}

// =========================================================================
// Message ID counter
// =========================================================================

test "message ID increments with operations" {
    const slot = ldap.ldap_create();
    defer ldap.ldap_destroy(slot);
    try std.testing.expectEqual(@as(u32, 0), ldap.ldap_message_id(slot));

    // Bind increments
    _ = ldap.ldap_bind(slot, "cn=admin", 8, "pw", 2);
    try std.testing.expectEqual(@as(u32, 1), ldap.ldap_message_id(slot));

    // Bind complete does NOT increment (it's a response, not a request)
    _ = ldap.ldap_bind_complete(slot, 0);
    try std.testing.expectEqual(@as(u32, 1), ldap.ldap_message_id(slot));

    // Search increments
    _ = ldap.ldap_search(slot, "dc=x", 4, 0);
    try std.testing.expectEqual(@as(u32, 2), ldap.ldap_message_id(slot));

    // Modify increments
    _ = ldap.ldap_modify(slot);
    try std.testing.expectEqual(@as(u32, 3), ldap.ldap_message_id(slot));

    // Unbind increments
    _ = ldap.ldap_unbind(slot);
    try std.testing.expectEqual(@as(u32, 4), ldap.ldap_message_id(slot));
}
