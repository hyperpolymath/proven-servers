// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-mdns FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Responder lifecycle (create/destroy)
//   - Service registration and unregistration
//   - Probing -> Announcing -> Running lifecycle
//   - Conflict handling (probe/defend/withdraw)
//   - Query submission and record caching
//   - Shutdown / Cleanup
//   - Stateless responder transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const mdns = @import("mdns");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), mdns.mdns_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "RecordType encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mdns.RecordType.a));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mdns.RecordType.aaaa));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mdns.RecordType.ptr));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mdns.RecordType.srv));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(mdns.RecordType.txt));
}

test "QueryType encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mdns.QueryType.standard));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mdns.QueryType.one_shot));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mdns.QueryType.continuous));
}

test "ConflictAction encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mdns.ConflictAction.probe));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mdns.ConflictAction.defend));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mdns.ConflictAction.withdraw));
}

test "ServiceFlag encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mdns.ServiceFlag.unique));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mdns.ServiceFlag.shared));
}

test "ResponderState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mdns.ResponderState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mdns.ResponderState.probing));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mdns.ResponderState.announcing));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mdns.ResponderState.running));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(mdns.ResponderState.shutting_down));
}

// =========================================================================
// Responder lifecycle
// =========================================================================

test "create returns valid slot in Idle state" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    try std.testing.expect(slot >= 0);
    defer mdns.mdns_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_state(slot)); // Idle
}

test "create rejects empty hostname" {
    const host = "x";
    try std.testing.expectEqual(@as(c_int, -1), mdns.mdns_create(host.ptr, 0));
}

test "destroy is safe with invalid slot" {
    mdns.mdns_destroy(-1);
    mdns.mdns_destroy(999);
}

// =========================================================================
// Service registration
// =========================================================================

test "register_service adds a service" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    defer mdns.mdns_destroy(slot);

    const name = "My Web Server";
    const stype = "_http._tcp.local";
    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_register_service(
        slot, name.ptr, name.len, stype.ptr, stype.len, 8080, 0,
    ));
    try std.testing.expectEqual(@as(u32, 1), mdns.mdns_service_count(slot));
}

test "register_service rejects duplicate name" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    defer mdns.mdns_destroy(slot);

    const name = "svc1";
    const stype = "_http._tcp.local";
    _ = mdns.mdns_register_service(slot, name.ptr, name.len, stype.ptr, stype.len, 80, 0);
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_register_service(
        slot, name.ptr, name.len, stype.ptr, stype.len, 80, 0,
    ));
}

test "register_service rejects port 0" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    defer mdns.mdns_destroy(slot);

    const name = "svc";
    const stype = "_http._tcp.local";
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_register_service(
        slot, name.ptr, name.len, stype.ptr, stype.len, 0, 0,
    ));
}

test "unregister_service removes a service" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    defer mdns.mdns_destroy(slot);

    const name = "svc";
    const stype = "_http._tcp.local";
    _ = mdns.mdns_register_service(slot, name.ptr, name.len, stype.ptr, stype.len, 80, 0);
    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_unregister_service(slot, name.ptr, name.len));
    try std.testing.expectEqual(@as(u32, 0), mdns.mdns_service_count(slot));
}

// =========================================================================
// Probing -> Announcing -> Running lifecycle
// =========================================================================

test "full lifecycle: Idle -> Probing -> Announcing -> Running" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    defer mdns.mdns_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_start_probing(slot));
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_state(slot)); // Probing

    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_finish_probing(slot));
    try std.testing.expectEqual(@as(u8, 2), mdns.mdns_state(slot)); // Announcing

    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_finish_announcing(slot));
    try std.testing.expectEqual(@as(u8, 3), mdns.mdns_state(slot)); // Running
}

test "start_probing rejected from non-Idle" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    defer mdns.mdns_destroy(slot);

    _ = mdns.mdns_start_probing(slot);
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_start_probing(slot));
}

// =========================================================================
// Conflict handling
// =========================================================================

test "conflict withdraw from Running returns to Idle" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    defer mdns.mdns_destroy(slot);

    _ = mdns.mdns_start_probing(slot);
    _ = mdns.mdns_finish_probing(slot);
    _ = mdns.mdns_finish_announcing(slot);

    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_handle_conflict(slot, 2)); // Withdraw
    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_state(slot)); // Idle
}

