// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// BFD protocol types for proven-servers.

/// BfdState matching the Idris2 ABI tags.
enum BfdState {
  adminDown(0),
  down(1),
  init(2),
  up(3);

  const BfdState(this.tag);
  final int tag;

  static BfdState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Diagnostic matching the Idris2 ABI tags.
enum Diagnostic {
  noDiagnostic(0),
  controlDetectionTimeExpired(1),
  echoFunctionFailed(2),
  neighborSignaledSessionDown(3),
  forwardingPlaneReset(4),
  pathDown(5),
  concatenatedPathDown(6),
  administrativelyDown(7),
  reverseConcatenatedPathDown(8);

  const Diagnostic(this.tag);
  final int tag;

  static Diagnostic? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SessionMode matching the Idris2 ABI tags.
enum SessionMode {
  asyncMode(0),
  demandMode(1);

  const SessionMode(this.tag);
  final int tag;

  static SessionMode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SessionState matching the Idris2 ABI tags.
enum SessionState {
  idle(0),
  ssDown(1),
  negotiating(2),
  established(3),
  teardown(4);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
