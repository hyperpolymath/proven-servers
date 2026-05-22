// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Game Server protocol types for proven-servers.

/// SessionType matching the Idris2 ABI tags.
enum SessionType {
  lobby(0),
  match(1),
  practice(2),
  spectator(3),
  tournament(4);

  const SessionType(this.tag);
  final int tag;

  static SessionType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// PlayerState matching the Idris2 ABI tags.
enum PlayerState {
  idle(0),
  queuing(1),
  loading(2),
  playing(3),
  spectating(4),
  disconnected(5);

  const PlayerState(this.tag);
  final int tag;

  static PlayerState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// MatchState matching the Idris2 ABI tags.
enum MatchState {
  waiting(0),
  starting(1),
  inProgress(2),
  paused(3),
  ending(4),
  complete(5);

  const MatchState(this.tag);
  final int tag;

  static MatchState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
