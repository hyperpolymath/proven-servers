/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * graphql.h -- C-ABI header for proven-graphql.
 * Generated from GraphQLABI.Layout.idr and GraphQLABI.Transitions.idr tag assignments.
 */

#ifndef PROVEN_GRAPHQL_H
#define PROVEN_GRAPHQL_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- OperationType (3 constructors, tags 0-2) ----------------------------- */
#define GQL_OP_QUERY        0
#define GQL_OP_MUTATION     1
#define GQL_OP_SUBSCRIPTION 2

/* -- TypeKind (8 constructors, tags 0-7) ---------------------------------- */
#define GQL_TK_SCALAR       0
#define GQL_TK_OBJECT       1
#define GQL_TK_INTERFACE    2
#define GQL_TK_UNION        3
#define GQL_TK_ENUM         4
#define GQL_TK_INPUT_OBJECT 5
#define GQL_TK_LIST         6
#define GQL_TK_NON_NULL     7

/* -- ScalarKind (6 constructors, tags 0-5) -------------------------------- */
#define GQL_SK_INT     0
#define GQL_SK_FLOAT   1
#define GQL_SK_STRING  2
#define GQL_SK_BOOLEAN 3
#define GQL_SK_ID      4
#define GQL_SK_CUSTOM  5

/* -- DirectiveLocation (18 constructors, tags 0-17) ----------------------- */
/* Executable locations */
#define GQL_DL_QUERY                  0
#define GQL_DL_MUTATION               1
#define GQL_DL_SUBSCRIPTION           2
#define GQL_DL_FIELD                  3
#define GQL_DL_FRAGMENT_DEFINITION    4
#define GQL_DL_FRAGMENT_SPREAD        5
#define GQL_DL_INLINE_FRAGMENT        6
/* Type system locations */
#define GQL_DL_SCHEMA                 7
#define GQL_DL_SCALAR                 8
#define GQL_DL_OBJECT                 9
#define GQL_DL_FIELD_DEFINITION       10
#define GQL_DL_ARGUMENT_DEFINITION    11
#define GQL_DL_INTERFACE              12
#define GQL_DL_UNION                  13
#define GQL_DL_ENUM                   14
#define GQL_DL_ENUM_VALUE             15
#define GQL_DL_INPUT_OBJECT           16
#define GQL_DL_INPUT_FIELD_DEFINITION 17

/* -- ErrorCategory (5 constructors, tags 0-4) ----------------------------- */
#define GQL_ERR_PARSE      0
#define GQL_ERR_VALIDATION 1
#define GQL_ERR_EXECUTION  2
#define GQL_ERR_AUTH       3
#define GQL_ERR_RATE       4

/* -- RequestPhase (6 constructors, tags 0-5) ------------------------------ */
#define GQL_PHASE_PARSE     0
#define GQL_PHASE_VALIDATE  1
#define GQL_PHASE_EXECUTE   2
#define GQL_PHASE_RESOLVE   3
#define GQL_PHASE_SERIALIZE 4
#define GQL_PHASE_FAILED    5

/* -- SubscriptionPhase (4 constructors, tags 0-3) ------------------------- */
#define GQL_SUB_SUBSCRIBE   0
#define GQL_SUB_ACTIVE      1
#define GQL_SUB_UNSUBSCRIBE 2
#define GQL_SUB_FAILED      3

/* -- IntrospectionField (3 constructors, tags 0-2) ------------------------ */
#define GQL_INTRO_SCHEMA   0
#define GQL_INTRO_TYPE     1
#define GQL_INTRO_TYPENAME 2

/* -- BatchStatus (4 constructors, tags 0-3) ------------------------------- */
#define GQL_BATCH_PENDING   0
#define GQL_BATCH_RUNNING   1
#define GQL_BATCH_COMPLETE  2
#define GQL_BATCH_FAILED    3

/* -- Sentinel values ------------------------------------------------------ */
#define GQL_INVALID 255

/* -- ABI ------------------------------------------------------------------ */
uint32_t graphql_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      graphql_create(uint8_t op_type);
void     graphql_destroy(int slot);

/* -- State queries -------------------------------------------------------- */
uint8_t  graphql_phase(int slot);
uint8_t  graphql_operation_type(int slot);
uint8_t  graphql_error_category(int slot);

/* -- Request phase transitions -------------------------------------------- */
uint8_t  graphql_advance(int slot);
uint8_t  graphql_abort(int slot, uint8_t err_cat);

/* -- Query parser state --------------------------------------------------- */
uint8_t  graphql_set_query_depth(int slot, uint16_t depth);
uint16_t graphql_query_depth(int slot);
uint8_t  graphql_set_complexity(int slot, uint16_t score);
uint16_t graphql_complexity(int slot);

/* -- Field resolver ------------------------------------------------------- */
uint8_t  graphql_resolve_field(int slot, uint8_t type_kind, uint8_t scalar_kind);
uint16_t graphql_fields_resolved(int slot);

/* -- Stateless transition checks ------------------------------------------ */
uint8_t  graphql_can_transition(uint8_t from, uint8_t to);

/* -- Subscription management ---------------------------------------------- */
int      graphql_sub_create(int slot);
uint8_t  graphql_sub_phase(int slot);
uint8_t  graphql_sub_advance(int slot);
uint8_t  graphql_sub_emit_event(int slot);
uint8_t  graphql_sub_abort(int slot);
uint32_t graphql_sub_event_count(int slot);
uint8_t  graphql_sub_can_transition(uint8_t from, uint8_t to);

/* -- Introspection -------------------------------------------------------- */
uint8_t  graphql_introspection_query(int slot, uint8_t intro_field);

/* -- Batch query support -------------------------------------------------- */
int      graphql_batch_create(uint8_t count);
uint8_t  graphql_batch_set_op(int batch_id, uint8_t index, uint8_t op_type);
uint8_t  graphql_batch_status(int batch_id);
uint8_t  graphql_batch_query_status(int batch_id, uint8_t index);
uint8_t  graphql_batch_advance(int batch_id);
void     graphql_batch_destroy(int batch_id);

/* -- Depth/complexity limit checks (stateless) ---------------------------- */
uint8_t  graphql_check_depth(uint16_t depth, uint16_t max_depth);
uint8_t  graphql_check_complexity(uint16_t score, uint16_t max_complexity);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_GRAPHQL_H */
