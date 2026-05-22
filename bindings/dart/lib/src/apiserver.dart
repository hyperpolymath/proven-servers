// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// API Server protocol types for proven-servers.

/// AuthScheme matching the Idris2 ABI tags.
enum AuthScheme {
  apiKey(0),
  bearer(1),
  basic(2),
  oAuth2(3),
  hmac(4),
  mtls(5);

  const AuthScheme(this.tag);
  final int tag;

  static AuthScheme? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// RateLimitStrategy matching the Idris2 ABI tags.
enum RateLimitStrategy {
  fixedWindow(0),
  slidingWindow(1),
  tokenBucket(2),
  leakyBucket(3);

  const RateLimitStrategy(this.tag);
  final int tag;

  static RateLimitStrategy? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ApiVersion matching the Idris2 ABI tags.
enum ApiVersion {
  v1(0),
  v2(1),
  v3(2),
  latest(3),
  deprecated(4);

  const ApiVersion(this.tag);
  final int tag;

  static ApiVersion? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ResponseFormat matching the Idris2 ABI tags.
enum ResponseFormat {
  json(0),
  xml(1),
  protobuf(2),
  messagePack(3);

  const ResponseFormat(this.tag);
  final int tag;

  static ResponseFormat? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// GatewayError matching the Idris2 ABI tags.
enum GatewayError {
  unauthorized(0),
  rateLimited(1),
  notFound(2),
  badRequest(3),
  serviceUnavailable(4),
  circuitOpen(5);

  const GatewayError(this.tag);
  final int tag;

  static GatewayError? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
