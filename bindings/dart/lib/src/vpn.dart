// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// VPN protocol types for proven-servers.

/// TunnelType matching the Idris2 ABI tags.
enum TunnelType {
  ipsec(0),
  wireguard(1),
  openvpn(2),
  l2tp(3);

  const TunnelType(this.tag);
  final int tag;

  static TunnelType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TunnelPhase matching the Idris2 ABI tags.
enum TunnelPhase {
  idle(0),
  phase1Init(1),
  phase1Auth(2),
  phase1Done(3),
  phase2Negotiating(4),
  established(5),
  tunnelPhase_Expired(6);

  const TunnelPhase(this.tag);
  final int tag;

  static TunnelPhase? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// EncryptionAlgorithm matching the Idris2 ABI tags.
enum EncryptionAlgorithm {
  aes128Cbc(0),
  aes256Cbc(1),
  aes128Gcm(2),
  aes256Gcm(3),
  chacha20Poly1305(4),
  nullCipher(5);

  const EncryptionAlgorithm(this.tag);
  final int tag;

  static EncryptionAlgorithm? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// IntegrityAlgorithm matching the Idris2 ABI tags.
enum IntegrityAlgorithm {
  hmacSha1(0),
  hmacSha256(1),
  hmacSha384(2),
  hmacSha512(3),
  noIntegrity(4);

  const IntegrityAlgorithm(this.tag);
  final int tag;

  static IntegrityAlgorithm? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// DhGroup matching the Idris2 ABI tags.
enum DhGroup {
  dh14(0),
  ecp256(1),
  ecp384(2),
  curve25519(3);

  const DhGroup(this.tag);
  final int tag;

  static DhGroup? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SaLifecycle matching the Idris2 ABI tags.
enum SaLifecycle {
  none(0),
  active(1),
  rekeying(2),
  saLifecycle_Expired(3),
  deleted(4);

  const SaLifecycle(this.tag);
  final int tag;

  static SaLifecycle? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// IkeVersion matching the Idris2 ABI tags.
enum IkeVersion {
  v1(0),
  v2(1);

  const IkeVersion(this.tag);
  final int tag;

  static IkeVersion? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// VpnError matching the Idris2 ABI tags.
enum VpnError {
  authenticationFailed(0),
  noProposalChosen(1),
  lifetimeExpired(2),
  invalidSpi(3),
  replayDetected(4),
  negotiationTimeout(5);

  const VpnError(this.tag);
  final int tag;

  static VpnError? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
