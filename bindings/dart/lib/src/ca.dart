// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CA protocol types for proven-servers.

/// CertType matching the Idris2 ABI tags.
enum CertType {
  root(0),
  intermediate(1),
  endEntity(2),
  crossSigned(3),
  codeSigning(4),
  emailProtection(5),
  ocspSigning(6);

  const CertType(this.tag);
  final int tag;

  static CertType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// KeyAlgorithm matching the Idris2 ABI tags.
enum KeyAlgorithm {
  rsa2048(0),
  rsa4096(1),
  ecdsaP256(2),
  ecdsaP384(3),
  ed25519(4),
  ed448(5);

  const KeyAlgorithm(this.tag);
  final int tag;

  static KeyAlgorithm? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SignatureAlgorithm matching the Idris2 ABI tags.
enum SignatureAlgorithm {
  sha256WithRsa(0),
  sha384WithRsa(1),
  sha512WithRsa(2),
  sha256WithEcdsa(3),
  sha384WithEcdsa(4),
  pureEd25519(5),
  pureEd448(6);

  const SignatureAlgorithm(this.tag);
  final int tag;

  static SignatureAlgorithm? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// CertState matching the Idris2 ABI tags.
enum CertState {
  pending(0),
  active(1),
  revoked(2),
  expired(3),
  suspended(4);

  const CertState(this.tag);
  final int tag;

  static CertState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// RevocationReason matching the Idris2 ABI tags.
enum RevocationReason {
  unspecified(0),
  keyCompromise(1),
  caCompromise(2),
  affiliationChanged(3),
  superseded(4),
  cessationOfOperation(5),
  certificateHold(6);

  const RevocationReason(this.tag);
  final int tag;

  static RevocationReason? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// CrlStatus matching the Idris2 ABI tags.
enum CrlStatus {
  current(0),
  crlExpired(1),
  crlPending(2),
  crlError(3);

  const CrlStatus(this.tag);
  final int tag;

  static CrlStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// OcspStatus matching the Idris2 ABI tags.
enum OcspStatus {
  good(0),
  ocspRevoked(1),
  unknown(2),
  unavailable(3);

  const OcspStatus(this.tag);
  final int tag;

  static OcspStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Extension matching the Idris2 ABI tags.
enum Extension {
  basicConstraints(0),
  keyUsage(1),
  extKeyUsage(2),
  subjectAltName(3),
  authorityInfoAccess(4),
  crlDistributionPoints(5);

  const Extension(this.tag);
  final int tag;

  static Extension? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// KeyUsageBit matching the Idris2 ABI tags.
enum KeyUsageBit {
  digitalSignature(0),
  nonRepudiation(1),
  keyEncipherment(2),
  dataEncipherment(3),
  keyAgreement(4),
  keyCertSign(5),
  crlSign(6),
  encipherOnly(7),
  decipherOnly(8);

  const KeyUsageBit(this.tag);
  final int tag;

  static KeyUsageBit? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
