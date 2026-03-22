// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// App Server protocol types for proven-servers.

/// RequestType matching the Idris2 ABI tags.
enum RequestType {
  http(0),
  webSocket(1),
  grpc(2),
  graphQl(3);

  const RequestType(this.tag);
  final int tag;

  static RequestType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// LifecycleState matching the Idris2 ABI tags.
enum LifecycleState {
  initializing(0),
  starting(1),
  running(2),
  draining(3),
  stopping(4),
  stopped(5);

  const LifecycleState(this.tag);
  final int tag;

  static LifecycleState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// HealthCheck matching the Idris2 ABI tags.
enum HealthCheck {
  liveness(0),
  readiness(1),
  startup(2);

  const HealthCheck(this.tag);
  final int tag;

  static HealthCheck? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DeployStrategy matching the Idris2 ABI tags.
enum DeployStrategy {
  rollingUpdate(0),
  blueGreen(1),
  canary(2),
  recreate(3);

  const DeployStrategy(this.tag);
  final int tag;

  static DeployStrategy? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ErrorCategory matching the Idris2 ABI tags.
enum ErrorCategory {
  clientError(0),
  serverError(1),
  timeout(2),
  circuitOpen(3),
  rateLimited(4);

  const ErrorCategory(this.tag);
  final int tag;

  static ErrorCategory? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
