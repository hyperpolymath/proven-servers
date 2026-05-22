// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Air Gap protocol types for proven-servers.

/// TransferDirection matching the Idris2 ABI tags.
enum TransferDirection {
  import_(0),
  export_(1);

  const TransferDirection(this.tag);
  final int tag;

  static TransferDirection? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// MediaType matching the Idris2 ABI tags.
enum MediaType {
  usb(0),
  opticalDisc(1),
  tapeCartridge(2),
  diodeLink(3);

  const MediaType(this.tag);
  final int tag;

  static MediaType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ScanResult matching the Idris2 ABI tags.
enum ScanResult {
  clean(0),
  suspicious(1),
  malicious(2),
  unscannable(3);

  const ScanResult(this.tag);
  final int tag;

  static ScanResult? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// TransferState matching the Idris2 ABI tags.
enum TransferState {
  pending(0),
  scanning(1),
  approved(2),
  rejected(3),
  inProgress(4),
  complete(5),
  failed(6);

  const TransferState(this.tag);
  final int tag;

  static TransferState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ValidationCheck matching the Idris2 ABI tags.
enum ValidationCheck {
  hashVerify(0),
  signatureVerify(1),
  formatCheck(2),
  contentInspection(3),
  malwareScan(4);

  const ValidationCheck(this.tag);
  final int tag;

  static ValidationCheck? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
