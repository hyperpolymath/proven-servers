// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Backup protocol types for proven-servers.

/// BackupType matching the Idris2 ABI tags.
enum BackupType {
  full(0),
  incremental(1),
  differential(2),
  snapshot(3),
  mirror(4);

  const BackupType(this.tag);
  final int tag;

  static BackupType? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// ScheduleFreq matching the Idris2 ABI tags.
enum ScheduleFreq {
  hourly(0),
  daily(1),
  weekly(2),
  monthly(3),
  onDemand(4);

  const ScheduleFreq(this.tag);
  final int tag;

  static ScheduleFreq? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// CompressionAlg matching the Idris2 ABI tags.
enum CompressionAlg {
  none(0),
  gzip(1),
  zstd(2),
  lz4(3),
  xz(4);

  const CompressionAlg(this.tag);
  final int tag;

  static CompressionAlg? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// EncryptionAlg matching the Idris2 ABI tags.
enum EncryptionAlg {
  noEncryption(0),
  aes256Gcm(1),
  chaCha20Poly1305(2);

  const EncryptionAlg(this.tag);
  final int tag;

  static EncryptionAlg? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// BackupState matching the Idris2 ABI tags.
enum BackupState {
  idle(0),
  running(1),
  verifying(2),
  complete(3),
  failed(4),
  cancelled(5);

  const BackupState(this.tag);
  final int tag;

  static BackupState? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}

/// RetentionPolicy matching the Idris2 ABI tags.
enum RetentionPolicy {
  keepAll(0),
  keepLast(1),
  keepDaily(2),
  keepWeekly(3),
  keepMonthly(4);

  const RetentionPolicy(this.tag);
  final int tag;

  static RetentionPolicy? fromTag(int tag) {
    for (final v in values) {
      if (v.tag == tag) return v;
    }
    return null;
  }
}
