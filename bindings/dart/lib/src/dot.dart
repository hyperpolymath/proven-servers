// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoT protocol types for proven-servers.

/// SessionState matching the Idris2 ABI tags.
enum SessionState {
  connecting(0),
  handshaking(1),
  established(2),
  closing(3),
  closed(4);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// PaddingStrategy matching the Idris2 ABI tags.
enum PaddingStrategy {
  noPadding(0),
  blockPadding(1),
  randomPadding(2);

  const PaddingStrategy(this.tag);
  final int tag;

  static PaddingStrategy? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ErrorReason matching the Idris2 ABI tags.
enum ErrorReason {
  handshakeFailed(0),
  certificateInvalid(1),
  timeout(2),
  upstreamError(3);

  const ErrorReason(this.tag);
  final int tag;

  static ErrorReason? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ServerState matching the Idris2 ABI tags.
enum ServerState {
  idle(0),
  bound(1),
  listening(2),
  processing(3),
  shutdown(4);

  const ServerState(this.tag);
  final int tag;

  static ServerState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
