// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Air Gap protocol types for proven-servers.

/** TransferDirection matching the Idris2 ABI tags. */
export const TransferDirection = Object.freeze({
  IMPORT: 0,
  EXPORT: 1,
});

/** MediaType matching the Idris2 ABI tags. */
export const MediaType = Object.freeze({
  USB: 0,
  OPTICAL_DISC: 1,
  TAPE_CARTRIDGE: 2,
  DIODE_LINK: 3,
});

/** ScanResult matching the Idris2 ABI tags. */
export const ScanResult = Object.freeze({
  CLEAN: 0,
  SUSPICIOUS: 1,
  MALICIOUS: 2,
  UNSCANNABLE: 3,
});

/** TransferState matching the Idris2 ABI tags. */
export const TransferState = Object.freeze({
  PENDING: 0,
  SCANNING: 1,
  APPROVED: 2,
  REJECTED: 3,
  IN_PROGRESS: 4,
  COMPLETE: 5,
  FAILED: 6,
});

/** ValidationCheck matching the Idris2 ABI tags. */
export const ValidationCheck = Object.freeze({
  HASH_VERIFY: 0,
  SIGNATURE_VERIFY: 1,
  FORMAT_CHECK: 2,
  CONTENT_INSPECTION: 3,
  MALWARE_SCAN: 4,
});
