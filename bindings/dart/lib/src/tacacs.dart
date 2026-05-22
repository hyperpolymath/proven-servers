// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TACACS+ protocol types for proven-servers.

/// PacketType matching the Idris2 ABI tags.
enum PacketType {
  authentication(0),
  authorization(1),
  accounting(2);

  const PacketType(this.tag);
  final int tag;

  static PacketType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AuthenType matching the Idris2 ABI tags.
enum AuthenType {
  ascii(0),
  pap(1),
  chap(2),
  msChapV1(3),
  msChapV2(4);

  const AuthenType(this.tag);
  final int tag;

  static AuthenType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AuthenAction matching the Idris2 ABI tags.
enum AuthenAction {
  login(0),
  changePass(1),
  sendAuth(2);

  const AuthenAction(this.tag);
  final int tag;

  static AuthenAction? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AuthenStatus matching the Idris2 ABI tags.
enum AuthenStatus {
  pass(0),
  authenStatus_Fail(1),
  getData(2),
  getUser(3),
  getPass(4),
  restart(5),
  authenStatus_Error(6),
  authenStatus_Follow(7);

  const AuthenStatus(this.tag);
  final int tag;

  static AuthenStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AuthorStatus matching the Idris2 ABI tags.
enum AuthorStatus {
  passAdd(0),
  passRepl(1),
  authorStatus_Fail(2),
  authorStatus_Error(3),
  authorStatus_Follow(4);

  const AuthorStatus(this.tag);
  final int tag;

  static AuthorStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AcctStatus matching the Idris2 ABI tags.
enum AcctStatus {
  success(0),
  acctStatus_Error(1),
  acctStatus_Follow(2);

  const AcctStatus(this.tag);
  final int tag;

  static AcctStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// AcctFlag matching the Idris2 ABI tags.
enum AcctFlag {
  start(0),
  stop(1),
  watchdog(2);

  const AcctFlag(this.tag);
  final int tag;

  static AcctFlag? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SessionState matching the Idris2 ABI tags.
enum SessionState {
  idle(0),
  authenticating(1),
  authorizing(2),
  active(3),
  closing(4);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
