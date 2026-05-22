// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Hardened protocol types for proven-servers.

/// HardeningLevel matching the Idris2 ABI tags.
enum HardeningLevel {
  minimal(0),
  standard(1),
  high(2),
  maximum(3);

  const HardeningLevel(this.tag);
  final int tag;

  static HardeningLevel? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SecurityControl matching the Idris2 ABI tags.
enum SecurityControl {
  aslr(0),
  dep(1),
  stackCanary(2),
  cfi(3),
  sandboxing(4),
  secureBoot(5),
  auditLog(6);

  const SecurityControl(this.tag);
  final int tag;

  static SecurityControl? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ComplianceStandard matching the Idris2 ABI tags.
enum ComplianceStandard {
  cis(0),
  stig(1),
  nist80053(2),
  pciDss(3),
  fips140(4);

  const ComplianceStandard(this.tag);
  final int tag;

  static ComplianceStandard? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AuditEvent matching the Idris2 ABI tags.
enum AuditEvent {
  processStart(0),
  fileAccess(1),
  networkConn(2),
  privilegeEscalation(3),
  configChange(4),
  authAttempt(5);

  const AuditEvent(this.tag);
  final int tag;

  static AuditEvent? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// HardenedHealthStatus matching the Idris2 ABI tags.
enum HardenedHealthStatus {
  healthy(0),
  degraded(1),
  compromised(2),
  unresponsive(3);

  const HardenedHealthStatus(this.tag);
  final int tag;

  static HardenedHealthStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ServerState matching the Idris2 ABI tags.
enum ServerState {
  idle(0),
  hardening(1),
  active(2),
  auditing(3),
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
