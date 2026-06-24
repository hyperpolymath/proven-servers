// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// gameserver.zig -- Zig FFI implementation of proven-gameserver.
//
// Implements the game server session state machine with:
//   - 64-slot mutex-protected session pool
//   - Player management (connect/disconnect/state tracking)
//   - Game state lifecycle (lobby -> running -> paused -> ended)
//   - Sync strategy configuration
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching GameserverABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching GameserverABI.Types.idr tag assignments)
// =========================================================================

/// Packet types (ABI tags 0-8).
pub const PacketType = enum(u8) {
    connect = 0,
    disconnect = 1,
    input = 2,
    state_update = 3,
    chat = 4,
    ping = 5,
    pong = 6,
    sync = 7,
    event = 8,
};

/// Player states (ABI tags 0-4).
pub const PlayerState = enum(u8) {
    connecting = 0,
    lobby = 1,
    in_game = 2,
    spectating = 3,
    disconnected = 4,
};

/// Game states (ABI tags 0-5).
pub const GameState = enum(u8) {
    waiting = 0,
    starting = 1,
    running = 2,
    paused = 3,
    ending = 4,
    finished = 5,
};

/// Sync strategies (ABI tags 0-3).
pub const SyncStrategy = enum(u8) {
    lockstep = 0,
    rollback = 1,
    server_auth = 2,
    client_prediction = 3,
};

/// Disconnect reasons (ABI tags 0-4).
pub const DisconnectReason = enum(u8) {
    timeout = 0,
    kicked = 1,
    quit = 2,
    err = 3,
    server_shutdown = 4,
};

/// Server lifecycle states (ABI tags 0-4).
pub const ServerState = enum(u8) {
    idle = 0,
    lobby_state = 1,
    running_state = 2,
    paused_state = 3,
    shutdown = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

const MAX_SESSIONS: usize = 64;
const MAX_NAME_LEN: usize = 256;
const MAX_PLAYERS: usize = 64;

/// A player entry.
const Player = struct {
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    state: PlayerState,
    active: bool,
};

const empty_player: Player = .{
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .state = .connecting,
    .active = false,
};

/// A game server session.
const Session = struct {
    state: ServerState,
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    max_players: u16,
    sync_strategy: SyncStrategy,
    game_state: GameState,
    players: [MAX_PLAYERS]Player,
    player_count: u16,
    active: bool,
};

const empty_session: Session = .{
    .state = .idle,
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .max_players = MAX_PLAYERS,
    .sync_strategy = .server_auth,
    .game_state = .waiting,
    .players = [_]Player{empty_player} ** MAX_PLAYERS,
    .player_count = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

pub export fn gs_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new game server session. Returns slot (>=0) or -1.
/// Starts in Lobby state.
pub export fn gs_create(
    name_ptr: [*]const u8,
    name_len: u32,
    max_players: u16,
    sync: u8,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (name_len == 0 or name_len > MAX_NAME_LEN) return -1;
    if (sync > 3) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.name[0..name_len], name_ptr[0..name_len]);
            s.name_len = name_len;
            s.max_players = if (max_players == 0 or max_players > MAX_PLAYERS) MAX_PLAYERS else max_players;
            s.sync_strategy = @enumFromInt(sync);
            s.state = .lobby_state;
            s.game_state = .waiting;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn gs_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

pub export fn gs_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

pub export fn gs_game_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].game_state);
}

// -- Player management ----------------------------------------------------

/// Add a player. Returns 0 on success, 1 on rejection.
pub export fn gs_player_join(
    slot: c_int,
    name_ptr: [*]const u8,
    name_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .lobby_state and state != .running_state) return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (sessions[idx].player_count >= sessions[idx].max_players) return 1;

    for (&sessions[idx].players) |*p| {
        if (!p.active) {
            @memcpy(p.name[0..name_len], name_ptr[0..name_len]);
            p.name_len = name_len;
            p.state = if (state == .running_state) .spectating else .lobby;
            p.active = true;
            sessions[idx].player_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Remove a player. Returns 0 on success, 1 on rejection.
pub export fn gs_player_leave(
    slot: c_int,
    player_idx: u16,
    reason: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = reason;

    const idx = validSlot(slot) orelse return 1;
    if (player_idx >= MAX_PLAYERS) return 1;

    // Find the active player by index
    var count: u16 = 0;
    for (&sessions[idx].players) |*p| {
        if (p.active) {
            if (count == player_idx) {
                p.state = .disconnected;
                p.active = false;
                sessions[idx].player_count -= 1;
                return 0;
            }
            count += 1;
        }
    }
    return 1;
}

pub export fn gs_player_count(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].player_count;
}

/// Get player state. Returns PlayerState tag.
pub export fn gs_player_state(slot: c_int, player_idx: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(PlayerState.disconnected);
    if (player_idx >= MAX_PLAYERS) return @intFromEnum(PlayerState.disconnected);

    var count: u16 = 0;
    for (&sessions[idx].players) |*p| {
        if (p.active) {
            if (count == player_idx) {
                return @intFromEnum(p.state);
            }
            count += 1;
        }
    }
    return @intFromEnum(PlayerState.disconnected);
}

// -- Game lifecycle -------------------------------------------------------

/// Start the game. Transitions Lobby -> Running.
pub export fn gs_start_game(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .lobby_state) return 1;

    sessions[idx].state = .running_state;
    sessions[idx].game_state = .running;

    // Move lobby players to InGame
    for (&sessions[idx].players) |*p| {
        if (p.active and p.state == .lobby) {
            p.state = .in_game;
        }
    }

    return 0;
}

/// Pause the game. Transitions Running -> Paused.
pub export fn gs_pause_game(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .running_state) return 1;

    sessions[idx].state = .paused_state;
    sessions[idx].game_state = .paused;
    return 0;
}

/// Resume the game. Transitions Paused -> Running.
pub export fn gs_resume_game(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .paused_state) return 1;

    sessions[idx].state = .running_state;
    sessions[idx].game_state = .running;
    return 0;
}

/// End the game. Transitions Running -> Lobby.
pub export fn gs_end_game(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .running_state) return 1;

    sessions[idx].state = .lobby_state;
    sessions[idx].game_state = .finished;

    // Move InGame players back to Lobby
    for (&sessions[idx].players) |*p| {
        if (p.active and (p.state == .in_game or p.state == .spectating)) {
            p.state = .lobby;
        }
    }

    return 0;
}

// -- Shutdown / Cleanup ---------------------------------------------------

pub export fn gs_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .lobby_state or state == .running_state or state == .paused_state) {
        sessions[idx].state = .shutdown;
        return 0;
    }
    return 1;
}

pub export fn gs_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .shutdown) return 1;

    sessions[idx].state = .idle;
    sessions[idx].game_state = .waiting;
    sessions[idx].players = [_]Player{empty_player} ** MAX_PLAYERS;
    sessions[idx].player_count = 0;

    return 0;
}

// -- Stateless transition table -------------------------------------------

pub export fn gs_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Lobby
    if (from == 1 and to == 2) return 1; // Lobby -> Running
    if (from == 2 and to == 3) return 1; // Running -> Paused
    if (from == 3 and to == 2) return 1; // Paused -> Running
    if (from == 2 and to == 1) return 1; // Running -> Lobby (game ended)
    if (from == 1 and to == 4) return 1; // Lobby -> Shutdown
    if (from == 2 and to == 4) return 1; // Running -> Shutdown
    if (from == 3 and to == 4) return 1; // Paused -> Shutdown
    if (from == 4 and to == 0) return 1; // Shutdown -> Idle
    return 0;
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
