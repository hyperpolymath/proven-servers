// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// Backup protocol types for proven-servers.

/** BackupType matching the Idris2 ABI tags. */
export const BackupType = Object.freeze({
  FULL: 0,
  INCREMENTAL: 1,
  DIFFERENTIAL: 2,
  SNAPSHOT: 3,
  MIRROR: 4,
});

/** ScheduleFreq matching the Idris2 ABI tags. */
export const ScheduleFreq = Object.freeze({
  HOURLY: 0,
  DAILY: 1,
  WEEKLY: 2,
  MONTHLY: 3,
  ON_DEMAND: 4,
});

/** CompressionAlg matching the Idris2 ABI tags. */
export const CompressionAlg = Object.freeze({
  NONE: 0,
  GZIP: 1,
  ZSTD: 2,
  LZ4: 3,
  XZ: 4,
});

/** EncryptionAlg matching the Idris2 ABI tags. */
export const EncryptionAlg = Object.freeze({
  NO_ENCRYPTION: 0,
  AES256_GCM: 1,
  CHA_CHA20_POLY1305: 2,
});

/** BackupState matching the Idris2 ABI tags. */
export const BackupState = Object.freeze({
  IDLE: 0,
  RUNNING: 1,
  VERIFYING: 2,
  COMPLETE: 3,
  FAILED: 4,
  CANCELLED: 5,
});

/** RetentionPolicy matching the Idris2 ABI tags. */
export const RetentionPolicy = Object.freeze({
  KEEP_ALL: 0,
  KEEP_LAST: 1,
  KEEP_DAILY: 2,
  KEEP_WEEKLY: 3,
  KEEP_MONTHLY: 4,
});
