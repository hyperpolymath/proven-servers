// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LPD protocol types for proven-servers.

/// CommandCode matching the Idris2 ABI tags.
enum CommandCode {
  printJob(1),
  receiveJob(2),
  shortQueue(3),
  longQueue(4),
  removeJobs(5);

  const CommandCode(this.tag);
  final int tag;

  static CommandCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SubCommandCode matching the Idris2 ABI tags.
enum SubCommandCode {
  abortJob(1),
  controlFile(2),
  dataFile(3);

  const SubCommandCode(this.tag);
  final int tag;

  static SubCommandCode? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// JobStatus matching the Idris2 ABI tags.
enum JobStatus {
  pending(0),
  printing(1),
  complete(2),
  failed(3);

  const JobStatus(this.tag);
  final int tag;

  static JobStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
