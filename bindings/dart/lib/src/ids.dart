// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IDS protocol types for proven-servers.

/// AlertSeverity matching the Idris2 ABI tags.
enum AlertSeverity {
  alertSeverity_Low(0),
  alertSeverity_Medium(1),
  alertSeverity_High(2),
  alertSeverity_Critical(3);

  const AlertSeverity(this.tag);
  final int tag;

  static AlertSeverity? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DetectionMethod matching the Idris2 ABI tags.
enum DetectionMethod {
  signature(0),
  anomaly(1),
  stateful(2),
  heuristic(3);

  const DetectionMethod(this.tag);
  final int tag;

  static DetectionMethod? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// IdsProtocol matching the Idris2 ABI tags.
enum IdsProtocol {
  tcp(0),
  udp(1),
  icmp(2),
  dns(3),
  http(4),
  tls(5),
  ssh(6);

  const IdsProtocol(this.tag);
  final int tag;

  static IdsProtocol? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// IdsAction matching the Idris2 ABI tags.
enum IdsAction {
  alert(0),
  drop(1),
  log(2),
  block(3),
  pass(4);

  const IdsAction(this.tag);
  final int tag;

  static IdsAction? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Direction matching the Idris2 ABI tags.
enum Direction {
  inbound(0),
  outbound(1),
  both(2);

  const Direction(this.tag);
  final int tag;

  static Direction? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ThreatLevel matching the Idris2 ABI tags.
enum ThreatLevel {
  info(0),
  threatLevel_Low(1),
  threatLevel_Medium(2),
  threatLevel_High(3),
  threatLevel_Critical(4);

  const ThreatLevel(this.tag);
  final int tag;

  static ThreatLevel? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
