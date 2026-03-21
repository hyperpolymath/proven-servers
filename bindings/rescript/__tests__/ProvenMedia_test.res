// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenMedia protocol bindings.

open ProvenMedia

let test_mediaContentType_roundtrip = () => {
  assert(mediaContentTypeFromTag(0) == Some(Audio))
  assert(mediaContentTypeFromTag(1) == Some(Video))
  assert(mediaContentTypeFromTag(2) == Some(LiveStream))
  assert(mediaContentTypeFromTag(3) == Some(Playlist))
  assert(mediaContentTypeFromTag(4) == Some(Subtitle))
  assert(mediaContentTypeFromTag(5) == None)
}

let test_mediaContentType_toTag = () => {
  assert(mediaContentTypeToTag(Audio) == 0)
  assert(mediaContentTypeToTag(Video) == 1)
  assert(mediaContentTypeToTag(LiveStream) == 2)
  assert(mediaContentTypeToTag(Playlist) == 3)
  assert(mediaContentTypeToTag(Subtitle) == 4)
}

let test_codec_roundtrip = () => {
  assert(codecFromTag(0) == Some(H264))
  assert(codecFromTag(1) == Some(H265))
  assert(codecFromTag(2) == Some(Av1))
  assert(codecFromTag(3) == Some(Vp9))
  assert(codecFromTag(4) == Some(Aac))
  assert(codecFromTag(5) == Some(Opus))
  assert(codecFromTag(6) == Some(Flac))
  assert(codecFromTag(7) == Some(Mp3))
  assert(codecFromTag(8) == None)
}

let test_codec_toTag = () => {
  assert(codecToTag(H264) == 0)
  assert(codecToTag(H265) == 1)
  assert(codecToTag(Av1) == 2)
  assert(codecToTag(Vp9) == 3)
  assert(codecToTag(Aac) == 4)
  assert(codecToTag(Opus) == 5)
  assert(codecToTag(Flac) == 6)
  assert(codecToTag(Mp3) == 7)
}

let test_streamProtocol_roundtrip = () => {
  assert(streamProtocolFromTag(0) == Some(Hls))
  assert(streamProtocolFromTag(1) == Some(Dash))
  assert(streamProtocolFromTag(2) == Some(Rtmp))
  assert(streamProtocolFromTag(3) == Some(Rtsp))
  assert(streamProtocolFromTag(4) == Some(WebRtc))
  assert(streamProtocolFromTag(5) == Some(Srt))
  assert(streamProtocolFromTag(6) == None)
}

let test_streamProtocol_toTag = () => {
  assert(streamProtocolToTag(Hls) == 0)
  assert(streamProtocolToTag(Dash) == 1)
  assert(streamProtocolToTag(Rtmp) == 2)
  assert(streamProtocolToTag(Rtsp) == 3)
  assert(streamProtocolToTag(WebRtc) == 4)
  assert(streamProtocolToTag(Srt) == 5)
}

let test_transcodeProfile_roundtrip = () => {
  assert(transcodeProfileFromTag(0) == Some(Passthrough))
  assert(transcodeProfileFromTag(1) == Some(Low))
  assert(transcodeProfileFromTag(2) == Some(Medium))
  assert(transcodeProfileFromTag(3) == Some(High))
  assert(transcodeProfileFromTag(4) == Some(Ultra))
  assert(transcodeProfileFromTag(5) == None)
}

let test_transcodeProfile_toTag = () => {
  assert(transcodeProfileToTag(Passthrough) == 0)
  assert(transcodeProfileToTag(Low) == 1)
  assert(transcodeProfileToTag(Medium) == 2)
  assert(transcodeProfileToTag(High) == 3)
  assert(transcodeProfileToTag(Ultra) == 4)
}

let test_playerEvent_roundtrip = () => {
  assert(playerEventFromTag(0) == Some(Play))
  assert(playerEventFromTag(1) == Some(Pause))
  assert(playerEventFromTag(2) == Some(Seek))
  assert(playerEventFromTag(3) == Some(Stop))
  assert(playerEventFromTag(4) == Some(BufferStart))
  assert(playerEventFromTag(5) == Some(BufferEnd))
  assert(playerEventFromTag(6) == Some(Error))
  assert(playerEventFromTag(7) == Some(QualityChange))
  assert(playerEventFromTag(8) == None)
}

let test_playerEvent_toTag = () => {
  assert(playerEventToTag(Play) == 0)
  assert(playerEventToTag(Pause) == 1)
  assert(playerEventToTag(Seek) == 2)
  assert(playerEventToTag(Stop) == 3)
  assert(playerEventToTag(BufferStart) == 4)
  assert(playerEventToTag(BufferEnd) == 5)
  assert(playerEventToTag(Error) == 6)
  assert(playerEventToTag(QualityChange) == 7)
}

let test_playerState_roundtrip = () => {
  assert(playerStateFromTag(0) == Some(Idle))
  assert(playerStateFromTag(1) == Some(Ready))
  assert(playerStateFromTag(2) == Some(Playing))
  assert(playerStateFromTag(3) == Some(Paused))
  assert(playerStateFromTag(4) == Some(Stopping))
  assert(playerStateFromTag(5) == None)
}

let test_playerState_toTag = () => {
  assert(playerStateToTag(Idle) == 0)
  assert(playerStateToTag(Ready) == 1)
  assert(playerStateToTag(Playing) == 2)
  assert(playerStateToTag(Paused) == 3)
  assert(playerStateToTag(Stopping) == 4)
}

// Run all tests
test_mediaContentType_roundtrip()
test_mediaContentType_toTag()
test_codec_roundtrip()
test_codec_toTag()
test_streamProtocol_roundtrip()
test_streamProtocol_toTag()
test_transcodeProfile_roundtrip()
test_transcodeProfile_toTag()
test_playerEvent_roundtrip()
test_playerEvent_toTag()
test_playerState_roundtrip()
test_playerState_toTag()
