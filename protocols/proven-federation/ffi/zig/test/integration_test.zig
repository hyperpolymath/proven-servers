// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-federation FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Actor registration
//   - Activity submission
//   - Delivery lifecycle
//   - Trust level management
//   - Shutdown / Cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const fed = @import("federation");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), fed.fed_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "ActivityType encoding matches Types.idr (11 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fed.ActivityType.create));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fed.ActivityType.update));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fed.ActivityType.delete));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fed.ActivityType.follow));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(fed.ActivityType.accept));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(fed.ActivityType.reject));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(fed.ActivityType.announce));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(fed.ActivityType.like));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(fed.ActivityType.undo));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(fed.ActivityType.block));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(fed.ActivityType.flag));
}

test "ActorType encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fed.ActorType.person));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fed.ActorType.service));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fed.ActorType.application));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fed.ActorType.group));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(fed.ActorType.organization));
}

test "DeliveryStatus encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fed.DeliveryStatus.pending));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fed.DeliveryStatus.delivered));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fed.DeliveryStatus.failed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fed.DeliveryStatus.rejected));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(fed.DeliveryStatus.deferred));
}

test "TrustLevel encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fed.TrustLevel.self_signed));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fed.TrustLevel.peer_verified));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fed.TrustLevel.federation_trusted));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fed.TrustLevel.revoked));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(fed.TrustLevel.unknown));
}

test "ObjectType encoding matches Types.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fed.ObjectType.note));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fed.ObjectType.article));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fed.ObjectType.image));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fed.ObjectType.video));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(fed.ObjectType.audio));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(fed.ObjectType.document));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(fed.ObjectType.event));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(fed.ObjectType.collection));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(fed.ObjectType.ordered_collection));
}

test "ServerState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fed.ServerState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fed.ServerState.active));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fed.ServerState.processing));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fed.ServerState.delivering));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(fed.ServerState.shutdown));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Active state" {
    const domain = "example.social";
    const slot = fed.fed_create(domain.ptr, domain.len);
    try std.testing.expect(slot >= 0);
    defer fed.fed_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), fed.fed_state(slot)); // Active
}

test "create rejects empty domain" {
    const domain = "x";
    const slot = fed.fed_create(domain.ptr, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    fed.fed_destroy(-1);
    fed.fed_destroy(999);
}

// =========================================================================
// Actor registration
// =========================================================================

test "register_actor creates Person actor" {
    const domain = "actors.social";
    const slot = fed.fed_create(domain.ptr, domain.len);
    defer fed.fed_destroy(slot);

    const name = "alice";
    try std.testing.expectEqual(@as(u8, 0), fed.fed_register_actor(slot, 0, name.ptr, name.len));
    try std.testing.expectEqual(@as(u32, 1), fed.fed_actor_count(slot));
}

test "register_actor rejects invalid actor type" {
    const domain = "badactor.social";
    const slot = fed.fed_create(domain.ptr, domain.len);
    defer fed.fed_destroy(slot);

    const name = "bad";
    try std.testing.expectEqual(@as(u8, 1), fed.fed_register_actor(slot, 99, name.ptr, name.len));
}

// =========================================================================
// Activity submission
// =========================================================================

test "submit_activity creates Note activity" {
    const domain = "activity.social";
    const slot = fed.fed_create(domain.ptr, domain.len);
    defer fed.fed_destroy(slot);

    const name = "alice";
    _ = fed.fed_register_actor(slot, 0, name.ptr, name.len);

    try std.testing.expectEqual(@as(u8, 0), fed.fed_submit_activity(slot, 0, 0, 0)); // Create Note
    try std.testing.expectEqual(@as(u32, 1), fed.fed_activity_count(slot));
}

test "submit_activity rejects invalid activity type" {
    const domain = "badact.social";
    const slot = fed.fed_create(domain.ptr, domain.len);
    defer fed.fed_destroy(slot);

    const name = "alice";
    _ = fed.fed_register_actor(slot, 0, name.ptr, name.len);
    try std.testing.expectEqual(@as(u8, 1), fed.fed_submit_activity(slot, 99, 0, 0));
}

test "submit_activity rejects non-existent actor" {
    const domain = "noactor.social";
    const slot = fed.fed_create(domain.ptr, domain.len);
    defer fed.fed_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), fed.fed_submit_activity(slot, 0, 0, 0));
}

// =========================================================================
// Delivery lifecycle
// =========================================================================

test "begin_delivery transitions Active -> Delivering" {
    const domain = "deliver.social";
    const slot = fed.fed_create(domain.ptr, domain.len);
    defer fed.fed_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), fed.fed_begin_delivery(slot));
    try std.testing.expectEqual(@as(u8, 3), fed.fed_state(slot)); // Delivering
}

test "finish_delivery transitions Delivering -> Active" {
    const domain = "finishdeliver.social";
    const slot = fed.fed_create(domain.ptr, domain.len);
    defer fed.fed_destroy(slot);

    _ = fed.fed_begin_delivery(slot);
    try std.testing.expectEqual(@as(u8, 0), fed.fed_finish_delivery(slot, 1)); // delivered
    try std.testing.expectEqual(@as(u8, 1), fed.fed_state(slot)); // Active
}

