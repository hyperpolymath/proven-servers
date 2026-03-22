// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Semantic Web protocol types for proven-servers.

/// RdfFormat matching the Idris2 ABI tags.
enum RdfFormat {
  rdfXml(0),
  turtle(1),
  nTriples(2),
  nQuads(3),
  jsonLd(4),
  trig(5);

  const RdfFormat(this.tag);
  final int tag;

  static RdfFormat? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SemwebResourceType matching the Idris2 ABI tags.
enum SemwebResourceType {
  class_(0),
  property(1),
  individual(2),
  ontology(3),
  namedGraph(4);

  const SemwebResourceType(this.tag);
  final int tag;

  static SemwebResourceType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// HttpMethod matching the Idris2 ABI tags.
enum HttpMethod {
  get_(0),
  post(1),
  put(2),
  patch(3),
  delete(4);

  const HttpMethod(this.tag);
  final int tag;

  static HttpMethod? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ContentNegotiation matching the Idris2 ABI tags.
enum ContentNegotiation {
  negRdfXml(0),
  negTurtle(1),
  negJsonLd(2),
  negHtml(3);

  const ContentNegotiation(this.tag);
  final int tag;

  static ContentNegotiation? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SemwebErrorCode matching the Idris2 ABI tags.
enum SemwebErrorCode {
  notFound(0),
  invalidUri(1),
  malformedRdf(2),
  unsupportedFormat(3),
  conflictingTriples(4);

  const SemwebErrorCode(this.tag);
  final int tag;

  static SemwebErrorCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
