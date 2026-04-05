/*
 * SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * proven-nesy-solver-api ABI -- C header mirroring Idris2 type definitions.
 * DO NOT EDIT -- regenerate from src/NesySolverAPIABI/ if types change.
 *
 * ABI Version: 0.1
 *
 * Tag values here MUST match src/NesySolverAPIABI/Layout.idr and
 * ffi/zig/src/nesy_solver_api.zig exactly.
 *
 * Type tag consistency map:
 *   ProverKind:       tags 0-8  (9 provers)
 *   InputLanguage:    tags 0-4  (5 source languages)
 *   ObligationClass:  tags 0-10 (11 classes, mirrors verisimdb Enum8)
 *   ProveOutcome:     tags 0-3  (success/failure/timeout/unknown)
 *   SessionState:     tags 0-3  (Idle/Dispatching/Recording/FailedS)
 *   SurfaceKind:      tags 0-15 (16 hexadeca protocol surfaces)
 */

#ifndef PROVEN_NESY_SOLVER_API_H
#define PROVEN_NESY_SOLVER_API_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ---- ABI version ---- */
#define PROVEN_NESY_SOLVER_API_ABI_VERSION_MAJOR 0
#define PROVEN_NESY_SOLVER_API_ABI_VERSION_MINOR 1

/* ---- ProverKind (1 byte, tags 0-8) ---- */
typedef uint8_t nesy_prover_t;
#define NESY_PROVER_Z3        0
#define NESY_PROVER_CVC5      1
#define NESY_PROVER_COQ       2
#define NESY_PROVER_LEAN      3
#define NESY_PROVER_IDRIS2    4
#define NESY_PROVER_AGDA      5
#define NESY_PROVER_ISABELLE  6
#define NESY_PROVER_DAFNY     7
#define NESY_PROVER_FSTAR     8

/* ---- InputLanguage (1 byte, tags 0-4) ---- */
typedef uint8_t nesy_language_t;
#define NESY_LANG_SMTLIB      0
#define NESY_LANG_LEAN        1
#define NESY_LANG_COQ         2
#define NESY_LANG_IDRIS2      3
#define NESY_LANG_AGDA        4

/* ---- ObligationClass (1 byte, tags 0-10) ---- */
typedef uint8_t nesy_class_t;
#define NESY_CLASS_SAFETY         0
#define NESY_CLASS_LINEARITY      1
#define NESY_CLASS_TERMINATION    2
#define NESY_CLASS_EQUIV          3
#define NESY_CLASS_CORRECTNESS    4
#define NESY_CLASS_CONFLUENCE     5
#define NESY_CLASS_TOTALITY       6
#define NESY_CLASS_INVARIANT      7
#define NESY_CLASS_REFINEMENT     8
#define NESY_CLASS_MODEL_CHECK    9
#define NESY_CLASS_OTHER         10

/* ---- ProveOutcome (1 byte, tags 0-3) ---- */
typedef uint8_t nesy_outcome_t;
#define NESY_OUTCOME_SUCCESS  0
#define NESY_OUTCOME_FAILURE  1
#define NESY_OUTCOME_TIMEOUT  2
#define NESY_OUTCOME_UNKNOWN  3

/* ---- SessionState (1 byte, tags 0-3) ---- */
typedef uint8_t nesy_session_state_t;
#define NESY_STATE_IDLE         0
#define NESY_STATE_DISPATCHING  1
#define NESY_STATE_RECORDING    2
#define NESY_STATE_FAILED       3

/* ---- SurfaceKind (1 byte, tags 0-15) ---- */
typedef uint8_t nesy_surface_t;
#define NESY_SURFACE_REST         0
#define NESY_SURFACE_GRAPHQL      1
#define NESY_SURFACE_WEBSOCKET    2
#define NESY_SURFACE_SSE          3
#define NESY_SURFACE_GRPC         4
#define NESY_SURFACE_JSONRPC      5
#define NESY_SURFACE_MSGPACK_RPC  6
#define NESY_SURFACE_CBOR         7
#define NESY_SURFACE_FLATBUFFERS  8
#define NESY_SURFACE_CAPNPROTO    9
#define NESY_SURFACE_BEBOP       10
#define NESY_SURFACE_TRPC        11
#define NESY_SURFACE_MQTT        12
#define NESY_SURFACE_AMQP        13
#define NESY_SURFACE_SOAP        14
#define NESY_SURFACE_VERISIMDB   15

/* ---- Opaque handles ---- */
typedef struct nesy_session  nesy_session_t;
typedef struct nesy_dispatch nesy_dispatch_t;

/* ---- Session lifecycle ---- */
nesy_session_t *nesy_session_open(void);
void            nesy_session_close(nesy_session_t *s);
nesy_session_state_t nesy_session_state(const nesy_session_t *s);

/* ---- Dispatch ---- */
nesy_dispatch_t *nesy_dispatch_begin(
    nesy_session_t *s,
    nesy_prover_t prover,
    nesy_language_t language,
    nesy_class_t obligation_class,
    const uint8_t *content,
    size_t content_len);

nesy_outcome_t nesy_dispatch_poll(const nesy_dispatch_t *d);
uint64_t       nesy_dispatch_duration_ms(const nesy_dispatch_t *d);
void           nesy_dispatch_end(nesy_dispatch_t *d);

/* ---- Utilities ---- */
/* Computes SHA-256 of (content, content_len) into out (64 hex chars + NUL).
 * out must be at least 65 bytes. Returns 0 on success, -1 on error. */
int nesy_obligation_hash(const uint8_t *content, size_t content_len,
                         char *out, size_t out_len);

/* Strategy recommendation: returns the top ProverKind tag for a class,
 * or 0xFF if no data is available. */
nesy_prover_t nesy_strategy_lookup(nesy_class_t obligation_class);

/* Record an attempt into verisim-api. Caller owns all pointers.
 * started_at / completed_at are ISO-8601 without trailing Z (ClickHouse format).
 * Returns true on success. */
bool nesy_record_attempt(
    nesy_session_t *s,
    const char *attempt_id,
    const char *obligation_id,
    const char *repo,
    const char *file,
    const char *claim,
    nesy_class_t obligation_class,
    nesy_prover_t prover,
    nesy_outcome_t outcome,
    uint64_t duration_ms,
    double confidence,
    const char *strategy_tag,
    const char *started_at,
    const char *completed_at);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_NESY_SOLVER_API_H */
