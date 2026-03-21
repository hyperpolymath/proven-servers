// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig — Integration tests for the proven-socks FFI.
//
// Tests cover:
//   - ABI version check
//   - Connection lifecycle (create, destroy, state queries)
//   - Authentication flow (Initial -> Authenticating -> Authenticated)
//   - Authentication failure (Authenticating -> Closed)
//   - Command execution (Authenticated -> Connecting -> Established)
//   - Connection failure (Connecting -> Closed)
//   - Close from any state
//   - Stateless transition validation
//   - Edge cases (invalid slots, double destroy, etc.)

const std = @import("std");
const socks = @import("socks");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ── ABI Version ─────────────────────────────────────────────────────────

test "abi version returns 1" {
    try expectEqual(@as(u32, 1), socks.socks_abi_version());
}

// ── Create and Destroy ──────────────────────────────────────────────────

test "create returns valid slot" {
    const slot = socks.socks_create(0); // NoAuth
    try expect(slot >= 0);
    socks.socks_destroy(slot);
}

test "create with invalid auth returns -1" {
    const slot = socks.socks_create(99);
    try expectEqual(@as(c_int, -1), slot);
}

test "destroy invalid slot is safe" {
    socks.socks_destroy(-1);
    socks.socks_destroy(999);
}

test "double destroy is safe" {
    const slot = socks.socks_create(0);
    socks.socks_destroy(slot);
    socks.socks_destroy(slot);
}

// ── State Queries on Fresh Connection ───────────────────────────────────

test "fresh connection is in Initial state" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    try expectEqual(@as(u8, 0), socks.socks_get_state(slot)); // Initial
}

test "fresh connection has specified auth method" {
    const slot = socks.socks_create(2); // UsernamePassword
    defer socks.socks_destroy(slot);
    try expectEqual(@as(u8, 2), socks.socks_get_auth(slot));
}

test "fresh connection has no reply (255)" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    try expectEqual(@as(u8, 255), socks.socks_get_reply(slot));
}

test "fresh connection has no command (255)" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    try expectEqual(@as(u8, 255), socks.socks_get_command(slot));
}

test "fresh connection has no addr type (255)" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    try expectEqual(@as(u8, 255), socks.socks_get_addr_type(slot));
}

// ── Queries on Invalid Slot ─────────────────────────────────────────────

test "get_state on invalid slot returns 0" {
    try expectEqual(@as(u8, 0), socks.socks_get_state(-1));
}

test "get_reply on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), socks.socks_get_reply(-1));
}

test "get_command on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), socks.socks_get_command(-1));
}

// ── Authentication Flow ─────────────────────────────────────────────────

test "authenticate transitions Initial -> Authenticating" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    try expectEqual(@as(u8, 0), socks.socks_authenticate(slot)); // Ok
    try expectEqual(@as(u8, 1), socks.socks_get_state(slot)); // Authenticating
}

test "authenticate from non-Initial state fails" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    _ = socks.socks_authenticate(slot); // -> Authenticating
    try expectEqual(@as(u8, 3), socks.socks_authenticate(slot)); // InvalidState
}

test "auth_complete with Succeeded transitions to Authenticated" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    _ = socks.socks_authenticate(slot);
    try expectEqual(@as(u8, 0), socks.socks_auth_complete(slot, 0)); // Succeeded
    try expectEqual(@as(u8, 2), socks.socks_get_state(slot)); // Authenticated
    try expectEqual(@as(u8, 0), socks.socks_get_reply(slot)); // Succeeded
}

test "auth_complete with failure transitions to Closed" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    _ = socks.socks_authenticate(slot);
    try expectEqual(@as(u8, 0), socks.socks_auth_complete(slot, 1)); // GeneralFailure
    try expectEqual(@as(u8, 5), socks.socks_get_state(slot)); // Closed
    try expectEqual(@as(u8, 1), socks.socks_get_reply(slot));
}

test "auth_complete with invalid reply fails" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    _ = socks.socks_authenticate(slot);
    try expectEqual(@as(u8, 7), socks.socks_auth_complete(slot, 99)); // InvalidReply
}

test "auth_complete from wrong state fails" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    try expectEqual(@as(u8, 3), socks.socks_auth_complete(slot, 0)); // InvalidState
}

// ── Command Execution ───────────────────────────────────────────────────

test "connect transitions Authenticated -> Connecting" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    _ = socks.socks_authenticate(slot);
    _ = socks.socks_auth_complete(slot, 0);
    try expectEqual(@as(u8, 0), socks.socks_connect(slot, 0, 0)); // Connect, IPv4
    try expectEqual(@as(u8, 3), socks.socks_get_state(slot)); // Connecting
    try expectEqual(@as(u8, 0), socks.socks_get_command(slot)); // Connect
    try expectEqual(@as(u8, 0), socks.socks_get_addr_type(slot)); // IPv4
}

test "connect with Bind and IPv6" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    _ = socks.socks_authenticate(slot);
    _ = socks.socks_auth_complete(slot, 0);
    try expectEqual(@as(u8, 0), socks.socks_connect(slot, 1, 2)); // Bind, IPv6
    try expectEqual(@as(u8, 1), socks.socks_get_command(slot)); // Bind
    try expectEqual(@as(u8, 2), socks.socks_get_addr_type(slot)); // IPv6
}

