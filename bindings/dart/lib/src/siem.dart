// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SIEM protocol types for proven-servers.

/// EventSeverity matching the Idris2 ABI tags.
enum EventSeverity {
  info(0),
  low(1),
  medium(2),
  high(3),
  critical(4);

  const EventSeverity(this.tag);
  final int tag;

  static EventSeverity? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// EventCategory matching the Idris2 ABI tags.
enum EventCategory {
  authentication(0),
  networkTraffic(1),
  fileActivity(2),
  processExecution(3),
  policyViolation(4),
  malware(5),
  dataExfiltration(6);

  const EventCategory(this.tag);
  final int tag;

  static EventCategory? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// CorrelationRule matching the Idris2 ABI tags.
enum CorrelationRule {
  threshold(0),
  sequence(1),
  aggregation(2),
  absence(3),
  statistical(4);

  const CorrelationRule(this.tag);
  final int tag;

  static CorrelationRule? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AlertState matching the Idris2 ABI tags.
enum AlertState {
  new_(0),
  acknowledged(1),
  inProgress(2),
  resolved(3),
  falsePositive(4);

  const AlertState(this.tag);
  final int tag;

  static AlertState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
