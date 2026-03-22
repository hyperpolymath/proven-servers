// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TFTP protocol types for proven-servers.

/// Opcode matching the Idris2 ABI tags.
enum Opcode {
  rrq(0),
  wrq(1),
  data(2),
  ack(3),
  error(4);

  const Opcode(this.tag);
  final int tag;

  static Opcode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TransferMode matching the Idris2 ABI tags.
enum TransferMode {
  netAscii(0),
  octet(1),
  mail(2);

  const TransferMode(this.tag);
  final int tag;

  static TransferMode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TftpError matching the Idris2 ABI tags.
enum TftpError {
  notDefined(0),
  fileNotFound(1),
  accessViolation(2),
  diskFull(3),
  illegalOperation(4),
  unknownTid(5),
  fileExists(6),
  noSuchUser(7);

  const TftpError(this.tag);
  final int tag;

  static TftpError? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TransferState matching the Idris2 ABI tags.
enum TransferState {
  idle(0),
  reading(1),
  writing(2),
  inError(3),
  complete(4);

  const TransferState(this.tag);
  final int tag;

  static TransferState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
