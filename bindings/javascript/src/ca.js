// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CA protocol types for proven-servers.

/** CertType matching the Idris2 ABI tags. */
export const CertType = Object.freeze({
  ROOT: 0,
  INTERMEDIATE: 1,
  END_ENTITY: 2,
  CROSS_SIGNED: 3,
  CODE_SIGNING: 4,
  EMAIL_PROTECTION: 5,
  OCSP_SIGNING: 6,
});

/** KeyAlgorithm matching the Idris2 ABI tags. */
export const KeyAlgorithm = Object.freeze({
  RSA2048: 0,
  RSA4096: 1,
  ECDSA_P256: 2,
  ECDSA_P384: 3,
  ED25519: 4,
  ED448: 5,
});

/** SignatureAlgorithm matching the Idris2 ABI tags. */
export const SignatureAlgorithm = Object.freeze({
  SHA256_WITH_RSA: 0,
  SHA384_WITH_RSA: 1,
  SHA512_WITH_RSA: 2,
  SHA256_WITH_ECDSA: 3,
  SHA384_WITH_ECDSA: 4,
  PURE_ED25519: 5,
  PURE_ED448: 6,
});

/** CertState matching the Idris2 ABI tags. */
export const CertState = Object.freeze({
  PENDING: 0,
  ACTIVE: 1,
  REVOKED: 2,
  EXPIRED: 3,
  SUSPENDED: 4,
});

/** RevocationReason matching the Idris2 ABI tags. */
export const RevocationReason = Object.freeze({
  UNSPECIFIED: 0,
  KEY_COMPROMISE: 1,
  CA_COMPROMISE: 2,
  AFFILIATION_CHANGED: 3,
  SUPERSEDED: 4,
  CESSATION_OF_OPERATION: 5,
  CERTIFICATE_HOLD: 6,
});

/** CrlStatus matching the Idris2 ABI tags. */
export const CrlStatus = Object.freeze({
  CURRENT: 0,
  CRL_EXPIRED: 1,
  CRL_PENDING: 2,
  CRL_ERROR: 3,
});

/** OcspStatus matching the Idris2 ABI tags. */
export const OcspStatus = Object.freeze({
  GOOD: 0,
  OCSP_REVOKED: 1,
  UNKNOWN: 2,
  UNAVAILABLE: 3,
});

/** Extension matching the Idris2 ABI tags. */
export const Extension = Object.freeze({
  BASIC_CONSTRAINTS: 0,
  KEY_USAGE: 1,
  EXT_KEY_USAGE: 2,
  SUBJECT_ALT_NAME: 3,
  AUTHORITY_INFO_ACCESS: 4,
  CRL_DISTRIBUTION_POINTS: 5,
});

/** KeyUsageBit matching the Idris2 ABI tags. */
export const KeyUsageBit = Object.freeze({
  DIGITAL_SIGNATURE: 0,
  NON_REPUDIATION: 1,
  KEY_ENCIPHERMENT: 2,
  DATA_ENCIPHERMENT: 3,
  KEY_AGREEMENT: 4,
  KEY_CERT_SIGN: 5,
  CRL_SIGN: 6,
  ENCIPHER_ONLY: 7,
  DECIPHER_ONLY: 8,
});
