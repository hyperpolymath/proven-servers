// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-carddav FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Server lifecycle (create/destroy)
//   - Address book management (create/delete/count)
//   - vCard management (put/delete/count)
//   - UID uniqueness enforcement
//   - vCard version validation
//   - Shutdown / Cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const carddav = @import("carddav");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), carddav.carddav_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "PropertyType encoding matches Types.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(carddav.PropertyType.fn_name));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(carddav.PropertyType.n));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(carddav.PropertyType.email));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(carddav.PropertyType.tel));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(carddav.PropertyType.adr));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(carddav.PropertyType.org));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(carddav.PropertyType.photo));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(carddav.PropertyType.url));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(carddav.PropertyType.note));
}

test "CardMethod encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(carddav.CardMethod.get));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(carddav.CardMethod.put));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(carddav.CardMethod.delete));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(carddav.CardMethod.propfind));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(carddav.CardMethod.proppatch));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(carddav.CardMethod.report));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(carddav.CardMethod.mkcol));
}

test "VCardVersion encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(carddav.VCardVersion.vcard3));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(carddav.VCardVersion.vcard4));
}

test "CardError encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(carddav.CardError.valid_address_data));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(carddav.CardError.no_resource_type));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(carddav.CardError.max_resource_size));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(carddav.CardError.uid_conflict));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(carddav.CardError.supported_address_data));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(carddav.CardError.precondition_failed));
}

test "ServerState encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(carddav.ServerState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(carddav.ServerState.bound));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(carddav.ServerState.serving));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(carddav.ServerState.shutdown));
}

// =========================================================================
// Server lifecycle
// =========================================================================

test "create returns valid slot in Bound state" {
    const slot = carddav.carddav_create(8080);
    try std.testing.expect(slot >= 0);
    defer carddav.carddav_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), carddav.carddav_state(slot)); // Bound
}

test "create rejects port 0" {
    const slot = carddav.carddav_create(0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    carddav.carddav_destroy(-1);
    carddav.carddav_destroy(999);
}

// =========================================================================
// Address book management
// =========================================================================

test "create_addressbook transitions Bound -> Serving" {
    const slot = carddav.carddav_create(8080);
    defer carddav.carddav_destroy(slot);

    const path = "/addressbooks/contacts";
    try std.testing.expectEqual(@as(u8, 0), carddav.carddav_create_addressbook(
        slot, path.ptr, path.len,
    ));
    try std.testing.expectEqual(@as(u8, 2), carddav.carddav_state(slot)); // Serving
    try std.testing.expectEqual(@as(u32, 1), carddav.carddav_addressbook_count(slot));
}

test "create_addressbook rejects duplicate path" {
    const slot = carddav.carddav_create(8080);
    defer carddav.carddav_destroy(slot);

    const path = "/addressbooks/contacts";
    _ = carddav.carddav_create_addressbook(slot, path.ptr, path.len);
    try std.testing.expectEqual(@as(u8, 1), carddav.carddav_create_addressbook(
        slot, path.ptr, path.len,
    ));
}

test "delete_addressbook last book transitions Serving -> Bound" {
    const slot = carddav.carddav_create(8080);
    defer carddav.carddav_destroy(slot);

    const path = "/addressbooks/contacts";
    _ = carddav.carddav_create_addressbook(slot, path.ptr, path.len);

    try std.testing.expectEqual(@as(u8, 0), carddav.carddav_delete_addressbook(
        slot, path.ptr, path.len,
    ));
    try std.testing.expectEqual(@as(u8, 1), carddav.carddav_state(slot)); // Bound
}

// =========================================================================
// vCard management
// =========================================================================

test "put_vcard creates contact" {
    const slot = carddav.carddav_create(8080);
    defer carddav.carddav_destroy(slot);

    const ab = "/addressbooks/contacts";
    _ = carddav.carddav_create_addressbook(slot, ab.ptr, ab.len);

    const uid = "john-doe@example.com";
    try std.testing.expectEqual(@as(u8, 0), carddav.carddav_put_vcard(
        slot, ab.ptr, ab.len, uid.ptr, uid.len, 1, 12345, // vCard 4.0
    ));
    try std.testing.expectEqual(@as(u32, 1), carddav.carddav_vcard_count(
        slot, ab.ptr, ab.len,
    ));
}

test "put_vcard updates existing UID (idempotent)" {
    const slot = carddav.carddav_create(8080);
    defer carddav.carddav_destroy(slot);

    const ab = "/addressbooks/contacts";
    _ = carddav.carddav_create_addressbook(slot, ab.ptr, ab.len);

    const uid = "john-doe@example.com";
    _ = carddav.carddav_put_vcard(slot, ab.ptr, ab.len, uid.ptr, uid.len, 1, 100);
    _ = carddav.carddav_put_vcard(slot, ab.ptr, ab.len, uid.ptr, uid.len, 1, 200);

    try std.testing.expectEqual(@as(u32, 1), carddav.carddav_vcard_count(
        slot, ab.ptr, ab.len,
    ));
}

test "put_vcard rejects invalid version" {
    const slot = carddav.carddav_create(8080);
    defer carddav.carddav_destroy(slot);

    const ab = "/addressbooks/contacts";
    _ = carddav.carddav_create_addressbook(slot, ab.ptr, ab.len);

    const uid = "bad@example.com";
    try std.testing.expectEqual(@as(u8, 1), carddav.carddav_put_vcard(
        slot, ab.ptr, ab.len, uid.ptr, uid.len, 99, 100,
    ));
}

test "delete_vcard removes contact" {
    const slot = carddav.carddav_create(8080);
    defer carddav.carddav_destroy(slot);

    const ab = "/addressbooks/contacts";
    _ = carddav.carddav_create_addressbook(slot, ab.ptr, ab.len);

    const uid = "john-doe@example.com";
    _ = carddav.carddav_put_vcard(slot, ab.ptr, ab.len, uid.ptr, uid.len, 1, 100);

    try std.testing.expectEqual(@as(u8, 0), carddav.carddav_delete_vcard(
        slot, ab.ptr, ab.len, uid.ptr, uid.len,
    ));
    try std.testing.expectEqual(@as(u32, 0), carddav.carddav_vcard_count(
        slot, ab.ptr, ab.len,
    ));
}

test "total_vcards counts across all address books" {
    const slot = carddav.carddav_create(8080);
    defer carddav.carddav_destroy(slot);

    const ab1 = "/addressbooks/personal";
    const ab2 = "/addressbooks/work";
    _ = carddav.carddav_create_addressbook(slot, ab1.ptr, ab1.len);
    _ = carddav.carddav_create_addressbook(slot, ab2.ptr, ab2.len);

    const uid1 = "alice@example.com";
    const uid2 = "bob@example.com";
    const uid3 = "carol@example.com";
    _ = carddav.carddav_put_vcard(slot, ab1.ptr, ab1.len, uid1.ptr, uid1.len, 1, 1);
    _ = carddav.carddav_put_vcard(slot, ab1.ptr, ab1.len, uid2.ptr, uid2.len, 1, 2);
    _ = carddav.carddav_put_vcard(slot, ab2.ptr, ab2.len, uid3.ptr, uid3.len, 0, 3);

    try std.testing.expectEqual(@as(u32, 3), carddav.carddav_total_vcards(slot));
}

// =========================================================================
// Shutdown / Cleanup
// =========================================================================

test "shutdown transitions Serving -> Shutdown" {
    const slot = carddav.carddav_create(8080);
    defer carddav.carddav_destroy(slot);

    const ab = "/addressbooks/contacts";
    _ = carddav.carddav_create_addressbook(slot, ab.ptr, ab.len);

    try std.testing.expectEqual(@as(u8, 0), carddav.carddav_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 3), carddav.carddav_state(slot));
}

