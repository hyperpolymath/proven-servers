// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-media FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Player lifecycle (create/destroy)
//   - Load media (Idle -> Ready)
//   - Play/Pause/Seek lifecycle
//   - Stop / Cleanup
//   - Profile and codec management
//   - Event counting
//   - Stateless player transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const media = @import("media");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), media.media_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "MediaType encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(media.MediaType.audio));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(media.MediaType.video));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(media.MediaType.live_stream));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(media.MediaType.playlist));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(media.MediaType.subtitle));
}

test "Codec encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(media.Codec.h264));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(media.Codec.h265));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(media.Codec.av1));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(media.Codec.vp9));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(media.Codec.aac));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(media.Codec.opus));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(media.Codec.flac));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(media.Codec.mp3));
}

test "StreamProtocol encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(media.StreamProtocol.hls));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(media.StreamProtocol.dash));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(media.StreamProtocol.rtmp));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(media.StreamProtocol.rtsp));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(media.StreamProtocol.webrtc));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(media.StreamProtocol.srt));
}

test "TranscodeProfile encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(media.TranscodeProfile.passthrough));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(media.TranscodeProfile.low));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(media.TranscodeProfile.medium));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(media.TranscodeProfile.high));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(media.TranscodeProfile.ultra));
}

test "PlayerEvent encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(media.PlayerEvent.play));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(media.PlayerEvent.pause));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(media.PlayerEvent.seek));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(media.PlayerEvent.stop));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(media.PlayerEvent.buffer_start));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(media.PlayerEvent.buffer_end));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(media.PlayerEvent.err));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(media.PlayerEvent.quality_change));
}

test "PlayerState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(media.PlayerState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(media.PlayerState.ready));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(media.PlayerState.playing));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(media.PlayerState.paused));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(media.PlayerState.stopping));
}

// =========================================================================
// Player lifecycle
// =========================================================================

test "create returns valid slot in Idle state" {
    const slot = media.media_create(0, 0); // HLS, Passthrough
    try std.testing.expect(slot >= 0);
    defer media.media_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), media.media_state(slot)); // Idle
}

test "create rejects invalid protocol" {
    try std.testing.expectEqual(@as(c_int, -1), media.media_create(99, 0));
}

test "create rejects invalid profile" {
    try std.testing.expectEqual(@as(c_int, -1), media.media_create(0, 99));
}

test "destroy is safe with invalid slot" {
    media.media_destroy(-1);
    media.media_destroy(999);
}

// =========================================================================
// Load media
// =========================================================================

test "load transitions Idle -> Ready" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    const url = "https://example.com/stream.m3u8";
    try std.testing.expectEqual(@as(u8, 0), media.media_load(slot, url.ptr, url.len, 1, 0));
    try std.testing.expectEqual(@as(u8, 1), media.media_state(slot)); // Ready
}

test "load rejects empty URL" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    const url = "x";
    try std.testing.expectEqual(@as(u8, 1), media.media_load(slot, url.ptr, 0, 0, 0));
}

test "load rejects invalid media type" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    const url = "https://example.com/file.mp4";
    try std.testing.expectEqual(@as(u8, 1), media.media_load(slot, url.ptr, url.len, 99, 0));
}

test "load rejected from non-Idle state" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    const url = "https://example.com/a.mp4";
    _ = media.media_load(slot, url.ptr, url.len, 1, 0);
    try std.testing.expectEqual(@as(u8, 1), media.media_load(slot, url.ptr, url.len, 1, 0));
}

// =========================================================================
// Play / Pause / Seek
// =========================================================================

test "play transitions Ready -> Playing" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    const url = "https://example.com/a.mp4";
    _ = media.media_load(slot, url.ptr, url.len, 1, 0);

    try std.testing.expectEqual(@as(u8, 0), media.media_play(slot));
    try std.testing.expectEqual(@as(u8, 2), media.media_state(slot)); // Playing
}

test "pause transitions Playing -> Paused" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    const url = "https://example.com/a.mp4";
    _ = media.media_load(slot, url.ptr, url.len, 1, 0);
    _ = media.media_play(slot);

    try std.testing.expectEqual(@as(u8, 0), media.media_pause(slot));
    try std.testing.expectEqual(@as(u8, 3), media.media_state(slot)); // Paused
}

test "play from Paused transitions back to Playing" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    const url = "https://example.com/a.mp4";
    _ = media.media_load(slot, url.ptr, url.len, 1, 0);
    _ = media.media_play(slot);
    _ = media.media_pause(slot);

    try std.testing.expectEqual(@as(u8, 0), media.media_play(slot));
    try std.testing.expectEqual(@as(u8, 2), media.media_state(slot)); // Playing
}

