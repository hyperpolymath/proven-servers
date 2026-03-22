// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OCSP protocol types for proven-servers.

/// CertStatus matching the Idris2 ABI tags.
enum CertStatus {
  good(0),
  revoked(1),
  unknown(2);

  const CertStatus(this.tag);
  final int tag;

  static CertStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ResponseStatus matching the Idris2 ABI tags.
enum ResponseStatus {
  successful(0),
  malformedRequest(1),
  internalError(2),
  tryLater(3),
  sigRequired(4),
  unauthorized(5);

  const ResponseStatus(this.tag);
  final int tag;

  static ResponseStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// HashAlgorithm matching the Idris2 ABI tags.
enum HashAlgorithm {
  sha1(0),
  sha256(1),
  sha384(2),
  sha512(3);

  const HashAlgorithm(this.tag);
  final int tag;

  static HashAlgorithm? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ResponderState matching the Idris2 ABI tags.
enum ResponderState {
  idle(0),
  ready(1),
  processing(2),
  signing(3),
  closing(4);

  const ResponderState(this.tag);
  final int tag;

  static ResponderState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
