// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-xmpp FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Stream lifecycle (create/destroy)
//   - State transitions (Disconnected -> Connected -> Authenticated -> Bound)
//   - Stanza send/receive counting
//   - Presence state management
//   - Resource binding
//   - Stream error handling
//   - Disconnect from any state
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const xmpp = @import("xmpp");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), xmpp.xmpp_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "StanzaType encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(xmpp.StanzaType.message));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(xmpp.StanzaType.presence));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(xmpp.StanzaType.iq));
}

test "MessageType encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(xmpp.MessageType.chat));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(xmpp.MessageType.err));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(xmpp.MessageType.groupchat));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(xmpp.MessageType.headline));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(xmpp.MessageType.normal));
}

test "PresenceType encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(xmpp.PresenceType.available));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(xmpp.PresenceType.away));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(xmpp.PresenceType.dnd));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(xmpp.PresenceType.xa));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(xmpp.PresenceType.unavailable));
}

test "IQType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(xmpp.IQType.get));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(xmpp.IQType.set));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(xmpp.IQType.result));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(xmpp.IQType.iq_error));
}

test "StreamError encoding matches Types.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(xmpp.StreamError.bad_format));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(xmpp.StreamError.conflict));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(xmpp.StreamError.connection_timeout));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(xmpp.StreamError.host_gone));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(xmpp.StreamError.host_unknown));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(xmpp.StreamError.not_authorized));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(xmpp.StreamError.policy_violation));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(xmpp.StreamError.resource_constraint));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(xmpp.StreamError.system_shutdown));
}

test "StreamState encoding matches lifecycle (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(xmpp.StreamState.disconnected));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(xmpp.StreamState.connected));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(xmpp.StreamState.authenticated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(xmpp.StreamState.bound));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(xmpp.StreamState.err));
}

// =========================================================================
// Stream lifecycle
// =========================================================================

test "create returns valid slot in Disconnected state" {
    const jid = "alice@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    try std.testing.expect(slot >= 0);
    defer xmpp.xmpp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_state(slot)); // Disconnected
}

test "create rejects empty jid" {
    const jid = "x";
    const slot = xmpp.xmpp_create(jid.ptr, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    xmpp.xmpp_destroy(-1);
    xmpp.xmpp_destroy(999);
}

// =========================================================================
// State transitions
// =========================================================================

test "connect transitions Disconnected -> Connected" {
    const jid = "bob@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_connect(slot));
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_state(slot));
}

test "authenticate transitions Connected -> Authenticated" {
    const jid = "carol@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    _ = xmpp.xmpp_connect(slot);
    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_authenticate(slot));
    try std.testing.expectEqual(@as(u8, 2), xmpp.xmpp_state(slot));
}

test "bind transitions Authenticated -> Bound" {
    const jid = "dave@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    _ = xmpp.xmpp_connect(slot);
    _ = xmpp.xmpp_authenticate(slot);

    const resource = "phone";
    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_bind(slot, resource.ptr, resource.len));
    try std.testing.expectEqual(@as(u8, 3), xmpp.xmpp_state(slot));
}

test "connect rejected from Connected" {
    const jid = "eve@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    _ = xmpp.xmpp_connect(slot);
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_connect(slot));
}

test "authenticate rejected from Disconnected" {
    const jid = "frank@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_authenticate(slot));
}

test "bind rejected from Connected" {
    const jid = "grace@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    _ = xmpp.xmpp_connect(slot);
    const resource = "laptop";
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_bind(slot, resource.ptr, resource.len));
}

// =========================================================================
// Stanza send/receive
// =========================================================================

test "send_stanza succeeds from Bound" {
    const jid = "henry@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    _ = xmpp.xmpp_connect(slot);
    _ = xmpp.xmpp_authenticate(slot);
    const resource = "desktop";
    _ = xmpp.xmpp_bind(slot, resource.ptr, resource.len);

    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_send_stanza(slot, 0)); // message
    try std.testing.expectEqual(@as(u32, 1), xmpp.xmpp_stanzas_sent(slot));
}

test "send_stanza rejected from Connected" {
    const jid = "iris@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    _ = xmpp.xmpp_connect(slot);
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_send_stanza(slot, 0));
}

test "send_stanza rejects invalid type" {
    const jid = "jack@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    _ = xmpp.xmpp_connect(slot);
    _ = xmpp.xmpp_authenticate(slot);
    const resource = "tablet";
    _ = xmpp.xmpp_bind(slot, resource.ptr, resource.len);

    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_send_stanza(slot, 99));
}

