/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * audit.h — C-ABI header for proven-audit.
 * Generated from AuditABI.Layout.idr tag assignments.
 *
 * Tag values here MUST match:
 *   - Idris2 ABI (src/AuditABI/Layout.idr)
 *   - Zig FFI   (ffi/zig/src/audit.zig)
 */

#ifndef PROVEN_AUDIT_H
#define PROVEN_AUDIT_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ── AuditLevel (5 constructors, tags 0-4) ───────────────────────────── */
#define AUDIT_LEVEL_NONE     0
#define AUDIT_LEVEL_MINIMAL  1
#define AUDIT_LEVEL_STANDARD 2
#define AUDIT_LEVEL_VERBOSE  3
#define AUDIT_LEVEL_FULL     4

/* ── EventCategory (8 constructors, tags 0-7) ────────────────────────── */
#define AUDIT_CAT_STATE_TRANSITION 0
#define AUDIT_CAT_AUTHENTICATION   1
#define AUDIT_CAT_AUTHORIZATION    2
#define AUDIT_CAT_DATA_ACCESS      3
#define AUDIT_CAT_CONFIGURATION    4
#define AUDIT_CAT_ERROR            5
#define AUDIT_CAT_SECURITY         6
#define AUDIT_CAT_LIFECYCLE        7

/* ── Integrity (5 constructors, tags 0-4) ────────────────────────────── */
#define AUDIT_INTEGRITY_UNSIGNED     0
#define AUDIT_INTEGRITY_HMAC         1
#define AUDIT_INTEGRITY_SIGNED       2
#define AUDIT_INTEGRITY_CHAINED      3
#define AUDIT_INTEGRITY_MERKLE_PROOF 4

/* ── RetentionPolicy (5 constructors, tags 0-4) ─────────────────────── */
#define AUDIT_RETENTION_EPHEMERAL  0
#define AUDIT_RETENTION_SESSION    1
#define AUDIT_RETENTION_DAILY      2
#define AUDIT_RETENTION_INDEFINITE 3
#define AUDIT_RETENTION_REGULATORY 4

/* ── AuditError (5 constructors, tags 0-4) ───────────────────────────── */
#define AUDIT_ERR_STORAGE_FULL        0
#define AUDIT_ERR_WRITE_FAILURE       1
#define AUDIT_ERR_INTEGRITY_VIOLATION 2
#define AUDIT_ERR_TIMESTAMP_ERROR     3
#define AUDIT_ERR_CHAIN_BROKEN        4
#define AUDIT_ERR_OK                  255

/* ── AuditTrailState (5 constructors, tags 0-4) ─────────────────────── */
#define AUDIT_STATE_IDLE      0
#define AUDIT_STATE_RECORDING 1
#define AUDIT_STATE_SEALED    2
#define AUDIT_STATE_ARCHIVED  3
#define AUDIT_STATE_FAILED    4

/* ── ABI ─────────────────────────────────────────────────────────────── */
uint32_t audit_abi_version(void);

/* ── Lifecycle ───────────────────────────────────────────────────────── */
int      audit_create(uint8_t level, uint8_t integrity, uint8_t retention);
void     audit_destroy(int slot);

/* ── State queries ───────────────────────────────────────────────────── */
uint8_t  audit_state(int slot);
uint8_t  audit_last_error(int slot);
uint32_t audit_event_count(int slot);
uint8_t  audit_level(int slot);
uint8_t  audit_integrity(int slot);
uint8_t  audit_retention(int slot);

/* ── Transitions ─────────────────────────────────────────────────────── */
uint8_t audit_open(int slot);
uint8_t audit_seal(int slot);
uint8_t audit_archive(int slot);
uint8_t audit_fail(int slot, uint8_t err_tag);
uint8_t audit_reset(int slot);

/* ── Event recording ─────────────────────────────────────────────────── */
uint8_t audit_record_event(int slot, uint8_t category);

/* ── Stateless validation ────────────────────────────────────────────── */
uint8_t audit_can_transition(uint8_t from, uint8_t to);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_AUDIT_H */
