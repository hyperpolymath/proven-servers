// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Kerberos protocol types for proven-servers.

/// MessageType matching the Idris2 ABI tags.
enum MessageType {
  asReq(0),
  asRep(1),
  tgsReq(2),
  tgsRep(3),
  apReq(4),
  apRep(5),
  krbError(6),
  krbSafe(7),
  krbPriv(8),
  krbCred(9);

  const MessageType(this.tag);
  final int tag;

  static MessageType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// EncryptionType matching the Idris2 ABI tags.
enum EncryptionType {
  aes256CtsHmacSha1(0),
  aes128CtsHmacSha1(1),
  aes256CtsHmacSha384(2),
  rc4Hmac(3),
  des3CbcSha1(4);

  const EncryptionType(this.tag);
  final int tag;

  static EncryptionType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// PrincipalType matching the Idris2 ABI tags.
enum PrincipalType {
  ntUnknown(0),
  ntPrincipal(1),
  ntSrvInst(2),
  ntSrvHst(3),
  ntUid(4),
  ntX500(5),
  ntEnterprise(6);

  const PrincipalType(this.tag);
  final int tag;

  static PrincipalType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TicketFlag matching the Idris2 ABI tags.
enum TicketFlag {
  forwardable(0),
  forwarded(1),
  proxiable(2),
  proxy(3),
  renewable(4),
  preAuthent(5),
  hwAuthent(6);

  const TicketFlag(this.tag);
  final int tag;

  static TicketFlag? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ErrorCode matching the Idris2 ABI tags.
enum ErrorCode {
  kdcErrNone(0),
  kdcErrNameExp(1),
  kdcErrServiceExp(2),
  kdcErrBadPvno(3),
  kdcErrCOldMastKvno(4),
  kdcErrSOldMastKvno(5),
  kdcErrCPrincipalUnknown(6),
  kdcErrSPrincipalUnknown(7),
  kdcErrPreauthFailed(8),
  kdcErrPreauthRequired(9);

  const ErrorCode(this.tag);
  final int tag;

  static ErrorCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AuthState matching the Idris2 ABI tags.
enum AuthState {
  initial(0),
  tgtObtained(1),
  serviceTicketObtained(2),
  authenticated(3),
  authFailed(4);

  const AuthState(this.tag);
  final int tag;

  static AuthState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// EncStrength matching the Idris2 ABI tags.
enum EncStrength {
  strong(0),
  medium(1),
  weak(2);

  const EncStrength(this.tag);
  final int tag;

  static EncStrength? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// PreAuthType matching the Idris2 ABI tags.
enum PreAuthType {
  paEncTimestamp(0),
  paEtypeInfo2(1),
  paFxFast(2),
  paFxCookie(3);

  const PreAuthType(this.tag);
  final int tag;

  static PreAuthType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// NegotiationState matching the Idris2 ABI tags.
enum NegotiationState {
  negIdle(0),
  proposed(1),
  selected(2),
  negFailed(3);

  const NegotiationState(this.tag);
  final int tag;

  static NegotiationState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
