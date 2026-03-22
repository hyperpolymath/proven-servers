// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SOCKS5 protocol types for proven-servers.

/// AuthMethod matching the Idris2 ABI tags.
enum AuthMethod {
  noAuth(0),
  gssapi(1),
  usernamePassword(2),
  noAcceptable(3);

  const AuthMethod(this.tag);
  final int tag;

  static AuthMethod? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Command matching the Idris2 ABI tags.
enum Command {
  connect(0),
  bind(1),
  udpAssociate(2);

  const Command(this.tag);
  final int tag;

  static Command? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AddressType matching the Idris2 ABI tags.
enum AddressType {
  iPv4(0),
  domainName(1),
  iPv6(2);

  const AddressType(this.tag);
  final int tag;

  static AddressType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Reply matching the Idris2 ABI tags.
enum Reply {
  succeeded(0),
  generalFailure(1),
  notAllowed(2),
  networkUnreachable(3),
  hostUnreachable(4),
  connectionRefused(5),
  ttlExpired(6),
  commandNotSupported(7),
  addressTypeNotSupported(8);

  const Reply(this.tag);
  final int tag;

  static Reply? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// State matching the Idris2 ABI tags.
enum State {
  initial(0),
  authenticating(1),
  authenticated(2),
  connecting(3),
  established(4),
  closed(5);

  const State(this.tag);
  final int tag;

  static State? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
