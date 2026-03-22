// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NTS protocol types for proven-servers.

/// RecordType matching the Idris2 ABI tags.
enum RecordType {
  endOfMessage(0),
  nextProtocol(1),
  error(2),
  warning(3),
  aeadAlgorithm(4),
  cookie(5),
  cookiePlaceholder(6),
  ntskeServer(7),
  ntskePort(8);

  const RecordType(this.tag);
  final int tag;

  static RecordType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ErrorCode matching the Idris2 ABI tags.
enum ErrorCode {
  unrecognizedCritical(0),
  badRequest(1),
  internalError(2);

  const ErrorCode(this.tag);
  final int tag;

  static ErrorCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AeadAlgorithm matching the Idris2 ABI tags.
enum AeadAlgorithm {
  aeadAes128Gcm(0),
  aeadAes256Gcm(1),
  aeadAesSivCmac256(2);

  const AeadAlgorithm(this.tag);
  final int tag;

  static AeadAlgorithm? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// HandshakeState matching the Idris2 ABI tags.
enum HandshakeState {
  initial(0),
  handshakeState_Negotiating(1),
  handshakeState_Established(2),
  failed(3);

  const HandshakeState(this.tag);
  final int tag;

  static HandshakeState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SessionState matching the Idris2 ABI tags.
enum SessionState {
  idle(0),
  handshaking(1),
  sessionState_Negotiating(2),
  sessionState_Established(3),
  closing(4);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
