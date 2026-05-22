// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Java JNI bindings for the proven-graphql protocol.
// Wraps the C-ABI functions from protocols/proven-graphql/ffi/zig/src/graphql.zig.

package com.hyperpolymath.proven;

/**
 * Java bindings for the proven GraphQL server protocol.
 *
 * <p>Request lifecycle: Received -&gt; Parsed -&gt; Executing -&gt; Complete/Error.
 * Includes subscription, introspection, depth/complexity checking.</p>
 *
 * @author Jonathan D.A. Jewell
 */
public final class ProvenGraphql {

    private ProvenGraphql() {}

    // -----------------------------------------------------------------------
    // Enums
    // -----------------------------------------------------------------------

    /** GraphQL request phases (tags 0-4). */
    public enum Phase {
        RECEIVED(0), PARSED(1), EXECUTING(2), COMPLETE(3), ERROR(4);

        private final int tag;
        Phase(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Phase fromTag(int tag) {
            for (Phase p : values()) {
                if (p.tag == tag) return p;
            }
            return null;
        }
    }

    /** GraphQL operation types. */
    public enum OperationType {
        QUERY(0), MUTATION(1), SUBSCRIPTION(2);

        private final int tag;
        OperationType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static OperationType fromTag(int tag) {
            for (OperationType o : values()) {
                if (o.tag == tag) return o;
            }
            return null;
        }
    }

    // -----------------------------------------------------------------------
    // JNI native methods
    // -----------------------------------------------------------------------

    private static native int nativeAbiVersion();
    private static native int nativeCreate(int opType);
    private static native void nativeDestroy(int slot);
    private static native int nativePhase(int slot);
    private static native int nativeOperationType(int slot);
    private static native int nativeErrorCategory(int slot);
    private static native int nativeAdvance(int slot);
    private static native int nativeAbort(int slot, int errCat);
    private static native int nativeSetQueryDepth(int slot, int depth);
    private static native int nativeQueryDepth(int slot);
    private static native int nativeSetComplexity(int slot, int score);
    private static native int nativeComplexity(int slot);
    private static native int nativeResolveField(int slot, int typeKind, int scalarKind);
    private static native int nativeFieldsResolved(int slot);
    private static native int nativeCanTransition(int from, int to);
    private static native int nativeSubCreate(int slot);
    private static native int nativeSubPhase(int slot);
    private static native int nativeSubAdvance(int slot);
    private static native int nativeSubEmitEvent(int slot);
    private static native int nativeSubAbort(int slot);
    private static native int nativeSubEventCount(int slot);
    private static native int nativeSubCanTransition(int from, int to);
    private static native int nativeIntrospectionQuery(int slot, int introField);
    private static native int nativeCheckDepth(int depth, int maxDepth);
    private static native int nativeCheckComplexity(int score, int maxComplexity);

    // -----------------------------------------------------------------------
    // Safe wrappers
    // -----------------------------------------------------------------------

    public static int abiVersion() { return nativeAbiVersion(); }

    /**
     * Create a new GraphQL request context.
     *
     * @param opType operation type (0=query, 1=mutation, 2=subscription)
     * @return context slot index
     * @throws ProvenError if pool exhausted
     */
    public static int create(OperationType opType) throws ProvenError {
        return ProvenError.checkSlot(nativeCreate(opType.tag()));
    }

    public static void destroy(int slot) { nativeDestroy(slot); }

    public static Phase phase(int slot) { return Phase.fromTag(nativePhase(slot)); }

    public static OperationType operationType(int slot) { return OperationType.fromTag(nativeOperationType(slot)); }

    /** @return error category tag (255 = no error) */
    public static int errorCategory(int slot) { return nativeErrorCategory(slot); }

    /** Advance to the next lifecycle phase. */
    public static void advance(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeAdvance(slot));
    }

    /** Abort with an error category. */
    public static void abort(int slot, int errorCategory) throws ProvenError {
        ProvenError.checkStatus(nativeAbort(slot, errorCategory));
    }

    /** Set the query nesting depth. */
    public static void setQueryDepth(int slot, int depth) throws ProvenError {
        ProvenError.checkStatus(nativeSetQueryDepth(slot, depth));
    }

    public static int queryDepth(int slot) { return nativeQueryDepth(slot); }

    /** Set the query complexity score. */
    public static void setComplexity(int slot, int score) throws ProvenError {
        ProvenError.checkStatus(nativeSetComplexity(slot, score));
    }

    public static int complexity(int slot) { return nativeComplexity(slot); }

    /** Record a field resolution. */
    public static void resolveField(int slot, int typeKind, int scalarKind) throws ProvenError {
        ProvenError.checkStatus(nativeResolveField(slot, typeKind, scalarKind));
    }

    public static int fieldsResolved(int slot) { return nativeFieldsResolved(slot); }

    public static boolean canTransition(Phase from, Phase to) {
        return nativeCanTransition(from.tag(), to.tag()) == 1;
    }

    /** Create a subscription from a subscription-type context. */
    public static int subCreate(int slot) throws ProvenError {
        return ProvenError.checkSlot(nativeSubCreate(slot));
    }

    public static int subPhase(int slot) { return nativeSubPhase(slot); }

    public static void subAdvance(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeSubAdvance(slot));
    }

    public static void subEmitEvent(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeSubEmitEvent(slot));
    }

    public static void subAbort(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeSubAbort(slot));
    }

    public static int subEventCount(int slot) { return nativeSubEventCount(slot); }

    /** Run an introspection query on a field. */
    public static void introspectionQuery(int slot, int introField) throws ProvenError {
        ProvenError.checkStatus(nativeIntrospectionQuery(slot, introField));
    }

    /** Stateless: check if depth is within limit. */
    public static boolean checkDepth(int depth, int maxDepth) {
        return nativeCheckDepth(depth, maxDepth) == 1;
    }

    /** Stateless: check if complexity is within limit. */
    public static boolean checkComplexity(int score, int maxComplexity) {
        return nativeCheckComplexity(score, maxComplexity) == 1;
    }
}
