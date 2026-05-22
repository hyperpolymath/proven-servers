// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Proxy protocol types for proven-servers.

/// ProxyMode matching the Idris2 ABI tags.
enum ProxyMode {
  forward(0),
  reverse(1);

  const ProxyMode(this.tag);
  final int tag;

  static ProxyMode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// HopByHopHeader matching the Idris2 ABI tags.
enum HopByHopHeader {
  connection(0),
  keepAlive(1),
  proxyAuth(2),
  proxyAuthz(3),
  te(4),
  trailers(5),
  transferEncoding(6),
  upgrade(7);

  const HopByHopHeader(this.tag);
  final int tag;

  static HopByHopHeader? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// CacheDirective matching the Idris2 ABI tags.
enum CacheDirective {
  noCache(0),
  noStore(1),
  maxAge(2),
  public(3),
  private(4),
  mustRevalidate(5);

  const CacheDirective(this.tag);
  final int tag;

  static CacheDirective? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ProxyError matching the Idris2 ABI tags.
enum ProxyError {
  badGateway(0),
  gatewayTimeout(1),
  upstreamRefused(2),
  upstreamTls(3);

  const ProxyError(this.tag);
  final int tag;

  static ProxyError? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
