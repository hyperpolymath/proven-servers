// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SMB protocol types for proven-servers.

/// Command matching the Idris2 ABI tags.
enum Command {
  negotiate(0),
  sessionSetup(1),
  logoff(2),
  treeConnect(3),
  treeDisconnect(4),
  create(5),
  close(6),
  read(7),
  write(8),
  lock(9),
  ioctl(10),
  cancel(11),
  queryDirectory(12),
  changeNotify(13),
  queryInfo(14),
  setInfo(15);

  const Command(this.tag);
  final int tag;

  static Command? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// Dialect matching the Idris2 ABI tags.
enum Dialect {
  smb2_0_2(0),
  smb2_1(1),
  smb3_0(2),
  smb3_0_2(3),
  smb3_1_1(4);

  const Dialect(this.tag);
  final int tag;

  static Dialect? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ShareType matching the Idris2 ABI tags.
enum ShareType {
  disk(0),
  pipe(1),
  print(2);

  const ShareType(this.tag);
  final int tag;

  static ShareType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SessionState matching the Idris2 ABI tags.
enum SessionState {
  idle(0),
  negotiated(1),
  authenticated(2),
  treeConnected(3),
  fileOpen(4),
  disconnecting(5);

  const SessionState(this.tag);
  final int tag;

  static SessionState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