test "connect with invalid command fails" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    _ = socks.socks_authenticate(slot);
    _ = socks.socks_auth_complete(slot, 0);
    try expectEqual(@as(u8, 5), socks.socks_connect(slot, 99, 0)); // InvalidCommand
}

test "connect with invalid addr type fails" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    _ = socks.socks_authenticate(slot);
    _ = socks.socks_auth_complete(slot, 0);
    try expectEqual(@as(u8, 6), socks.socks_connect(slot, 0, 99)); // InvalidAddrType
}

test "connect from wrong state fails" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    try expectEqual(@as(u8, 3), socks.socks_connect(slot, 0, 0)); // InvalidState
}

test "connect_complete with Succeeded transitions to Established" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    _ = socks.socks_authenticate(slot);
    _ = socks.socks_auth_complete(slot, 0);
    _ = socks.socks_connect(slot, 0, 0);
    try expectEqual(@as(u8, 0), socks.socks_connect_complete(slot, 0)); // Succeeded
    try expectEqual(@as(u8, 4), socks.socks_get_state(slot)); // Established
}

test "connect_complete with failure transitions to Closed" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    _ = socks.socks_authenticate(slot);
    _ = socks.socks_auth_complete(slot, 0);
    _ = socks.socks_connect(slot, 0, 0);
    try expectEqual(@as(u8, 0), socks.socks_connect_complete(slot, 5)); // ConnectionRefused
    try expectEqual(@as(u8, 5), socks.socks_get_state(slot)); // Closed
}

test "connect_complete from wrong state fails" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    try expectEqual(@as(u8, 3), socks.socks_connect_complete(slot, 0)); // InvalidState
}

// ── Close ───────────────────────────────────────────────────────────────

test "close from Established" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    _ = socks.socks_authenticate(slot);
    _ = socks.socks_auth_complete(slot, 0);
    _ = socks.socks_connect(slot, 0, 0);
    _ = socks.socks_connect_complete(slot, 0);
    socks.socks_close(slot);
    try expectEqual(@as(u8, 5), socks.socks_get_state(slot)); // Closed
}

test "close from Initial" {
    const slot = socks.socks_create(0);
    defer socks.socks_destroy(slot);
    socks.socks_close(slot);
    try expectEqual(@as(u8, 5), socks.socks_get_state(slot)); // Closed
}

test "close on invalid slot is safe" {
    socks.socks_close(-1);
}

// ── Stateless Transition Validation ─────────────────────────────────────

test "can_transition: valid forward transitions" {
    try expectEqual(@as(u8, 1), socks.socks_can_transition(0, 1)); // Initial -> Authenticating
    try expectEqual(@as(u8, 1), socks.socks_can_transition(1, 2)); // Authenticating -> Authenticated
    try expectEqual(@as(u8, 1), socks.socks_can_transition(2, 3)); // Authenticated -> Connecting
    try expectEqual(@as(u8, 1), socks.socks_can_transition(3, 4)); // Connecting -> Established
}

test "can_transition: failure transitions to Closed" {
    try expectEqual(@as(u8, 1), socks.socks_can_transition(0, 5)); // Initial -> Closed
    try expectEqual(@as(u8, 1), socks.socks_can_transition(1, 5)); // Authenticating -> Closed
    try expectEqual(@as(u8, 1), socks.socks_can_transition(3, 5)); // Connecting -> Closed
    try expectEqual(@as(u8, 1), socks.socks_can_transition(4, 5)); // Established -> Closed
}

test "can_transition: invalid transitions" {
    try expectEqual(@as(u8, 0), socks.socks_can_transition(0, 2)); // Initial -> Authenticated
    try expectEqual(@as(u8, 0), socks.socks_can_transition(0, 4)); // Initial -> Established
    try expectEqual(@as(u8, 0), socks.socks_can_transition(5, 0)); // Closed -> Initial
    try expectEqual(@as(u8, 0), socks.socks_can_transition(4, 0)); // Established -> Initial
    try expectEqual(@as(u8, 0), socks.socks_can_transition(3, 2)); // Connecting -> Authenticated
}

// ── Full Lifecycle ──────────────────────────────────────────────────────

test "full SOCKS5 lifecycle: auth, connect, establish, close" {
    const slot = socks.socks_create(2); // UsernamePassword
    defer socks.socks_destroy(slot);

    // Authenticate
    try expectEqual(@as(u8, 0), socks.socks_authenticate(slot));
    try expectEqual(@as(u8, 1), socks.socks_get_state(slot));

    // Auth succeeds
    try expectEqual(@as(u8, 0), socks.socks_auth_complete(slot, 0));
    try expectEqual(@as(u8, 2), socks.socks_get_state(slot));

    // Connect via UDPAssociate to domain name
    try expectEqual(@as(u8, 0), socks.socks_connect(slot, 2, 1)); // UDPAssociate, DomainName
    try expectEqual(@as(u8, 3), socks.socks_get_state(slot));
    try expectEqual(@as(u8, 2), socks.socks_get_command(slot));
    try expectEqual(@as(u8, 1), socks.socks_get_addr_type(slot));

    // Connection succeeds
    try expectEqual(@as(u8, 0), socks.socks_connect_complete(slot, 0));
    try expectEqual(@as(u8, 4), socks.socks_get_state(slot));

    // Close
    socks.socks_close(slot);
    try expectEqual(@as(u8, 5), socks.socks_get_state(slot));
}
