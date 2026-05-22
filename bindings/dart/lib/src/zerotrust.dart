// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Zero Trust protocol types for proven-servers.

/// PolicyType matching the Idris2 ABI tags.
enum PolicyType {
  alwaysVerify(0),
  neverTrust(1),
  leastPrivilege(2),
  microSegmentation(3);

  const PolicyType(this.tag);
  final int tag;

  static PolicyType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// IdentityConfidence matching the Idris2 ABI tags.
enum IdentityConfidence {
  unverified(0),
  basicAuth(1),
  mfaVerified(2),
  strongAuth(3),
  continuousAuth(4);

  const IdentityConfidence(this.tag);
  final int tag;

  static IdentityConfidence? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DeviceTrustScore matching the Idris2 ABI tags.
enum DeviceTrustScore {
  deviceUnknown(0),
  devicePartial(1),
  deviceCompliant(2),
  deviceManaged(3),
  deviceHardened(4);

  const DeviceTrustScore(this.tag);
  final int tag;

  static DeviceTrustScore? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AccessDecision matching the Idris2 ABI tags.
enum AccessDecision {
  allow(0),
  deny(1),
  challenge(2),
  stepUp(3);

  const AccessDecision(this.tag);
  final int tag;

  static AccessDecision? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ContextSignalKind matching the Idris2 ABI tags.
enum ContextSignalKind {
  location(0),
  time(1),
  device(2),
  behavior(3),
  network(4);

  const ContextSignalKind(this.tag);
  final int tag;

  static ContextSignalKind? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AuthFactor matching the Idris2 ABI tags.
enum AuthFactor {
  certificate(0),
  token(1),
  biometric(2),
  fido2(3),
  totp(4),
  push(5);

  const AuthFactor(this.tag);
  final int tag;

  static AuthFactor? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
