// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-ssh-bastion FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const ssh_bastion = @import("ssh_bastion");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ssh_bastion.ssh_bastion_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "SshMessageType encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh_bastion.SshMessageType.kexinit));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ssh_bastion.SshMessageType.newkeys));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ssh_bastion.SshMessageType.service_request));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ssh_bastion.SshMessageType.userauth_request));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ssh_bastion.SshMessageType.channel_open));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ssh_bastion.SshMessageType.channel_data));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ssh_bastion.SshMessageType.channel_close));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(ssh_bastion.SshMessageType.disconnect));
}

test "AuthMethod encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh_bastion.AuthMethod.publickey));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ssh_bastion.AuthMethod.password));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ssh_bastion.AuthMethod.keyboard_interactive));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ssh_bastion.AuthMethod.auth_none));
}

test "KexMethod encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh_bastion.KexMethod.diffie_hellman_group14_sha256));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ssh_bastion.KexMethod.curve25519_sha256));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ssh_bastion.KexMethod.diffie_hellman_group16_sha512));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ssh_bastion.KexMethod.diffie_hellman_group18_sha512));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ssh_bastion.KexMethod.ecdh_sha2_nistp256));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ssh_bastion.KexMethod.ecdh_sha2_nistp384));
}

test "ChannelType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh_bastion.ChannelType.session));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ssh_bastion.ChannelType.direct_tcpip));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ssh_bastion.ChannelType.forwarded_tcpip));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ssh_bastion.ChannelType.x11));
}

test "BastionState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh_bastion.BastionState.connected));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ssh_bastion.BastionState.key_exchanged));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ssh_bastion.BastionState.authenticated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ssh_bastion.BastionState.channel_open));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ssh_bastion.BastionState.active));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ssh_bastion.BastionState.closed));
}

test "ChannelState encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh_bastion.ChannelState.opening));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ssh_bastion.ChannelState.open));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ssh_bastion.ChannelState.closing));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ssh_bastion.ChannelState.closed));
}

test "DisconnectReason encoding matches Types.idr (12 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh_bastion.DisconnectReason.host_not_allowed));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ssh_bastion.DisconnectReason.protocol_error));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ssh_bastion.DisconnectReason.key_exchange_failed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ssh_bastion.DisconnectReason.host_auth_failed));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ssh_bastion.DisconnectReason.mac_error));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ssh_bastion.DisconnectReason.service_not_available));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ssh_bastion.DisconnectReason.version_not_supported));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(ssh_bastion.DisconnectReason.host_key_not_verifiable));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(ssh_bastion.DisconnectReason.connection_lost));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(ssh_bastion.DisconnectReason.by_application));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(ssh_bastion.DisconnectReason.too_many_connections));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(ssh_bastion.DisconnectReason.auth_cancelled));
}

test "HostKeyAlgorithm encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh_bastion.HostKeyAlgorithm.ssh_ed25519));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ssh_bastion.HostKeyAlgorithm.rsa_sha2_256));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ssh_bastion.HostKeyAlgorithm.rsa_sha2_512));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ssh_bastion.HostKeyAlgorithm.ecdsa_nistp256));
}

test "CipherAlgorithm encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh_bastion.CipherAlgorithm.chacha20_poly1305));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ssh_bastion.CipherAlgorithm.aes256_gcm));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ssh_bastion.CipherAlgorithm.aes128_gcm));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ssh_bastion.CipherAlgorithm.aes256_ctr));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ssh_bastion.CipherAlgorithm.aes192_ctr));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ssh_bastion.CipherAlgorithm.aes128_ctr));
}

test "ChannelOpenFailure encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ssh_bastion.ChannelOpenFailure.admin_prohibited));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ssh_bastion.ChannelOpenFailure.connect_failed));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ssh_bastion.ChannelOpenFailure.unknown_channel_type));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ssh_bastion.ChannelOpenFailure.resource_shortage));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = ssh_bastion.ssh_bastion_create(0, 0);
    try std.testing.expect(slot >= 0);
    defer ssh_bastion.ssh_bastion_destroy(slot);
    const state = ssh_bastion.ssh_bastion_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    ssh_bastion.ssh_bastion_destroy(-1);
    ssh_bastion.ssh_bastion_destroy(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), ssh_bastion.ssh_bastion_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), ssh_bastion.ssh_bastion_can_transition(0, 0)); // self-loop
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = ssh_bastion.ssh_bastion_state(-1);
    _ = ssh_bastion.ssh_bastion_channel_count(-1);
    _ = ssh_bastion.ssh_bastion_audit_count(-1);
    _ = ssh_bastion.ssh_bastion_is_recording(-1);
}