test "begin_delivery rejects from non-Active state" {
    const domain = "baddeliver.social";
    const slot = fed.fed_create(domain.ptr, domain.len);
    defer fed.fed_destroy(slot);

    _ = fed.fed_begin_delivery(slot);
    try std.testing.expectEqual(@as(u8, 1), fed.fed_begin_delivery(slot)); // rejected (Delivering)
}

// =========================================================================
// Trust management
// =========================================================================

test "set_trust and get_trust round-trip" {
    const domain = "trust.social";
    const slot = fed.fed_create(domain.ptr, domain.len);
    defer fed.fed_destroy(slot);

    const name = "bob";
    _ = fed.fed_register_actor(slot, 0, name.ptr, name.len);

    try std.testing.expectEqual(@as(u8, 4), fed.fed_get_trust(slot, 0)); // unknown (default)
    try std.testing.expectEqual(@as(u8, 0), fed.fed_set_trust(slot, 0, 2)); // set to federation_trusted
    try std.testing.expectEqual(@as(u8, 2), fed.fed_get_trust(slot, 0)); // federation_trusted
}

test "set_trust rejects invalid trust level" {
    const domain = "badtrust.social";
    const slot = fed.fed_create(domain.ptr, domain.len);
    defer fed.fed_destroy(slot);

    const name = "carol";
    _ = fed.fed_register_actor(slot, 0, name.ptr, name.len);
    try std.testing.expectEqual(@as(u8, 1), fed.fed_set_trust(slot, 0, 99));
}

// =========================================================================
// Shutdown / Cleanup
// =========================================================================

test "shutdown transitions Active -> Shutdown" {
    const domain = "shutdown.social";
    const slot = fed.fed_create(domain.ptr, domain.len);
    defer fed.fed_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), fed.fed_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 4), fed.fed_state(slot)); // Shutdown
}

test "cleanup transitions Shutdown -> Idle" {
    const domain = "cleanup.social";
    const slot = fed.fed_create(domain.ptr, domain.len);
    defer fed.fed_destroy(slot);

    _ = fed.fed_shutdown(slot);
    try std.testing.expectEqual(@as(u8, 0), fed.fed_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), fed.fed_state(slot)); // Idle
}

test "cleanup clears actors and activities" {
    const domain = "clearcleanup.social";
    const slot = fed.fed_create(domain.ptr, domain.len);
    defer fed.fed_destroy(slot);

    const name = "alice";
    _ = fed.fed_register_actor(slot, 0, name.ptr, name.len);
    _ = fed.fed_submit_activity(slot, 0, 0, 0);
    _ = fed.fed_shutdown(slot);
    _ = fed.fed_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), fed.fed_actor_count(slot));
    try std.testing.expectEqual(@as(u32, 0), fed.fed_activity_count(slot));
}

test "cleanup rejected from non-Shutdown state" {
    const domain = "badcleanup.social";
    const slot = fed.fed_create(domain.ptr, domain.len);
    defer fed.fed_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), fed.fed_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "fed_can_transition matches Types.idr transitions" {
    try std.testing.expectEqual(@as(u8, 1), fed.fed_can_transition(0, 1)); // Idle -> Active
    try std.testing.expectEqual(@as(u8, 1), fed.fed_can_transition(1, 2)); // Active -> Processing
    try std.testing.expectEqual(@as(u8, 1), fed.fed_can_transition(2, 1)); // Processing -> Active
    try std.testing.expectEqual(@as(u8, 1), fed.fed_can_transition(2, 3)); // Processing -> Delivering
    try std.testing.expectEqual(@as(u8, 1), fed.fed_can_transition(3, 1)); // Delivering -> Active
    try std.testing.expectEqual(@as(u8, 1), fed.fed_can_transition(1, 4)); // Active -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), fed.fed_can_transition(2, 4)); // Processing -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), fed.fed_can_transition(3, 4)); // Delivering -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), fed.fed_can_transition(4, 0)); // Shutdown -> Idle

    try std.testing.expectEqual(@as(u8, 0), fed.fed_can_transition(0, 2)); // Idle -/-> Processing
    try std.testing.expectEqual(@as(u8, 0), fed.fed_can_transition(4, 1)); // Shutdown -/-> Active
    try std.testing.expectEqual(@as(u8, 0), fed.fed_can_transition(0, 4)); // Idle -/-> Shutdown
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), fed.fed_state(-1));
    try std.testing.expectEqual(@as(u32, 0), fed.fed_actor_count(-1));
    try std.testing.expectEqual(@as(u32, 0), fed.fed_activity_count(-1));
    try std.testing.expectEqual(@as(u8, 1), fed.fed_shutdown(-1));
    try std.testing.expectEqual(@as(u8, 1), fed.fed_cleanup(-1));
}
