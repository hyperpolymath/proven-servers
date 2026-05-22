// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CardDAV protocol types for proven-servers.

/// PropertyType matching the Idris2 ABI tags.
enum PropertyType {
  fnName(0),
  n(1),
  email(2),
  tel(3),
  adr(4),
  org(5),
  photo(6),
  url(7),
  note(8);

  const PropertyType(this.tag);
  final int tag;

  static PropertyType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// CardMethod matching the Idris2 ABI tags.
enum CardMethod {
  get_(0),
  put(1),
  delete(2),
  propfind(3),
  proppatch(4),
  report(5),
  mkcol(6);

  const CardMethod(this.tag);
  final int tag;

  static CardMethod? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// VCardVersion matching the Idris2 ABI tags.
enum VCardVersion {
  vcard3(0),
  vcard4(1);

  const VCardVersion(this.tag);
  final int tag;

  static VCardVersion? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// CardError matching the Idris2 ABI tags.
enum CardError {
  validAddressData(0),
  noResourceType(1),
  maxResourceSize(2),
  uidConflict(3),
  supportedAddressData(4),
  preconditionFailed(5);

  const CardError(this.tag);
  final int tag;

  static CardError? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ServerState matching the Idris2 ABI tags.
enum ServerState {
  idle(0),
  bound(1),
  serving(2),
  shutdown(3);

  const ServerState(this.tag);
  final int tag;

  static ServerState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
