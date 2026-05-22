// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Media protocol types for proven-servers.
// All tag values match the Idris2 ABI discriminants exactly.
package proven

// MediaContentType represents the MediaContentType type (Idris2 ABI tags).
type MediaContentType uint8

const (
	MediaContentTypeAudio MediaContentType = iota
	MediaContentTypeVideo
	MediaContentTypeLiveStream
	MediaContentTypePlaylist
	MediaContentTypeSubtitle
)

// Codec represents the Codec type (Idris2 ABI tags).
type Codec uint8

const (
	CodecH264 Codec = iota
	CodecH265
	CodecAv1
	CodecVp9
	CodecAac
	CodecOpus
	CodecFlac
	CodecMp3
)

// StreamProtocol represents the StreamProtocol type (Idris2 ABI tags).
type StreamProtocol uint8

const (
	StreamProtocolHls StreamProtocol = iota
	StreamProtocolDash
	StreamProtocolRtmp
	StreamProtocolRtsp
	StreamProtocolWebRtc
	StreamProtocolSrt
)

// TranscodeProfile represents the TranscodeProfile type (Idris2 ABI tags).
type TranscodeProfile uint8

const (
	TranscodeProfilePassthrough TranscodeProfile = iota
	TranscodeProfileLow
	TranscodeProfileMedium
	TranscodeProfileHigh
	TranscodeProfileUltra
)

// PlayerEvent represents the PlayerEvent type (Idris2 ABI tags).
type PlayerEvent uint8

const (
	PlayerEventPlay PlayerEvent = iota
	PlayerEventPause
	PlayerEventSeek
	PlayerEventStop
	PlayerEventBufferStart
	PlayerEventBufferEnd
	PlayerEventError
	PlayerEventQualityChange
)

// PlayerState represents the PlayerState type (Idris2 ABI tags).
type PlayerState uint8

const (
	PlayerStateIdle PlayerState = iota
	PlayerStateReady
	PlayerStatePlaying
	PlayerStatePaused
	PlayerStateStopping
)
