// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Media protocol types for proven-servers.

/// MediaContentType matching the Idris2 ABI tags.
enum MediaContentType {
  audio(0),
  video(1),
  liveStream(2),
  playlist(3),
  subtitle(4);

  const MediaContentType(this.tag);
  final int tag;

  static MediaContentType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Codec matching the Idris2 ABI tags.
enum Codec {
  h264(0),
  h265(1),
  av1(2),
  vp9(3),
  aac(4),
  opus(5),
  flac(6),
  mp3(7);

  const Codec(this.tag);
  final int tag;

  static Codec? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// StreamProtocol matching the Idris2 ABI tags.
enum StreamProtocol {
  hls(0),
  dash(1),
  rtmp(2),
  rtsp(3),
  webRtc(4),
  srt(5);

  const StreamProtocol(this.tag);
  final int tag;

  static StreamProtocol? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TranscodeProfile matching the Idris2 ABI tags.
enum TranscodeProfile {
  passthrough(0),
  low(1),
  medium(2),
  high(3),
  ultra(4);

  const TranscodeProfile(this.tag);
  final int tag;

  static TranscodeProfile? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// PlayerEvent matching the Idris2 ABI tags.
enum PlayerEvent {
  play(0),
  pause(1),
  seek(2),
  stop(3),
  bufferStart(4),
  bufferEnd(5),
  error(6),
  qualityChange(7);

  const PlayerEvent(this.tag);
  final int tag;

  static PlayerEvent? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// PlayerState matching the Idris2 ABI tags.
enum PlayerState {
  idle(0),
  ready(1),
  playing(2),
  paused(3),
  stopping(4);

  const PlayerState(this.tag);
  final int tag;

  static PlayerState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
