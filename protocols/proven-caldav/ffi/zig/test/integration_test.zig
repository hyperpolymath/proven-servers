// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-caldav FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Server lifecycle (create/destroy)
//   - Calendar collection management (create/delete/count)
//   - Resource management (put/delete/count/etag)
//   - UID uniqueness enforcement
//   - Supported component type filtering
//   - ETag tracking
//   - Shutdown / Cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const caldav = @import("caldav");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), caldav.caldav_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "ComponentType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(caldav.ComponentType.vevent));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(caldav.ComponentType.vtodo));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(caldav.ComponentType.vjournal));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(caldav.ComponentType.vfreebusy));
}

test "CalMethod encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(caldav.CalMethod.get));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(caldav.CalMethod.put));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(caldav.CalMethod.delete));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(caldav.CalMethod.propfind));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(caldav.CalMethod.proppatch));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(caldav.CalMethod.report));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(caldav.CalMethod.mkcalendar));
}

test "ScheduleStatus encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(caldav.ScheduleStatus.needs_action));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(caldav.ScheduleStatus.accepted));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(caldav.ScheduleStatus.declined));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(caldav.ScheduleStatus.tentative));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(caldav.ScheduleStatus.delegated));
}

test "CalError encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(caldav.CalError.valid_calendar_data));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(caldav.CalError.no_resource_type_change));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(caldav.CalError.supported_component_mismatch));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(caldav.CalError.max_resource_size));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(caldav.CalError.uid_conflict));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(caldav.CalError.precondition_failed));
}

test "ServerState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(caldav.ServerState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(caldav.ServerState.bound));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(caldav.ServerState.serving));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(caldav.ServerState.scheduling));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(caldav.ServerState.shutdown));
}

// =========================================================================
// Server lifecycle
// =========================================================================

test "create returns valid slot in Bound state" {
    const slot = caldav.caldav_create(8080);
    try std.testing.expect(slot >= 0);
    defer caldav.caldav_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_state(slot)); // Bound
}

test "create rejects port 0" {
    const slot = caldav.caldav_create(0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    caldav.caldav_destroy(-1);
    caldav.caldav_destroy(999);
}

// =========================================================================
// Calendar collection management
// =========================================================================

test "create_calendar transitions Bound -> Serving" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    const path = "/calendars/personal";
    try std.testing.expectEqual(@as(u8, 0), caldav.caldav_create_calendar(
        slot, path.ptr, path.len, 0x03, // VEVENT + VTODO
    ));
    try std.testing.expectEqual(@as(u8, 2), caldav.caldav_state(slot)); // Serving
    try std.testing.expectEqual(@as(u32, 1), caldav.caldav_calendar_count(slot));
}

test "create_calendar rejects empty supported components" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    const path = "/calendars/bad";
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_create_calendar(
        slot, path.ptr, path.len, 0x00,
    ));
}

test "create_calendar rejects duplicate path" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    const path = "/calendars/personal";
    _ = caldav.caldav_create_calendar(slot, path.ptr, path.len, 0x0F);
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_create_calendar(
        slot, path.ptr, path.len, 0x0F,
    ));
}

test "delete_calendar last calendar transitions Serving -> Bound" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    const path = "/calendars/personal";
    _ = caldav.caldav_create_calendar(slot, path.ptr, path.len, 0x0F);

    try std.testing.expectEqual(@as(u8, 0), caldav.caldav_delete_calendar(
        slot, path.ptr, path.len,
    ));
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_state(slot)); // Bound
    try std.testing.expectEqual(@as(u32, 0), caldav.caldav_calendar_count(slot));
}

// =========================================================================
// Resource management
// =========================================================================

test "put_resource creates event in calendar" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    const cal = "/calendars/personal";
    _ = caldav.caldav_create_calendar(slot, cal.ptr, cal.len, 0x0F);

    const uid = "event-001@example.com";
    try std.testing.expectEqual(@as(u8, 0), caldav.caldav_put_resource(
        slot, cal.ptr, cal.len, uid.ptr, uid.len, 0, 12345, // VEVENT, etag=12345
    ));
    try std.testing.expectEqual(@as(u32, 1), caldav.caldav_resource_count(
        slot, cal.ptr, cal.len,
    ));
}

test "put_resource updates existing UID (idempotent)" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    const cal = "/calendars/personal";
    _ = caldav.caldav_create_calendar(slot, cal.ptr, cal.len, 0x0F);

    const uid = "event-001@example.com";
    _ = caldav.caldav_put_resource(slot, cal.ptr, cal.len, uid.ptr, uid.len, 0, 100);
    _ = caldav.caldav_put_resource(slot, cal.ptr, cal.len, uid.ptr, uid.len, 0, 200);

    // Should still be 1 resource (updated, not duplicated)
    try std.testing.expectEqual(@as(u32, 1), caldav.caldav_resource_count(
        slot, cal.ptr, cal.len,
    ));
    // ETag should be updated
    try std.testing.expectEqual(@as(u32, 200), caldav.caldav_get_etag(
        slot, cal.ptr, cal.len, uid.ptr, uid.len,
    ));
}

test "put_resource rejects unsupported component type" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    const cal = "/calendars/events-only";
    _ = caldav.caldav_create_calendar(slot, cal.ptr, cal.len, 0x01); // VEVENT only

    const uid = "todo-001@example.com";
    // component_type=1 (VTODO), but calendar only supports VEVENT
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_put_resource(
        slot, cal.ptr, cal.len, uid.ptr, uid.len, 1, 100,
    ));
}

