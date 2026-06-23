// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// media.zig -- Zig FFI implementation of proven-media.
//
// Implements the media streaming server state machine with:
//   - 64-slot mutex-protected player session pool
//   - Per-session stream metadata (codec, protocol, profile)
//   - Per-session event counter
//   - Playback lifecycle (load/play/pause/seek/stop)
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching abi.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching abi.Types.idr tag assignments)
// =========================================================================

/// Media types (ABI tags 0-4).
pub const MediaType = enum(u8) {
    audio = 0,
    video = 1,
    live_stream = 2,
    playlist = 3,
    subtitle = 4,
};

/// Audio/video codecs (ABI tags 0-7).
pub const Codec = enum(u8) {
    h264 = 0,
    h265 = 1,
    av1 = 2,
    vp9 = 3,
    aac = 4,
    opus = 5,
    flac = 6,
    mp3 = 7,
};

/// Streaming transport protocols (ABI tags 0-5).
pub const StreamProtocol = enum(u8) {
    hls = 0,
    dash = 1,
    rtmp = 2,
    rtsp = 3,
    webrtc = 4,
    srt = 5,
};

/// Transcoding quality presets (ABI tags 0-4).
pub const TranscodeProfile = enum(u8) {
    passthrough = 0,
    low = 1,
    medium = 2,
    high = 3,
    ultra = 4,
};

/// Player events (ABI tags 0-7).
pub const PlayerEvent = enum(u8) {
    play = 0,
    pause = 1,
    seek = 2,
    stop = 3,
    buffer_start = 4,
    buffer_end = 5,
    err = 6,
    quality_change = 7,
};

/// Player session lifecycle states (ABI tags 0-4).
pub const PlayerState = enum(u8) {
    idle = 0,
    ready = 1,
    playing = 2,
    paused = 3,
    stopping = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum URL length.
const MAX_URL_LEN: usize = 512;

/// A media player session.
const Session = struct {
    /// Current player lifecycle state.
    state: PlayerState,
    /// Streaming protocol.
    protocol: StreamProtocol,
    /// Transcoding profile.
    profile: TranscodeProfile,
    /// Media type of currently loaded resource.
    media_type: MediaType,
    /// Codec of currently loaded resource.
    codec: Codec,
    /// Stream URL.
    url: [MAX_URL_LEN]u8,
    url_len: u32,
    /// Current playback position in milliseconds.
    position_ms: u64,
    /// Total event count for this session.
    event_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .protocol = .hls,
    .profile = .passthrough,
    .media_type = .audio,
    .codec = .h264,
    .url = [_]u8{0} ** MAX_URL_LEN,
    .url_len = 0,
    .position_ms = 0,
    .event_count = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

/// Returns the ABI version number.
pub export fn media_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new media player session. Returns slot index (>=0) or -1 on failure.
pub export fn media_create(protocol: u8, profile: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (protocol > 5) return -1;
    if (profile > 4) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.protocol = @enumFromInt(protocol);
            s.profile = @enumFromInt(profile);
            s.state = .idle;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn media_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current PlayerState tag.
pub export fn media_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Load a media resource. Transitions Idle -> Ready.
pub export fn media_load(
    slot: c_int,
    url_ptr: [*]const u8,
    url_len: u32,
    media_type: u8,
    codec: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .idle) return 1;
    if (url_len == 0 or url_len > MAX_URL_LEN) return 1;
    if (media_type > 4) return 1;
    if (codec > 7) return 1;

    @memcpy(sessions[idx].url[0..url_len], url_ptr[0..url_len]);
    sessions[idx].url_len = url_len;
    sessions[idx].media_type = @enumFromInt(media_type);
    sessions[idx].codec = @enumFromInt(codec);
    sessions[idx].position_ms = 0;
    sessions[idx].state = .ready;
    sessions[idx].event_count += 1;
    return 0;
}

/// Start playback. Transitions Ready/Paused -> Playing.
pub export fn media_play(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .ready and state != .paused) return 1;

    sessions[idx].state = .playing;
    sessions[idx].event_count += 1;
    return 0;
}

/// Pause playback. Transitions Playing -> Paused.
pub export fn media_pause(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .playing) return 1;

    sessions[idx].state = .paused;
    sessions[idx].event_count += 1;
    return 0;
}

/// Seek to a position. Valid from Playing or Paused.
pub export fn media_seek(slot: c_int, position_ms: u64) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .playing and state != .paused) return 1;

    sessions[idx].position_ms = position_ms;
    sessions[idx].event_count += 1;
    return 0;
}

/// Stop playback. Transitions to Stopping.
pub export fn media_stop(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .ready or state == .playing or state == .paused) {
        sessions[idx].state = .stopping;
        sessions[idx].event_count += 1;
        return 0;
    }
    return 1;
}

/// Cleanup after stop. Transitions Stopping -> Idle.
pub export fn media_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .stopping) return 1;

    sessions[idx].state = .idle;
    sessions[idx].url_len = 0;
    sessions[idx].position_ms = 0;
    return 0;
}

/// Set transcoding profile.
pub export fn media_set_profile(slot: c_int, profile: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (profile > 4) return 1;

    sessions[idx].profile = @enumFromInt(profile);
    sessions[idx].event_count += 1;
    return 0;
}

/// Returns the current transcoding profile tag.
pub export fn media_get_profile(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].profile);
}

/// Returns the current codec tag.
pub export fn media_get_codec(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].codec);
}

/// Returns the current streaming protocol tag.
pub export fn media_get_protocol(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].protocol);
}

/// Returns the total event count for this session.
pub export fn media_event_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].event_count;
}

/// Check if a player state transition is valid.
pub export fn media_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Ready
    if (from == 1 and to == 2) return 1; // Ready -> Playing
    if (from == 2 and to == 3) return 1; // Playing -> Paused
    if (from == 3 and to == 2) return 1; // Paused -> Playing
    if (from == 1 and to == 4) return 1; // Ready -> Stopping
    if (from == 2 and to == 4) return 1; // Playing -> Stopping
    if (from == 3 and to == 4) return 1; // Paused -> Stopping
    if (from == 4 and to == 0) return 1; // Stopping -> Idle
    return 0;
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