test "cleanup transitions Shutdown -> Idle" {
    const slot = carddav.carddav_create(8080);
    defer carddav.carddav_destroy(slot);

    _ = carddav.carddav_shutdown(slot);
    try std.testing.expectEqual(@as(u8, 0), carddav.carddav_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), carddav.carddav_state(slot));
}

test "cleanup rejected from non-Shutdown state" {
    const slot = carddav.carddav_create(8080);
    defer carddav.carddav_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), carddav.carddav_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "carddav_can_transition matches Types.idr" {
    try std.testing.expectEqual(@as(u8, 1), carddav.carddav_can_transition(0, 1)); // Idle -> Bound
    try std.testing.expectEqual(@as(u8, 1), carddav.carddav_can_transition(1, 2)); // Bound -> Serving
    try std.testing.expectEqual(@as(u8, 1), carddav.carddav_can_transition(2, 2)); // Serving -> Serving
    try std.testing.expectEqual(@as(u8, 1), carddav.carddav_can_transition(2, 1)); // Serving -> Bound
    try std.testing.expectEqual(@as(u8, 1), carddav.carddav_can_transition(1, 3)); // Bound -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), carddav.carddav_can_transition(2, 3)); // Serving -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), carddav.carddav_can_transition(3, 0)); // Shutdown -> Idle

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), carddav.carddav_can_transition(0, 2)); // Idle -/-> Serving
    try std.testing.expectEqual(@as(u8, 0), carddav.carddav_can_transition(3, 1)); // Shutdown -/-> Bound
    try std.testing.expectEqual(@as(u8, 0), carddav.carddav_can_transition(0, 3)); // Idle -/-> Shutdown
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), carddav.carddav_state(-1));
    try std.testing.expectEqual(@as(u32, 0), carddav.carddav_addressbook_count(-1));
    try std.testing.expectEqual(@as(u32, 0), carddav.carddav_total_vcards(-1));
    try std.testing.expectEqual(@as(u8, 1), carddav.carddav_shutdown(-1));
    try std.testing.expectEqual(@as(u8, 1), carddav.carddav_cleanup(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot create addressbook from Idle" {
    const slot = carddav.carddav_create(8080);
    defer carddav.carddav_destroy(slot);

    _ = carddav.carddav_shutdown(slot);
    _ = carddav.carddav_cleanup(slot);
    const ab = "/addressbooks/bad";
    try std.testing.expectEqual(@as(u8, 1), carddav.carddav_create_addressbook(
        slot, ab.ptr, ab.len,
    ));
}

test "cannot put vcard from Bound" {
    const slot = carddav.carddav_create(8080);
    defer carddav.carddav_destroy(slot);

    const ab = "/addressbooks/contacts";
    const uid = "test@example.com";
    try std.testing.expectEqual(@as(u8, 1), carddav.carddav_put_vcard(
        slot, ab.ptr, ab.len, uid.ptr, uid.len, 1, 100,
    ));
}