test "conflict defend from Running stays Running" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    defer mdns.mdns_destroy(slot);

    _ = mdns.mdns_start_probing(slot);
    _ = mdns.mdns_finish_probing(slot);
    _ = mdns.mdns_finish_announcing(slot);

    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_handle_conflict(slot, 1)); // Defend
    try std.testing.expectEqual(@as(u8, 3), mdns.mdns_state(slot)); // Still Running
}

test "conflict probe from Probing stays Probing" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    defer mdns.mdns_destroy(slot);

    _ = mdns.mdns_start_probing(slot);
    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_handle_conflict(slot, 0)); // Re-probe
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_state(slot)); // Still Probing
}

test "conflict rejected from Idle" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    defer mdns.mdns_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_handle_conflict(slot, 0));
}

// =========================================================================
// Query submission
// =========================================================================

test "query succeeds from Running" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    defer mdns.mdns_destroy(slot);

    _ = mdns.mdns_start_probing(slot);
    _ = mdns.mdns_finish_probing(slot);
    _ = mdns.mdns_finish_announcing(slot);

    const qname = "_http._tcp.local";
    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_query(slot, qname.ptr, qname.len, 2, 0));
    try std.testing.expectEqual(@as(u32, 1), mdns.mdns_record_count(slot));
}

test "query rejected from Idle" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    defer mdns.mdns_destroy(slot);

    const qname = "_http._tcp.local";
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_query(slot, qname.ptr, qname.len, 0, 0));
}

// =========================================================================
// Shutdown / Cleanup
// =========================================================================

test "shutdown transitions Running -> ShuttingDown" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    defer mdns.mdns_destroy(slot);

    _ = mdns.mdns_start_probing(slot);
    _ = mdns.mdns_finish_probing(slot);
    _ = mdns.mdns_finish_announcing(slot);

    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 4), mdns.mdns_state(slot));
}

test "cleanup transitions ShuttingDown -> Idle" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    defer mdns.mdns_destroy(slot);

    _ = mdns.mdns_start_probing(slot);
    _ = mdns.mdns_finish_probing(slot);
    _ = mdns.mdns_finish_announcing(slot);
    _ = mdns.mdns_shutdown(slot);

    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_state(slot)); // Idle
    try std.testing.expectEqual(@as(u32, 0), mdns.mdns_service_count(slot));
    try std.testing.expectEqual(@as(u32, 0), mdns.mdns_record_count(slot));
}

test "shutdown rejected from Idle" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    defer mdns.mdns_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_shutdown(slot));
}

test "cleanup rejected from non-ShuttingDown" {
    const host = "myhost.local";
    const slot = mdns.mdns_create(host.ptr, host.len);
    defer mdns.mdns_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "mdns_can_transition matches state machine" {
    // Valid
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_can_transition(0, 1)); // Idle -> Probing
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_can_transition(1, 2)); // Probing -> Announcing
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_can_transition(2, 3)); // Announcing -> Running
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_can_transition(1, 0)); // Probing -> Idle (withdraw)
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_can_transition(3, 1)); // Running -> Probing (re-probe)
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_can_transition(3, 0)); // Running -> Idle (withdraw)
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_can_transition(1, 4)); // Probing -> ShuttingDown
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_can_transition(2, 4)); // Announcing -> ShuttingDown
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_can_transition(3, 4)); // Running -> ShuttingDown
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_can_transition(4, 0)); // ShuttingDown -> Idle

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_can_transition(0, 3)); // Idle -/-> Running
    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_can_transition(4, 3)); // ShuttingDown -/-> Running
    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_can_transition(0, 4)); // Idle -/-> ShuttingDown
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), mdns.mdns_state(-1));
    try std.testing.expectEqual(@as(u32, 0), mdns.mdns_service_count(-1));
    try std.testing.expectEqual(@as(u32, 0), mdns.mdns_record_count(-1));
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_shutdown(-1));
    try std.testing.expectEqual(@as(u8, 1), mdns.mdns_cleanup(-1));
}
