/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * fsm.h — C-ABI header for proven-fsm.
 * Generated from FSMABI.Layout.idr tag assignments.
 *
 * Tag values here MUST match:
 *   - Idris2 ABI (src/FSMABI/Layout.idr)
 *   - Zig FFI   (ffi/zig/src/fsm.zig)
 */

#ifndef PROVEN_FSM_H
#define PROVEN_FSM_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ── TransitionResult (3 constructors, tags 0-2) ─────────────────────── */
#define FSM_RESULT_ACCEPTED  0
#define FSM_RESULT_REJECTED  1
#define FSM_RESULT_DEFERRED  2

/* ── ValidationError (4 constructors, tags 0-3) ──────────────────────── */
#define FSM_ERR_INVALID_TRANSITION   0
#define FSM_ERR_PRECONDITION_FAILED  1
#define FSM_ERR_POSTCONDITION_FAILED 2
#define FSM_ERR_GUARD_FAILED         3
#define FSM_ERR_NONE                 255

/* ── MachineState (4 constructors, tags 0-3) ─────────────────────────── */
#define FSM_STATE_INITIAL  0
#define FSM_STATE_RUNNING  1
#define FSM_STATE_TERMINAL 2
#define FSM_STATE_FAULTED  3

/* ── EventDisposition (4 constructors, tags 0-3) ─────────────────────── */
#define FSM_EVENT_CONSUMED 0
#define FSM_EVENT_IGNORED  1
#define FSM_EVENT_QUEUED   2
#define FSM_EVENT_DROPPED  3

/* ── Opaque handle ───────────────────────────────────────────────────── */
typedef struct fsm_machine* fsm_handle_t;

/* ── ABI version ─────────────────────────────────────────────────────── */
uint32_t fsm_abi_version(void);

/* ── Lifecycle ───────────────────────────────────────────────────────── */
fsm_handle_t fsm_create(uint16_t max_states, uint32_t max_transitions);
void         fsm_destroy(fsm_handle_t h);

/* ── State queries ───────────────────────────────────────────────────── */
uint8_t fsm_state(fsm_handle_t h);
uint8_t fsm_last_error(fsm_handle_t h);

/* ── Transitions ─────────────────────────────────────────────────────── */
uint8_t fsm_start(fsm_handle_t h);
uint8_t fsm_complete(fsm_handle_t h);
uint8_t fsm_fault(fsm_handle_t h);
uint8_t fsm_reset(fsm_handle_t h);

/* ── Event processing ────────────────────────────────────────────────── */
uint8_t fsm_submit_event(fsm_handle_t h, uint32_t event_id);

/* ── Stateless validation ────────────────────────────────────────────── */
uint8_t fsm_can_transition(uint8_t from, uint8_t to);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_FSM_H */
