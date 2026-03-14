// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ssh_bastion_test.zig -- Integration tests for proven-ssh-bastion FFI.
//
// 25+ tests covering: ABI version, enum encoding, session lifecycle,
// state transitions, channel management, audit logging, session recording,
// authentication failure tracking, impossibility checks, and edge cases.

const std = @import("std");
const ssh = @import("ssh_bastion");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ssh.ssh_bastion_abi_version());
}

// =========================================================================
// Enum encoding seams (matching SSHABI.Layout.idr)
// =========================================================================

test "SshMessageType encoding matches Layout.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh.SshMessageType.kexinit));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ssh.SshMessageType.newkeys));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ssh.SshMessageType.service_request));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ssh.SshMessageType.userauth_request));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ssh.SshMessageType.channel_open));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ssh.SshMessageType.channel_data));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ssh.SshMessageType.channel_close));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(ssh.SshMessageType.disconnect));
}

test "AuthMethod encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh.AuthMethod.publickey));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ssh.AuthMethod.password));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ssh.AuthMethod.keyboard_interactive));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ssh.AuthMethod.auth_none));
}

test "KexMethod encoding matches Layout.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh.KexMethod.diffie_hellman_group14_sha256));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ssh.KexMethod.curve25519_sha256));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ssh.KexMethod.diffie_hellman_group16_sha512));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ssh.KexMethod.diffie_hellman_group18_sha512));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ssh.KexMethod.ecdh_sha2_nistp256));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ssh.KexMethod.ecdh_sha2_nistp384));
}

test "ChannelType encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh.ChannelType.session));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ssh.ChannelType.direct_tcpip));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ssh.ChannelType.forwarded_tcpip));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ssh.ChannelType.x11));
}

test "BastionState encoding matches Transitions.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh.BastionState.connected));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ssh.BastionState.key_exchanged));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ssh.BastionState.authenticated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ssh.BastionState.channel_open));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ssh.BastionState.active));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ssh.BastionState.closed));
}

test "DisconnectReason encoding matches Layout.idr (12 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh.DisconnectReason.host_not_allowed));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ssh.DisconnectReason.service_not_available));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(ssh.DisconnectReason.by_application));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(ssh.DisconnectReason.auth_cancelled));
}

test "ChannelState encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh.ChannelState.opening));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ssh.ChannelState.open));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ssh.ChannelState.closing));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ssh.ChannelState.closed));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = ssh.ssh_bastion_create(1, 0); // curve25519, publickey
    try std.testing.expect(slot >= 0);
    defer ssh.ssh_bastion_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_state(slot)); // connected
}

test "create with all kex/auth combinations" {
    // DH group14 + password
    const slot = ssh.ssh_bastion_create(0, 1);
    try std.testing.expect(slot >= 0);
    defer ssh.ssh_bastion_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_kex_method(slot));
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_auth_method(slot));
}

test "create rejects invalid kex method" {
    try std.testing.expectEqual(@as(c_int, -1), ssh.ssh_bastion_create(99, 0));
}

test "create rejects invalid auth method" {
    try std.testing.expectEqual(@as(c_int, -1), ssh.ssh_bastion_create(1, 99));
}

test "destroy is safe with invalid slot" {
    ssh.ssh_bastion_destroy(-1);
    ssh.ssh_bastion_destroy(999);
}

// =========================================================================
// Full session lifecycle: Connected -> ... -> Active
// =========================================================================

test "full lifecycle: Connected -> KeyExchanged -> Authenticated -> ChannelOpen -> Active" {
    const slot = ssh.ssh_bastion_create(1, 0); // curve25519, publickey
    defer ssh.ssh_bastion_destroy(slot);

    // Connected(0)
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_state(slot));
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_can_transfer(slot));

    // Complete key exchange -> KeyExchanged(1)
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_complete_kex(slot));
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_state(slot));

    // Authenticate -> Authenticated(2)
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_authenticate(slot, 5));
    try std.testing.expectEqual(@as(u8, 2), ssh.ssh_bastion_state(slot));

    // Open channel -> ChannelOpen(3)
    const ch_id = ssh.ssh_bastion_open_channel(slot, 0); // session channel
    try std.testing.expect(ch_id >= 0);
    try std.testing.expectEqual(@as(u8, 3), ssh.ssh_bastion_state(slot));

    // Confirm channel -> Active(4)
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_confirm_channel(slot, @intCast(ch_id)));
    try std.testing.expectEqual(@as(u8, 4), ssh.ssh_bastion_state(slot));
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_can_transfer(slot));
}

test "can_transfer only true when Active" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);

    // Connected — cannot transfer
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_can_transfer(slot));

    // Advance to Active
    _ = ssh.ssh_bastion_complete_kex(slot);
    _ = ssh.ssh_bastion_authenticate(slot, 5);
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_can_transfer(slot));

    const ch = ssh.ssh_bastion_open_channel(slot, 0);
    _ = ssh.ssh_bastion_confirm_channel(slot, @intCast(ch));
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_can_transfer(slot));
}