test "put_resource rejects invalid component type" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    const cal = "/calendars/personal";
    _ = caldav.caldav_create_calendar(slot, cal.ptr, cal.len, 0x0F);

    const uid = "bad@example.com";
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_put_resource(
        slot, cal.ptr, cal.len, uid.ptr, uid.len, 99, 100,
    ));
}

test "delete_resource removes resource" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    const cal = "/calendars/personal";
    _ = caldav.caldav_create_calendar(slot, cal.ptr, cal.len, 0x0F);

    const uid = "event-001@example.com";
    _ = caldav.caldav_put_resource(slot, cal.ptr, cal.len, uid.ptr, uid.len, 0, 100);

    try std.testing.expectEqual(@as(u8, 0), caldav.caldav_delete_resource(
        slot, cal.ptr, cal.len, uid.ptr, uid.len,
    ));
    try std.testing.expectEqual(@as(u32, 0), caldav.caldav_resource_count(
        slot, cal.ptr, cal.len,
    ));
}

test "get_etag returns 0 for non-existent resource" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    const cal = "/calendars/personal";
    _ = caldav.caldav_create_calendar(slot, cal.ptr, cal.len, 0x0F);

    const uid = "nonexistent@example.com";
    try std.testing.expectEqual(@as(u32, 0), caldav.caldav_get_etag(
        slot, cal.ptr, cal.len, uid.ptr, uid.len,
    ));
}

test "total_resources counts across all calendars" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    const cal1 = "/calendars/personal";
    const cal2 = "/calendars/work";
    _ = caldav.caldav_create_calendar(slot, cal1.ptr, cal1.len, 0x0F);
    _ = caldav.caldav_create_calendar(slot, cal2.ptr, cal2.len, 0x0F);

    const uid1 = "event-001@example.com";
    const uid2 = "event-002@example.com";
    const uid3 = "event-003@example.com";
    _ = caldav.caldav_put_resource(slot, cal1.ptr, cal1.len, uid1.ptr, uid1.len, 0, 1);
    _ = caldav.caldav_put_resource(slot, cal1.ptr, cal1.len, uid2.ptr, uid2.len, 0, 2);
    _ = caldav.caldav_put_resource(slot, cal2.ptr, cal2.len, uid3.ptr, uid3.len, 0, 3);

    try std.testing.expectEqual(@as(u32, 3), caldav.caldav_total_resources(slot));
}

// =========================================================================
// Shutdown / Cleanup
// =========================================================================

test "shutdown transitions Serving -> Shutdown" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    const cal = "/calendars/personal";
    _ = caldav.caldav_create_calendar(slot, cal.ptr, cal.len, 0x0F);

    try std.testing.expectEqual(@as(u8, 0), caldav.caldav_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 4), caldav.caldav_state(slot));
}

test "cleanup transitions Shutdown -> Idle" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    _ = caldav.caldav_shutdown(slot);
    try std.testing.expectEqual(@as(u8, 0), caldav.caldav_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), caldav.caldav_state(slot));
}

test "cleanup clears calendars" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    const cal = "/calendars/personal";
    _ = caldav.caldav_create_calendar(slot, cal.ptr, cal.len, 0x0F);

    _ = caldav.caldav_shutdown(slot);
    _ = caldav.caldav_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), caldav.caldav_calendar_count(slot));
}

test "cleanup rejected from non-Shutdown state" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "caldav_can_transition matches Types.idr" {
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_can_transition(0, 1)); // Idle -> Bound
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_can_transition(1, 2)); // Bound -> Serving
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_can_transition(2, 1)); // Serving -> Bound
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_can_transition(2, 3)); // Serving -> Scheduling
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_can_transition(3, 2)); // Scheduling -> Serving
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_can_transition(1, 4)); // Bound -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_can_transition(2, 4)); // Serving -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_can_transition(3, 4)); // Scheduling -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_can_transition(4, 0)); // Shutdown -> Idle

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), caldav.caldav_can_transition(0, 2)); // Idle -/-> Serving
    try std.testing.expectEqual(@as(u8, 0), caldav.caldav_can_transition(4, 1)); // Shutdown -/-> Bound
    try std.testing.expectEqual(@as(u8, 0), caldav.caldav_can_transition(0, 4)); // Idle -/-> Shutdown
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), caldav.caldav_state(-1));
    try std.testing.expectEqual(@as(u8, 0), caldav.caldav_can_serve(-1));
    try std.testing.expectEqual(@as(u32, 0), caldav.caldav_calendar_count(-1));
    try std.testing.expectEqual(@as(u32, 0), caldav.caldav_total_resources(-1));
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_shutdown(-1));
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_cleanup(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot create calendar from Idle" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    _ = caldav.caldav_shutdown(slot);
    _ = caldav.caldav_cleanup(slot);
    const cal = "/calendars/bad";
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_create_calendar(
        slot, cal.ptr, cal.len, 0x0F,
    ));
}

test "cannot put resource from Bound" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    const cal = "/calendars/personal";
    const uid = "event@example.com";
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_put_resource(
        slot, cal.ptr, cal.len, uid.ptr, uid.len, 0, 100,
    ));
}

test "can_serve returns 0 from Bound" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), caldav.caldav_can_serve(slot));
}

test "can_serve returns 1 from Serving" {
    const slot = caldav.caldav_create(8080);
    defer caldav.caldav_destroy(slot);

    const cal = "/calendars/personal";
    _ = caldav.caldav_create_calendar(slot, cal.ptr, cal.len, 0x0F);
    try std.testing.expectEqual(@as(u8, 1), caldav.caldav_can_serve(slot));
}
