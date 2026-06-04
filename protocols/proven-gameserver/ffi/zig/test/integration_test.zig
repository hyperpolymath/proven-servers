// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-gameserver FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Player management (join/leave/state)
//   - Game lifecycle (start/pause/resume/end)
//   - Game state tracking
//   - Shutdown / Cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const gs = @import("gameserver");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), gs.gs_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "PacketType encoding matches Types.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gs.PacketType.connect));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(gs.PacketType.disconnect));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(gs.PacketType.input));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(gs.PacketType.state_update));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(gs.PacketType.chat));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(gs.PacketType.ping));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(gs.PacketType.pong));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(gs.PacketType.sync));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(gs.PacketType.event));
}

test "PlayerState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gs.PlayerState.connecting));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(gs.PlayerState.lobby));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(gs.PlayerState.in_game));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(gs.PlayerState.spectating));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(gs.PlayerState.disconnected));
}

test "GameState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gs.GameState.waiting));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(gs.GameState.starting));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(gs.GameState.running));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(gs.GameState.paused));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(gs.GameState.ending));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(gs.GameState.finished));
}

test "SyncStrategy encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gs.SyncStrategy.lockstep));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(gs.SyncStrategy.rollback));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(gs.SyncStrategy.server_auth));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(gs.SyncStrategy.client_prediction));
}

test "DisconnectReason encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gs.DisconnectReason.timeout));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(gs.DisconnectReason.kicked));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(gs.DisconnectReason.quit));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(gs.DisconnectReason.err));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(gs.DisconnectReason.server_shutdown));
}

test "ServerState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(gs.ServerState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(gs.ServerState.lobby_state));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(gs.ServerState.running_state));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(gs.ServerState.paused_state));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(gs.ServerState.shutdown));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Lobby state" {
    const name = "test-game";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    try std.testing.expect(slot >= 0);
    defer gs.gs_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), gs.gs_state(slot)); // Lobby
    try std.testing.expectEqual(@as(u8, 0), gs.gs_game_state(slot)); // Waiting
}

test "create rejects empty name" {
    const name = "x";
    const slot = gs.gs_create(name.ptr, 0, 16, 2);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects invalid sync strategy" {
    const name = "badsync";
    const slot = gs.gs_create(name.ptr, name.len, 16, 99);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    gs.gs_destroy(-1);
    gs.gs_destroy(999);
}

// =========================================================================
// Player management
// =========================================================================

test "player_join adds player in Lobby state" {
    const name = "join-game";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    const pname = "Alice";
    try std.testing.expectEqual(@as(u8, 0), gs.gs_player_join(slot, pname.ptr, pname.len));
    try std.testing.expectEqual(@as(u16, 1), gs.gs_player_count(slot));
    try std.testing.expectEqual(@as(u8, 1), gs.gs_player_state(slot, 0)); // lobby
}

test "player_join rejects when full" {
    const name = "full-game";
    const slot = gs.gs_create(name.ptr, name.len, 1, 2); // max 1 player
    defer gs.gs_destroy(slot);

    const p1 = "Alice";
    _ = gs.gs_player_join(slot, p1.ptr, p1.len);
    const p2 = "Bob";
    try std.testing.expectEqual(@as(u8, 1), gs.gs_player_join(slot, p2.ptr, p2.len));
}

test "player_leave removes player" {
    const name = "leave-game";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    const pname = "Alice";
    _ = gs.gs_player_join(slot, pname.ptr, pname.len);
    try std.testing.expectEqual(@as(u8, 0), gs.gs_player_leave(slot, 0, 2)); // quit
    try std.testing.expectEqual(@as(u16, 0), gs.gs_player_count(slot));
}

test "player joins during Running gets Spectating state" {
    const name = "spec-game";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    const p1 = "Alice";
    _ = gs.gs_player_join(slot, p1.ptr, p1.len);
    _ = gs.gs_start_game(slot);

    const p2 = "Bob";
    _ = gs.gs_player_join(slot, p2.ptr, p2.len);
    try std.testing.expectEqual(@as(u8, 3), gs.gs_player_state(slot, 1)); // spectating
}

// =========================================================================
// Game lifecycle
// =========================================================================

test "start_game transitions Lobby -> Running" {
    const name = "start-game";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    const pname = "Alice";
    _ = gs.gs_player_join(slot, pname.ptr, pname.len);

    try std.testing.expectEqual(@as(u8, 0), gs.gs_start_game(slot));
    try std.testing.expectEqual(@as(u8, 2), gs.gs_state(slot)); // Running
    try std.testing.expectEqual(@as(u8, 2), gs.gs_game_state(slot)); // Running
    try std.testing.expectEqual(@as(u8, 2), gs.gs_player_state(slot, 0)); // in_game
}

test "pause_game transitions Running -> Paused" {
    const name = "pause-game";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    _ = gs.gs_start_game(slot);
    try std.testing.expectEqual(@as(u8, 0), gs.gs_pause_game(slot));
    try std.testing.expectEqual(@as(u8, 3), gs.gs_state(slot)); // Paused
    try std.testing.expectEqual(@as(u8, 3), gs.gs_game_state(slot)); // Paused
}

