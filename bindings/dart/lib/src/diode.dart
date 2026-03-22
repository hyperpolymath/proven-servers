// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Data Diode protocol types for proven-servers.

/// Direction matching the Idris2 ABI tags.
enum Direction {
  highToLow(0),
  lowToHigh(1);

  const Direction(this.tag);
  final int tag;

  static Direction? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DiodeProtocol matching the Idris2 ABI tags.
enum DiodeProtocol {
  udp(0),
  tcp(1),
  fileTransfer(2),
  syslog(3),
  snmp(4);

  const DiodeProtocol(this.tag);
  final int tag;

  static DiodeProtocol? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TransferState matching the Idris2 ABI tags.
enum TransferState {
  queued(0),
  sending(1),
  confirming(2),
  complete(3),
  failed(4);

  const TransferState(this.tag);
  final int tag;

  static TransferState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ValidationResult matching the Idris2 ABI tags.
enum ValidationResult {
  passed(0),
  formatError(1),
  sizeExceeded(2),
  policyBlocked(3);

  const ValidationResult(this.tag);
  final int tag;

  static ValidationResult? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// IntegrityCheck matching the Idris2 ABI tags.
enum IntegrityCheck {
  crc32(0),
  sha256(1),
  hmac(2);

  const IntegrityCheck(this.tag);
  final int tag;

  static IntegrityCheck? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// GatewayState matching the Idris2 ABI tags.
enum GatewayState {
  idle(0),
  configured(1),
  transferring(2),
  validating(3),
  shutdown(4);

  const GatewayState(this.tag);
  final int tag;

  static GatewayState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
