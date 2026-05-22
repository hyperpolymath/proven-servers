// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SNMP protocol types for proven-servers.

/// Version matching the Idris2 ABI tags.
enum Version {
  v1(0),
  v2c(1),
  v3(2);

  const Version(this.tag);
  final int tag;

  static Version? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// PduType matching the Idris2 ABI tags.
enum PduType {
  getRequest(0),
  getNextRequest(1),
  getResponse(2),
  setRequest(3),
  getBulkRequest(4),
  informRequest(5),
  snmpV2Trap(6);

  const PduType(this.tag);
  final int tag;

  static PduType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ErrorStatus matching the Idris2 ABI tags.
enum ErrorStatus {
  noError(0),
  tooBig(1),
  noSuchName(2),
  badValue(3),
  readOnly(4),
  genErr(5),
  noAccess(6),
  wrongType(7),
  wrongLength(8),
  wrongValue(9),
  noCreation(10),
  inconsistentValue(11),
  resourceUnavailable(12),
  commitFailed(13),
  undoFailed(14),
  authorizationError(15);

  const ErrorStatus(this.tag);
  final int tag;

  static ErrorStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