test "resume_game transitions Paused -> Running" {
    const name = "resume-game";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    _ = gs.gs_start_game(slot);
    _ = gs.gs_pause_game(slot);
    try std.testing.expectEqual(@as(u8, 0), gs.gs_resume_game(slot));
    try std.testing.expectEqual(@as(u8, 2), gs.gs_state(slot)); // Running
}

test "end_game transitions Running -> Lobby" {
    const name = "end-game";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    const pname = "Alice";
    _ = gs.gs_player_join(slot, pname.ptr, pname.len);
    _ = gs.gs_start_game(slot);
    try std.testing.expectEqual(@as(u8, 0), gs.gs_end_game(slot));
    try std.testing.expectEqual(@as(u8, 1), gs.gs_state(slot)); // Lobby
    try std.testing.expectEqual(@as(u8, 5), gs.gs_game_state(slot)); // Finished
    try std.testing.expectEqual(@as(u8, 1), gs.gs_player_state(slot, 0)); // back to lobby
}

test "start_game rejects from non-Lobby" {
    const name = "badstart";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    _ = gs.gs_start_game(slot);
    try std.testing.expectEqual(@as(u8, 1), gs.gs_start_game(slot)); // already running
}

test "pause_game rejects from non-Running" {
    const name = "badpause";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), gs.gs_pause_game(slot)); // Lobby, not Running
}

test "resume_game rejects from non-Paused" {
    const name = "badresume";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), gs.gs_resume_game(slot)); // Lobby, not Paused
}

// =========================================================================
// Shutdown / Cleanup
// =========================================================================

test "shutdown transitions Lobby -> Shutdown" {
    const name = "shutdown-game";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), gs.gs_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 4), gs.gs_state(slot)); // Shutdown
}

test "shutdown from Running" {
    const name = "runshut";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    _ = gs.gs_start_game(slot);
    try std.testing.expectEqual(@as(u8, 0), gs.gs_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 4), gs.gs_state(slot));
}

test "cleanup transitions Shutdown -> Idle" {
    const name = "cleanup-game";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    _ = gs.gs_shutdown(slot);
    try std.testing.expectEqual(@as(u8, 0), gs.gs_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), gs.gs_state(slot)); // Idle
}

test "cleanup clears players" {
    const name = "clearcleanup";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    const pname = "Alice";
    _ = gs.gs_player_join(slot, pname.ptr, pname.len);
    _ = gs.gs_shutdown(slot);
    _ = gs.gs_cleanup(slot);
    try std.testing.expectEqual(@as(u16, 0), gs.gs_player_count(slot));
}

test "cleanup rejected from non-Shutdown state" {
    const name = "badcleanup";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), gs.gs_cleanup(slot));
}

test "shutdown rejected from Idle" {
    const name = "idleshut";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    _ = gs.gs_shutdown(slot);
    _ = gs.gs_cleanup(slot);
    try std.testing.expectEqual(@as(u8, 1), gs.gs_shutdown(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "gs_can_transition matches Types.idr transitions" {
    try std.testing.expectEqual(@as(u8, 1), gs.gs_can_transition(0, 1)); // Idle -> Lobby
    try std.testing.expectEqual(@as(u8, 1), gs.gs_can_transition(1, 2)); // Lobby -> Running
    try std.testing.expectEqual(@as(u8, 1), gs.gs_can_transition(2, 3)); // Running -> Paused
    try std.testing.expectEqual(@as(u8, 1), gs.gs_can_transition(3, 2)); // Paused -> Running
    try std.testing.expectEqual(@as(u8, 1), gs.gs_can_transition(2, 1)); // Running -> Lobby
    try std.testing.expectEqual(@as(u8, 1), gs.gs_can_transition(1, 4)); // Lobby -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), gs.gs_can_transition(2, 4)); // Running -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), gs.gs_can_transition(3, 4)); // Paused -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), gs.gs_can_transition(4, 0)); // Shutdown -> Idle

    try std.testing.expectEqual(@as(u8, 0), gs.gs_can_transition(0, 2)); // Idle -/-> Running
    try std.testing.expectEqual(@as(u8, 0), gs.gs_can_transition(4, 1)); // Shutdown -/-> Lobby
    try std.testing.expectEqual(@as(u8, 0), gs.gs_can_transition(0, 4)); // Idle -/-> Shutdown
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), gs.gs_state(-1));
    try std.testing.expectEqual(@as(u8, 0), gs.gs_game_state(-1));
    try std.testing.expectEqual(@as(u16, 0), gs.gs_player_count(-1));
    try std.testing.expectEqual(@as(u8, 1), gs.gs_shutdown(-1));
    try std.testing.expectEqual(@as(u8, 1), gs.gs_cleanup(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot start game from Idle" {
    const name = "idlestart";
    const slot = gs.gs_create(name.ptr, name.len, 16, 2);
    defer gs.gs_destroy(slot);

    _ = gs.gs_shutdown(slot);
    _ = gs.gs_cleanup(slot);
    try std.testing.expectEqual(@as(u8, 1), gs.gs_start_game(slot));
}
