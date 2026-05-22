# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-media protocol (Media streaming server).
#
# Wraps the C-ABI functions from protocols/proven-media/ffi/zig/src/media.zig
# via ccall into libproven_media.so.

module Media

using ..ProvenServers: check_status, check_slot, SlotId

export MediaContentType,
       Codec,
       StreamProtocol,
       TranscodeProfile,
       PlayerEvent,
       PlayerState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_media"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Media content types."""
@enum MediaContentType::UInt8 begin
    CONTENT_AUDIO = 0
    CONTENT_VIDEO = 1
    CONTENT_LIVE_STREAM = 2
    CONTENT_PLAYLIST = 3
    CONTENT_SUBTITLE = 4
end

"""Media codecs."""
@enum Codec::UInt8 begin
    CODEC_H264 = 0
    CODEC_H265 = 1
    CODEC_AV1 = 2
    CODEC_VP9 = 3
    CODEC_AAC = 4
    CODEC_OPUS = 5
    CODEC_FLAC = 6
    CODEC_MP3 = 7
end

"""Media streaming protocols."""
@enum StreamProtocol::UInt8 begin
    STREAM_HLS = 0
    STREAM_DASH = 1
    STREAM_RTMP = 2
    STREAM_RTSP = 3
    STREAM_WEBRTC = 4
    STREAM_SRT = 5
end

"""Transcoding quality profiles."""
@enum TranscodeProfile::UInt8 begin
    PROFILE_PASSTHROUGH = 0
    PROFILE_LOW = 1
    PROFILE_MEDIUM = 2
    PROFILE_HIGH = 3
    PROFILE_ULTRA = 4
end

"""Media player events."""
@enum PlayerEvent::UInt8 begin
    EVENT_PLAY = 0
    EVENT_PAUSE = 1
    EVENT_SEEK = 2
    EVENT_STOP = 3
    EVENT_BUFFER_START = 4
    EVENT_BUFFER_END = 5
    EVENT_ERROR = 6
    EVENT_QUALITY_CHANGE = 7
end

"""Media player states."""
@enum PlayerState::UInt8 begin
    STATE_IDLE = 0
    STATE_READY = 1
    STATE_PLAYING = 2
    STATE_PAUSED = 3
    STATE_STOPPING = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_media."""
function abi_version()::UInt32
    ccall((:media_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Media context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:media_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Media context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:media_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> PlayerState

Get the current Media lifecycle state.
"""
function get_state(slot::SlotId)::PlayerState
    PlayerState(ccall((:media_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::PlayerState, to::PlayerState) -> Bool

Check whether a Media state transition is valid.
"""
function can_transition(from::PlayerState, to::PlayerState)::Bool
    ccall((:media_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Media
