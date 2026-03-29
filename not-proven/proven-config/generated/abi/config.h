/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * config.h — C-ABI header for proven-config.
 * Generated from ConfigABI.Layout.idr and ConfigABI.Transitions.idr tag
 * assignments.
 *
 * Tag values here MUST match:
 *   - Idris2 ABI (src/ConfigABI/Layout.idr, src/ConfigABI/Transitions.idr)
 *   - Zig FFI   (ffi/zig/src/config.zig)
 */

#ifndef PROVEN_CONFIG_H
#define PROVEN_CONFIG_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ── ConfigSource (5 constructors, tags 0-4) ────────────────────────── */
#define CONFIG_SRC_FILE        0
#define CONFIG_SRC_ENVIRONMENT 1
#define CONFIG_SRC_COMMANDLINE 2
#define CONFIG_SRC_DEFAULT     3
#define CONFIG_SRC_REMOTE      4

/* ── ValidationResult (6 constructors, tags 0-5) ────────────────────── */
#define CONFIG_VAL_VALID              0
#define CONFIG_VAL_INVALID_VALUE      1
#define CONFIG_VAL_MISSING_REQUIRED   2
#define CONFIG_VAL_SECURITY_VIOLATION 3
#define CONFIG_VAL_TYPE_MISMATCH      4
#define CONFIG_VAL_OUT_OF_RANGE       5

/* ── SecurityPolicy (5 constructors, tags 0-4) ──────────────────────── */
#define CONFIG_POL_REQUIRE_TLS        0
#define CONFIG_POL_REQUIRE_AUTH       1
#define CONFIG_POL_REQUIRE_ENCRYPTION 2
#define CONFIG_POL_ALLOW_PLAINTEXT    3
#define CONFIG_POL_ALLOW_ANONYMOUS    4

/* ── OverrideLevel (4 constructors, tags 0-3) ───────────────────────── */
#define CONFIG_OVR_DEFAULT   0
#define CONFIG_OVR_USER      1
#define CONFIG_OVR_ADMIN     2
#define CONFIG_OVR_EMERGENCY 3

/* ── ConfigError (5 constructors, tags 0-4) ─────────────────────────── */
#define CONFIG_ERR_PARSE_ERROR        0
#define CONFIG_ERR_SCHEMA_VIOLATION   1
#define CONFIG_ERR_SECURITY_DOWNGRADE 2
#define CONFIG_ERR_CONFLICTING_VALUES 3
#define CONFIG_ERR_UNKNOWN_KEY        4
#define CONFIG_ERR_NONE               255

/* ── ConfigState (7 constructors, tags 0-6) ─────────────────────────── */
#define CONFIG_STATE_UNINITIALISED 0
#define CONFIG_STATE_LOADING       1
#define CONFIG_STATE_VALIDATING    2
#define CONFIG_STATE_ACTIVE        3
#define CONFIG_STATE_FROZEN        4
#define CONFIG_STATE_INVALID       5
#define CONFIG_STATE_ERRORED       6

/* ── ABI ────────────────────────────────────────────────────────────── */
uint32_t config_abi_version(void);

/* ── Lifecycle ──────────────────────────────────────────────────────── */
int      config_create(uint8_t source);
void     config_destroy(int slot);

/* ── State queries ──────────────────────────────────────────────────── */
uint8_t  config_state(int slot);
uint8_t  config_source(int slot);
uint8_t  config_policy(int slot);
uint8_t  config_override_level(int slot);
uint8_t  config_last_error(int slot);

/* ── Transitions ────────────────────────────────────────────────────── */
uint8_t config_load(int slot);
uint8_t config_validate(int slot);
uint8_t config_accept(int slot);
uint8_t config_reject(int slot, uint8_t err_tag);
uint8_t config_reload(int slot);
uint8_t config_lock(int slot);
uint8_t config_unlock(int slot);
uint8_t config_reset(int slot);
uint8_t config_error(int slot, uint8_t err_tag);

/* ── Setters (Active state only) ────────────────────────────────────── */
uint8_t config_set_policy(int slot, uint8_t policy_tag);
uint8_t config_set_override(int slot, uint8_t level_tag);

/* ── Stateless queries ──────────────────────────────────────────────── */
uint8_t config_can_transition(uint8_t from, uint8_t to);
uint8_t config_is_restrictive(uint8_t policy_tag);
uint8_t config_override_dominates(uint8_t a, uint8_t b);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_CONFIG_H */