test "seek from Playing updates position" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    const url = "https://example.com/a.mp4";
    _ = media.media_load(slot, url.ptr, url.len, 1, 0);
    _ = media.media_play(slot);

    try std.testing.expectEqual(@as(u8, 0), media.media_seek(slot, 30000));
}

test "seek rejected from Idle" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), media.media_seek(slot, 0));
}

// =========================================================================
// Stop / Cleanup
// =========================================================================

test "stop transitions Playing -> Stopping" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    const url = "https://example.com/a.mp4";
    _ = media.media_load(slot, url.ptr, url.len, 1, 0);
    _ = media.media_play(slot);

    try std.testing.expectEqual(@as(u8, 0), media.media_stop(slot));
    try std.testing.expectEqual(@as(u8, 4), media.media_state(slot)); // Stopping
}

test "cleanup transitions Stopping -> Idle" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    const url = "https://example.com/a.mp4";
    _ = media.media_load(slot, url.ptr, url.len, 1, 0);
    _ = media.media_play(slot);
    _ = media.media_stop(slot);

    try std.testing.expectEqual(@as(u8, 0), media.media_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), media.media_state(slot)); // Idle
}

test "cleanup rejected from non-Stopping" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), media.media_cleanup(slot));
}

// =========================================================================
// Profile and codec management
// =========================================================================

test "set_profile and get_profile" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), media.media_set_profile(slot, 3)); // High
    try std.testing.expectEqual(@as(u8, 3), media.media_get_profile(slot));
}

test "get_codec returns loaded codec" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    const url = "https://example.com/a.mp4";
    _ = media.media_load(slot, url.ptr, url.len, 1, 5); // Video, Opus
    try std.testing.expectEqual(@as(u8, 5), media.media_get_codec(slot));
}

test "get_protocol returns session protocol" {
    const slot = media.media_create(4, 0); // WebRTC
    defer media.media_destroy(slot);

    try std.testing.expectEqual(@as(u8, 4), media.media_get_protocol(slot));
}

// =========================================================================
// Event counting
// =========================================================================

test "event_count increments with operations" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    const url = "https://example.com/a.mp4";
    _ = media.media_load(slot, url.ptr, url.len, 1, 0);
    _ = media.media_play(slot);
    _ = media.media_pause(slot);
    try std.testing.expectEqual(@as(u32, 3), media.media_event_count(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "media_can_transition matches state machine" {
    // Valid
    try std.testing.expectEqual(@as(u8, 1), media.media_can_transition(0, 1)); // Idle -> Ready
    try std.testing.expectEqual(@as(u8, 1), media.media_can_transition(1, 2)); // Ready -> Playing
    try std.testing.expectEqual(@as(u8, 1), media.media_can_transition(2, 3)); // Playing -> Paused
    try std.testing.expectEqual(@as(u8, 1), media.media_can_transition(3, 2)); // Paused -> Playing
    try std.testing.expectEqual(@as(u8, 1), media.media_can_transition(1, 4)); // Ready -> Stopping
    try std.testing.expectEqual(@as(u8, 1), media.media_can_transition(2, 4)); // Playing -> Stopping
    try std.testing.expectEqual(@as(u8, 1), media.media_can_transition(3, 4)); // Paused -> Stopping
    try std.testing.expectEqual(@as(u8, 1), media.media_can_transition(4, 0)); // Stopping -> Idle

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), media.media_can_transition(0, 2)); // Idle -/-> Playing
    try std.testing.expectEqual(@as(u8, 0), media.media_can_transition(0, 3)); // Idle -/-> Paused
    try std.testing.expectEqual(@as(u8, 0), media.media_can_transition(4, 2)); // Stopping -/-> Playing
    try std.testing.expectEqual(@as(u8, 0), media.media_can_transition(0, 4)); // Idle -/-> Stopping
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), media.media_state(-1));
    try std.testing.expectEqual(@as(u32, 0), media.media_event_count(-1));
    try std.testing.expectEqual(@as(u8, 0), media.media_get_profile(-1));
    try std.testing.expectEqual(@as(u8, 0), media.media_get_codec(-1));
    try std.testing.expectEqual(@as(u8, 0), media.media_get_protocol(-1));
    try std.testing.expectEqual(@as(u8, 1), media.media_stop(-1));
    try std.testing.expectEqual(@as(u8, 1), media.media_cleanup(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot play from Idle" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), media.media_play(slot));
}

test "cannot pause from Ready" {
    const slot = media.media_create(0, 0);
    defer media.media_destroy(slot);

    const url = "https://example.com/a.mp4";
    _ = media.media_load(slot, url.ptr, url.len, 1, 0);

    try std.testing.expectEqual(@as(u8, 1), media.media_pause(slot));
}
