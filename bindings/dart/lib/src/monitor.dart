// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Monitor protocol types for proven-servers.

/// CheckType matching the Idris2 ABI tags.
enum CheckType {
  http(0),
  tcp(1),
  udp(2),
  icmp(3),
  dns(4),
  certificate(5),
  disk(6),
  cpu(7),
  memory(8),
  process(9),
  custom(10);

  const CheckType(this.tag);
  final int tag;

  static CheckType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Status matching the Idris2 ABI tags.
enum Status {
  up(0),
  down(1),
  degraded(2),
  unknown(3),
  maintenance(4);

  const Status(this.tag);
  final int tag;

  static Status? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AlertChannel matching the Idris2 ABI tags.
enum AlertChannel {
  email(0),
  sms(1),
  webhook(2),
  slack(3),
  pagerDuty(4);

  const AlertChannel(this.tag);
  final int tag;

  static AlertChannel? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Severity matching the Idris2 ABI tags.
enum Severity {
  info(0),
  warning(1),
  error(2),
  critical(3);

  const Severity(this.tag);
  final int tag;

  static Severity? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// CheckState matching the Idris2 ABI tags.
enum CheckState {
  pending(0),
  checkState_Running(1),
  passed(2),
  failed(3),
  timeout(4),
  csError(5);

  const CheckState(this.tag);
  final int tag;

  static CheckState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// MonitorState matching the Idris2 ABI tags.
enum MonitorState {
  idle(0),
  configured(1),
  monitorState_Running(2),
  monPaused(3),
  alerting(4),
  shutdown(5);

  const MonitorState(this.tag);
  final int tag;

  static MonitorState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
