// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Auth protocol types for proven-servers.

/// AuthMethod matching the Idris2 ABI tags.
enum AuthMethod {
  password(0),
  certificate(1),
  oAuth2(2),
  saml(3),
  fido2(4),
  kerberos(5),
  ldap(6),
  radius(7);

  const AuthMethod(this.tag);
  final int tag;

  static AuthMethod? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TokenType matching the Idris2 ABI tags.
enum TokenType {
  access(0),
  refresh(1),
  id(2),
  api(3);

  const TokenType(this.tag);
  final int tag;

  static TokenType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AuthResult matching the Idris2 ABI tags.
enum AuthResult {
  success(0),
  invalidCredentials(1),
  accountLocked(2),
  accountExpired(3),
  mfaRequired(4),
  ipBlocked(5);

  const AuthResult(this.tag);
  final int tag;

  static AuthResult? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// MfaMethod matching the Idris2 ABI tags.
enum MfaMethod {
  totp(0),
  sms(1),
  push(2),
  fido2Mfa(3),
  email(4);

  const MfaMethod(this.tag);
  final int tag;

  static MfaMethod? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SessionState matching the Idris2 ABI tags.
enum SessionState {
  active(0),
  expired(1),
  revoked(2),
  locked(3);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