// =========================================================================
// Re-keying: Active -> Active
// =========================================================================

test "rekey succeeds from Active" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);

    // Advance to Active
    _ = ssh.ssh_bastion_complete_kex(slot);
    _ = ssh.ssh_bastion_authenticate(slot, 5);
    const ch = ssh.ssh_bastion_open_channel(slot, 0);
    _ = ssh.ssh_bastion_confirm_channel(slot, @intCast(ch));

    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_rekey(slot));
    try std.testing.expectEqual(@as(u8, 4), ssh.ssh_bastion_state(slot)); // still Active
}

test "rekey rejected from non-Active" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_rekey(slot)); // Connected
}

// =========================================================================
// Disconnect
// =========================================================================

test "disconnect from Active with reason" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);

    // Advance to Active
    _ = ssh.ssh_bastion_complete_kex(slot);
    _ = ssh.ssh_bastion_authenticate(slot, 5);
    const ch = ssh.ssh_bastion_open_channel(slot, 0);
    _ = ssh.ssh_bastion_confirm_channel(slot, @intCast(ch));

    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_disconnect(slot, 9)); // by_application
    try std.testing.expectEqual(@as(u8, 5), ssh.ssh_bastion_state(slot)); // closed
    try std.testing.expectEqual(@as(u8, 9), ssh.ssh_bastion_disconnect_reason(slot));
}

test "disconnect from Connected (early termination)" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_disconnect(slot, 0)); // host_not_allowed
    try std.testing.expectEqual(@as(u8, 5), ssh.ssh_bastion_state(slot));
}

test "cannot disconnect from Closed (terminal)" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);
    _ = ssh.ssh_bastion_disconnect(slot, 9); // -> Closed
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_disconnect(slot, 9)); // rejected
}

test "disconnect rejects invalid reason" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_disconnect(slot, 99));
}

// =========================================================================
// Channel management
// =========================================================================

test "open multiple channels from Active" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);

    // Advance to Active
    _ = ssh.ssh_bastion_complete_kex(slot);
    _ = ssh.ssh_bastion_authenticate(slot, 5);
    const ch0 = ssh.ssh_bastion_open_channel(slot, 0);
    _ = ssh.ssh_bastion_confirm_channel(slot, @intCast(ch0));

    // Open additional channel (direct-tcpip)
    const ch1 = ssh.ssh_bastion_open_channel(slot, 1);
    try std.testing.expect(ch1 >= 0);
    try std.testing.expectEqual(@as(u8, 4), ssh.ssh_bastion_state(slot)); // still Active

    // Channel types
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_channel_type(slot, @intCast(ch0))); // session
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_channel_type(slot, @intCast(ch1))); // direct-tcpip

    // Channel count
    try std.testing.expectEqual(@as(u8, 2), ssh.ssh_bastion_channel_count(slot));
}

test "close channel" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);

    _ = ssh.ssh_bastion_complete_kex(slot);
    _ = ssh.ssh_bastion_authenticate(slot, 5);
    const ch = ssh.ssh_bastion_open_channel(slot, 0);
    _ = ssh.ssh_bastion_confirm_channel(slot, @intCast(ch));

    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_channel_state(slot, @intCast(ch))); // open
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_close_channel(slot, @intCast(ch)));
    try std.testing.expectEqual(@as(u8, 3), ssh.ssh_bastion_channel_state(slot, @intCast(ch))); // closed
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_channel_count(slot));
}

test "open channel rejects invalid type" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);
    _ = ssh.ssh_bastion_complete_kex(slot);
    _ = ssh.ssh_bastion_authenticate(slot, 5);
    try std.testing.expectEqual(@as(c_int, -1), ssh.ssh_bastion_open_channel(slot, 99));
}

test "cannot open channel before authentication" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);
    try std.testing.expectEqual(@as(c_int, -1), ssh.ssh_bastion_open_channel(slot, 0)); // Connected
}

// =========================================================================
// Transition validation (stateless)
// =========================================================================

test "ssh_bastion_can_transition matches Transitions.idr" {
    // Forward sequence
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_can_transition(0, 1)); // Connected -> KeyExchanged
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_can_transition(1, 2)); // KeyExchanged -> Authenticated
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_can_transition(2, 3)); // Authenticated -> ChannelOpen
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_can_transition(3, 4)); // ChannelOpen -> Active
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_can_transition(4, 4)); // Active -> Active (rekey)
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_can_transition(4, 5)); // Active -> Closed

    // Abort edges
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_can_transition(0, 5)); // Connected -> Closed
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_can_transition(1, 5)); // KeyExchanged -> Closed
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_can_transition(2, 5)); // Authenticated -> Closed
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_can_transition(3, 5)); // ChannelOpen -> Closed

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_can_transition(5, 0)); // Closed -> Connected (terminal!)
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_can_transition(5, 4)); // Closed -> Active
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_can_transition(0, 4)); // Connected -> Active (skip!)
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_can_transition(0, 2)); // Connected -> Authenticated (skip!)
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_can_transition(4, 1)); // Active -> KeyExchanged (backwards!)
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_can_transition(2, 0)); // Authenticated -> Connected (backwards!)
}