test "recv_stanza increments received count" {
    const jid = "kate@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    _ = xmpp.xmpp_connect(slot);
    _ = xmpp.xmpp_authenticate(slot);
    const resource = "phone";
    _ = xmpp.xmpp_bind(slot, resource.ptr, resource.len);

    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_recv_stanza(slot, 2)); // iq
    try std.testing.expectEqual(@as(u32, 1), xmpp.xmpp_stanzas_received(slot));
}

// =========================================================================
// Presence management
// =========================================================================

test "presence starts as available after bind" {
    const jid = "larry@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    _ = xmpp.xmpp_connect(slot);
    _ = xmpp.xmpp_authenticate(slot);
    const resource = "phone";
    _ = xmpp.xmpp_bind(slot, resource.ptr, resource.len);

    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_presence(slot)); // available
}

test "set_presence changes presence state" {
    const jid = "mary@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    _ = xmpp.xmpp_connect(slot);
    _ = xmpp.xmpp_authenticate(slot);
    const resource = "phone";
    _ = xmpp.xmpp_bind(slot, resource.ptr, resource.len);

    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_set_presence(slot, 2)); // dnd
    try std.testing.expectEqual(@as(u8, 2), xmpp.xmpp_presence(slot));
}

test "set_presence rejected from Connected" {
    const jid = "ned@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    _ = xmpp.xmpp_connect(slot);
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_set_presence(slot, 0));
}

test "set_presence rejects invalid tag" {
    const jid = "olivia@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    _ = xmpp.xmpp_connect(slot);
    _ = xmpp.xmpp_authenticate(slot);
    const resource = "phone";
    _ = xmpp.xmpp_bind(slot, resource.ptr, resource.len);

    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_set_presence(slot, 99));
}

// =========================================================================
// Stream error
// =========================================================================

test "stream_error transitions to Error state" {
    const jid = "pete@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    _ = xmpp.xmpp_connect(slot);
    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_stream_error(slot, 5)); // not-authorized
    try std.testing.expectEqual(@as(u8, 4), xmpp.xmpp_state(slot)); // Error
}

test "stream_error rejected from Disconnected" {
    const jid = "quinn@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_stream_error(slot, 0));
}

test "stream_error rejects invalid code" {
    const jid = "rosa@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    _ = xmpp.xmpp_connect(slot);
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_stream_error(slot, 99));
}

// =========================================================================
// Disconnect
// =========================================================================

test "disconnect from Bound resets presence" {
    const jid = "sam@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    _ = xmpp.xmpp_connect(slot);
    _ = xmpp.xmpp_authenticate(slot);
    const resource = "phone";
    _ = xmpp.xmpp_bind(slot, resource.ptr, resource.len);

    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_state(slot)); // Disconnected
    try std.testing.expectEqual(@as(u8, 4), xmpp.xmpp_presence(slot)); // unavailable
}

test "disconnect from Error" {
    const jid = "tina@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    _ = xmpp.xmpp_connect(slot);
    _ = xmpp.xmpp_stream_error(slot, 8); // system-shutdown
    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_state(slot));
}

test "disconnect rejected from Disconnected" {
    const jid = "uma@example.com";
    const slot = xmpp.xmpp_create(jid.ptr, jid.len);
    defer xmpp.xmpp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_disconnect(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "xmpp_can_transition matches stream lifecycle" {
    // Valid forward
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_can_transition(0, 1)); // Disconnected -> Connected
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_can_transition(1, 2)); // Connected -> Authenticated
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_can_transition(2, 3)); // Authenticated -> Bound

    // Error transitions
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_can_transition(1, 4)); // Connected -> Error
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_can_transition(2, 4)); // Authenticated -> Error
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_can_transition(3, 4)); // Bound -> Error

    // Disconnect transitions
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_can_transition(1, 0)); // Connected -> Disconnected
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_can_transition(2, 0)); // Authenticated -> Disconnected
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_can_transition(3, 0)); // Bound -> Disconnected
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_can_transition(4, 0)); // Error -> Disconnected

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_can_transition(0, 2)); // Disconnected -/-> Authenticated
    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_can_transition(0, 3)); // Disconnected -/-> Bound
    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_can_transition(4, 3)); // Error -/-> Bound
    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_can_transition(3, 1)); // Bound -/-> Connected
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), xmpp.xmpp_state(-1));
    try std.testing.expectEqual(@as(u32, 0), xmpp.xmpp_stanzas_sent(-1));
    try std.testing.expectEqual(@as(u32, 0), xmpp.xmpp_stanzas_received(-1));
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_connect(-1));
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_authenticate(-1));
    try std.testing.expectEqual(@as(u8, 1), xmpp.xmpp_disconnect(-1));
}
