// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// HTTP protocol types for proven-servers.

/// Method matching the Idris2 ABI tags.
enum Method {
  get_(0),
  post(1),
  put(2),
  delete(3),
  patch(4),
  head(5),
  options(6),
  trace(7),
  connect(8);

  const Method(this.tag);
  final int tag;

  static Method? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Version matching the Idris2 ABI tags.
enum Version {
  http10(0),
  http11(1),
  http20(2),
  http30(3);

  const Version(this.tag);
  final int tag;

  static Version? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// StatusCategory matching the Idris2 ABI tags.
enum StatusCategory {
  informational(0),
  success(1),
  redirect(2),
  clientError(3),
  serverError(4);

  const StatusCategory(this.tag);
  final int tag;

  static StatusCategory? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// StatusCode matching the Idris2 ABI tags.
enum StatusCode {
  continue_(0),
  switchingProtocols(1),
  ok(2),
  created(3),
  accepted(4),
  noContent(5),
  movedPermanently(6),
  found(7),
  notModified(8),
  temporaryRedirect(9),
  permanentRedirect(10),
  badRequest(11),
  unauthorized(12),
  forbidden(13),
  notFound(14),
  methodNotAllowed(15),
  requestTimeout(16),
  conflict(17),
  gone(18),
  lengthRequired(19),
  payloadTooLarge(20),
  uriTooLong(21),
  unsupportedMedia(22),
  tooManyRequests(23),
  internalError(24),
  notImplemented(25),
  badGateway(26),
  serviceUnavailable(27),
  gatewayTimeout(28);

  const StatusCode(this.tag);
  final int tag;

  static StatusCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ContentType matching the Idris2 ABI tags.
enum ContentType {
  textPlain(0),
  textHtml(1),
  applicationJson(2),
  applicationXml(3),
  applicationForm(4),
  multipartForm(5),
  octetStream(6),
  textCss(7);

  const ContentType(this.tag);
  final int tag;

  static ContentType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// HeaderType matching the Idris2 ABI tags.
enum HeaderType {
  contentType(0),
  contentLength(1),
  host(2),
  connection(3),
  accept(4),
  userAgent(5),
  server(6),
  location(7),
  cacheControl(8),
  custom(9);

  const HeaderType(this.tag);
  final int tag;

  static HeaderType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// RequestPhase matching the Idris2 ABI tags.
enum RequestPhase {
  idle(0),
  receiving(1),
  headersParsed(2),
  bodyReceiving(3),
  complete(4),
  responding(5),
  sent(6);

  const RequestPhase(this.tag);
  final int tag;

  static RequestPhase? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
