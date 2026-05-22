// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Load Balancer protocol types for proven-servers.

/// Algorithm matching the Idris2 ABI tags.
enum Algorithm {
  roundRobin(0),
  leastConnections(1),
  ipHash(2),
  random(3),
  weightedRoundRobin(4),
  leastResponseTime(5);

  const Algorithm(this.tag);
  final int tag;

  static Algorithm? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// HealthCheckType matching the Idris2 ABI tags.
enum HealthCheckType {
  healthCheckType_Http(0),
  healthCheckType_Tcp(1),
  healthCheckType_Grpc(2),
  script(3);

  const HealthCheckType(this.tag);
  final int tag;

  static HealthCheckType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// BackendState matching the Idris2 ABI tags.
enum BackendState {
  healthy(0),
  unhealthy(1),
  draining(2),
  disabled(3);

  const BackendState(this.tag);
  final int tag;

  static BackendState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SessionPersistence matching the Idris2 ABI tags.
enum SessionPersistence {
  none(0),
  cookie(1),
  sourceIp(2),
  header(3);

  const SessionPersistence(this.tag);
  final int tag;

  static SessionPersistence? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// LbProtocol matching the Idris2 ABI tags.
enum LbProtocol {
  lbProtocol_Http(0),
  https(1),
  lbProtocol_Tcp(2),
  udp(3),
  lbProtocol_Grpc(4);

  const LbProtocol(this.tag);
  final int tag;

  static LbProtocol? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
