// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CT Log protocol types for proven-servers.

/// LogEntryType matching the Idris2 ABI tags.
enum LogEntryType {
  x509Entry(0),
  precertEntry(1);

  const LogEntryType(this.tag);
  final int tag;

  static LogEntryType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SignatureType matching the Idris2 ABI tags.
enum SignatureType {
  certificateTimestamp(0),
  treeHash(1);

  const SignatureType(this.tag);
  final int tag;

  static SignatureType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// MerkleLeafType matching the Idris2 ABI tags.
enum MerkleLeafType {
  timestampedEntry(0);

  const MerkleLeafType(this.tag);
  final int tag;

  static MerkleLeafType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// SubmissionStatus matching the Idris2 ABI tags.
enum SubmissionStatus {
  accepted(0),
  duplicate(1),
  rateLimited(2),
  rejected(3),
  invalidChain(4),
  unknownAnchor(5);

  const SubmissionStatus(this.tag);
  final int tag;

  static SubmissionStatus? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// VerificationResult matching the Idris2 ABI tags.
enum VerificationResult {
  validProof(0),
  invalidProof(1),
  inconsistentTree(2),
  staleSth(3);

  const VerificationResult(this.tag);
  final int tag;

  static VerificationResult? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ServerState matching the Idris2 ABI tags.
enum ServerState {
  idle(0),
  active(1),
  merging(2),
  signing(3),
  shutdown(4);

  const ServerState(this.tag);
  final int tag;

  static ServerState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