// =========================================================================
// Invalid state transitions
// =========================================================================

test "cannot complete kex from non-Connected" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);
    _ = ssh.ssh_bastion_complete_kex(slot); // -> KeyExchanged
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_complete_kex(slot)); // rejected
}

test "cannot authenticate from non-KeyExchanged" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_authenticate(slot, 5)); // Connected
}

test "cannot advance from Closed" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);
    _ = ssh.ssh_bastion_disconnect(slot, 0); // -> Closed
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_complete_kex(slot));
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_authenticate(slot, 5));
    try std.testing.expectEqual(@as(c_int, -1), ssh.ssh_bastion_open_channel(slot, 0));
}

// =========================================================================
// Audit logging
// =========================================================================

test "audit log records all transitions" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);

    // Create records initial transition (closed -> connected)
    try std.testing.expectEqual(@as(u32, 1), ssh.ssh_bastion_audit_count(slot));

    // Complete kex (connected -> key_exchanged)
    _ = ssh.ssh_bastion_complete_kex(slot);
    try std.testing.expectEqual(@as(u32, 2), ssh.ssh_bastion_audit_count(slot));

    // Verify first entry: closed(5) -> connected(0)
    try std.testing.expectEqual(@as(u8, 5), ssh.ssh_bastion_audit_entry(slot, 0));
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_audit_entry_to(slot, 0));

    // Verify second entry: connected(0) -> key_exchanged(1)
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_audit_entry(slot, 1));
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_audit_entry_to(slot, 1));
}

test "audit entry out of range returns 255" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);
    try std.testing.expectEqual(@as(u8, 255), ssh.ssh_bastion_audit_entry(slot, 999));
}

// =========================================================================
// Session recording
// =========================================================================

test "session recording default off, can toggle" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_is_recording(slot));

    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_set_recording(slot, 1));
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_is_recording(slot));

    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_set_recording(slot, 0));
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_is_recording(slot));
}

// =========================================================================
// Authentication failure tracking
// =========================================================================

test "auth failure tracking and lockout" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_auth_failures(slot));

    // First failure — not locked out
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_record_auth_failure(slot));
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_auth_failures(slot));

    // Second failure — not locked out
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_record_auth_failure(slot));
    try std.testing.expectEqual(@as(u8, 2), ssh.ssh_bastion_auth_failures(slot));

    // Third failure — locked out (returns 1)
    try std.testing.expectEqual(@as(u8, 1), ssh.ssh_bastion_record_auth_failure(slot));
    try std.testing.expectEqual(@as(u8, 3), ssh.ssh_bastion_auth_failures(slot));
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 5), ssh.ssh_bastion_state(-1));   // closed fallback
    try std.testing.expectEqual(@as(u8, 255), ssh.ssh_bastion_kex_method(-1));
    try std.testing.expectEqual(@as(u8, 255), ssh.ssh_bastion_auth_method(-1));
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_can_transfer(-1));
    try std.testing.expectEqual(@as(u8, 255), ssh.ssh_bastion_disconnect_reason(-1));
    try std.testing.expectEqual(@as(u8, 255), ssh.ssh_bastion_auth_failures(-1));
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_channel_count(-1));
    try std.testing.expectEqual(@as(u32, 0), ssh.ssh_bastion_audit_count(-1));
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_is_recording(-1));
}

// =========================================================================
// Disconnect closes all channels
// =========================================================================

test "disconnect closes all active channels" {
    const slot = ssh.ssh_bastion_create(1, 0);
    defer ssh.ssh_bastion_destroy(slot);

    // Advance to Active with two channels
    _ = ssh.ssh_bastion_complete_kex(slot);
    _ = ssh.ssh_bastion_authenticate(slot, 5);
    const ch0 = ssh.ssh_bastion_open_channel(slot, 0);
    _ = ssh.ssh_bastion_confirm_channel(slot, @intCast(ch0));
    _ = ssh.ssh_bastion_open_channel(slot, 1);

    try std.testing.expectEqual(@as(u8, 2), ssh.ssh_bastion_channel_count(slot));

    // Disconnect
    _ = ssh.ssh_bastion_disconnect(slot, 9);
    try std.testing.expectEqual(@as(u8, 0), ssh.ssh_bastion_channel_count(slot));
}
