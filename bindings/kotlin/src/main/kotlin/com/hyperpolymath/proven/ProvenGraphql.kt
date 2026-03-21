// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Kotlin/JNI bindings for the proven-graphql protocol.
// Wraps the C-ABI functions from protocols/proven-graphql/ffi/zig/src/graphql.zig.
// Enum classes match Idris2 ABI tags exactly (GraphqlABI.Layout).

package com.hyperpolymath.proven

/**
 * Kotlin bindings for the proven GraphQL server protocol.
 *
 * Lifecycle: Received -> Parsed -> Executing -> Complete (or Error).
 *
 * @author Jonathan D.A. Jewell
 */
public class ProvenGraphql private constructor(private val slot: Int) : AutoCloseable {

    /** GraphQL request lifecycle phases (tags 0-4). */
    public enum class Phase(public val tag: Int) {
        RECEIVED(0), PARSED(1), EXECUTING(2), COMPLETE(3), ERROR(4);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): Phase? = entries.find { it.tag == tag }
        }
    }

    /** GraphQL operation types (tags 0-2). */
    public enum class OperationType(public val tag: Int) {
        QUERY(0), MUTATION(1), SUBSCRIPTION(2);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): OperationType? = entries.find { it.tag == tag }
        }
    }

    private companion object {
        @JvmStatic external fun graphql_abi_version(): Int
        @JvmStatic external fun graphql_create(opType: Int): Int
        @JvmStatic external fun graphql_destroy(slot: Int)
        @JvmStatic external fun graphql_phase(slot: Int): Int
        @JvmStatic external fun graphql_operation_type(slot: Int): Int
        @JvmStatic external fun graphql_error_category(slot: Int): Int
        @JvmStatic external fun graphql_advance(slot: Int): Int
        @JvmStatic external fun graphql_abort(slot: Int, errCat: Int): Int
        @JvmStatic external fun graphql_set_query_depth(slot: Int, depth: Int): Int
        @JvmStatic external fun graphql_query_depth(slot: Int): Int
        @JvmStatic external fun graphql_set_complexity(slot: Int, score: Int): Int
        @JvmStatic external fun graphql_complexity(slot: Int): Int
        @JvmStatic external fun graphql_resolve_field(slot: Int, typeKind: Int, scalarKind: Int): Int
        @JvmStatic external fun graphql_fields_resolved(slot: Int): Int
        @JvmStatic external fun graphql_can_transition(from: Int, to: Int): Int
        @JvmStatic external fun graphql_sub_create(slot: Int): Int
        @JvmStatic external fun graphql_sub_phase(slot: Int): Int
        @JvmStatic external fun graphql_sub_advance(slot: Int): Int
        @JvmStatic external fun graphql_sub_emit_event(slot: Int): Int
        @JvmStatic external fun graphql_sub_abort(slot: Int): Int
        @JvmStatic external fun graphql_sub_event_count(slot: Int): Int
        @JvmStatic external fun graphql_sub_can_transition(from: Int, to: Int): Int
        @JvmStatic external fun graphql_introspection_query(slot: Int, introField: Int): Int
        @JvmStatic external fun graphql_check_depth(depth: Int, maxDepth: Int): Int
        @JvmStatic external fun graphql_check_complexity(score: Int, maxComplexity: Int): Int
    }

    override fun close() { graphql_destroy(slot) }

    public val phase: Phase? get() = Phase.fromTag(graphql_phase(slot))
    public val operationType: OperationType? get() = OperationType.fromTag(graphql_operation_type(slot))
    public val errorCategory: Int get() = graphql_error_category(slot)
    public val queryDepth: Int get() = graphql_query_depth(slot)
    public val complexity: Int get() = graphql_complexity(slot)
    public val fieldsResolved: Int get() = graphql_fields_resolved(slot)
    public val subscriptionPhase: Int get() = graphql_sub_phase(slot)
    public val subscriptionEventCount: Int get() = graphql_sub_event_count(slot)

    public fun advance(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(graphql_advance(slot)) }
    public fun abort(errorCategory: Int): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(graphql_abort(slot, errorCategory)) }
    public fun setQueryDepth(depth: Int): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(graphql_set_query_depth(slot, depth)) }
    public fun setComplexity(score: Int): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(graphql_set_complexity(slot, score)) }
    public fun resolveField(typeKind: Int, scalarKind: Int): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(graphql_resolve_field(slot, typeKind, scalarKind)) }

    public fun createSubscription(): Result<Int> = ProvenError.runCatching { ProvenError.checkSlot(graphql_sub_create(slot)) }
    public fun subscriptionAdvance(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(graphql_sub_advance(slot)) }
    public fun subscriptionEmitEvent(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(graphql_sub_emit_event(slot)) }
    public fun subscriptionAbort(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(graphql_sub_abort(slot)) }
    public fun introspectionQuery(field: Int): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(graphql_introspection_query(slot, field)) }

    public companion object {
        @JvmStatic public fun create(operationType: OperationType = OperationType.QUERY): Result<ProvenGraphql> = ProvenError.runCatching {
            ProvenGraphql(ProvenError.checkSlot(graphql_create(operationType.tag)))
        }

        @JvmStatic public fun abiVersion(): Int = graphql_abi_version()

        @JvmStatic public fun canTransition(from: Phase, to: Phase): Boolean =
            graphql_can_transition(from.tag, to.tag) == 1

        @JvmStatic public fun checkDepth(depth: Int, maxDepth: Int): Boolean =
            graphql_check_depth(depth, maxDepth) == 1

        @JvmStatic public fun checkComplexity(score: Int, maxComplexity: Int): Boolean =
            graphql_check_complexity(score, maxComplexity) == 1
    }
}
