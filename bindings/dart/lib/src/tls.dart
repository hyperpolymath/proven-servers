// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TLS protocol types for proven-servers.

/// TlsState matching the Idris2 ABI tags.
enum TlsState {
  tlsIdle(0),
  tlsClientHello(1),
  tlsServerHello(2),
  tlsNegotiating(3),
  tlsEstablished(4),
  tlsRenegotiating(5),
  tlsShutdown(6);

  const TlsState(this.tag);
  final int tag;

  static TlsState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TlsVersion matching the Idris2 ABI tags.
enum TlsVersion {
  tls12(0),
  tls13(1);

  const TlsVersion(this.tag);
  final int tag;

  static TlsVersion? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// CipherSuite matching the Idris2 ABI tags.
enum CipherSuite {
  aesGcm128Sha256(0),
  aesGcm256Sha384(1),
  chaCha20Poly1305Sha256(2),
  aesCcm128Sha256(3);

  const CipherSuite(this.tag);
  final int tag;

  static CipherSuite? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
