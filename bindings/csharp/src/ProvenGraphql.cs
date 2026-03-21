// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// C# P/Invoke bindings for the proven-graphql protocol.
// Wraps the C-ABI functions from protocols/proven-graphql/ffi/zig/src/graphql.zig.

using System;
using System.Runtime.InteropServices;

namespace ProvenServers
{
    /// <summary>GraphQL request phases (tags 0-4).</summary>
    public enum GraphqlPhase : byte
    {
        Received = 0, Parsed = 1, Executing = 2, Complete = 3, Error = 4
    }

    /// <summary>GraphQL operation types.</summary>
    public enum GraphqlOperationType : byte
    {
        Query = 0, Mutation = 1, Subscription = 2
    }

    /// <summary>
    /// C# bindings for the proven GraphQL server protocol.
    /// Lifecycle: Received -> Parsed -> Executing -> Complete/Error.
    /// </summary>
    public static class ProvenGraphql
    {
        private const string Lib = "proven_graphql";

        [DllImport(Lib)] private static extern uint graphql_abi_version();
        [DllImport(Lib)] private static extern int graphql_create(byte opType);
        [DllImport(Lib)] private static extern void graphql_destroy(int slot);
        [DllImport(Lib)] private static extern byte graphql_phase(int slot);
        [DllImport(Lib)] private static extern byte graphql_operation_type(int slot);
        [DllImport(Lib)] private static extern byte graphql_error_category(int slot);
        [DllImport(Lib)] private static extern byte graphql_advance(int slot);
        [DllImport(Lib)] private static extern byte graphql_abort(int slot, byte errCat);
        [DllImport(Lib)] private static extern byte graphql_set_query_depth(int slot, ushort depth);
        [DllImport(Lib)] private static extern ushort graphql_query_depth(int slot);
        [DllImport(Lib)] private static extern byte graphql_set_complexity(int slot, ushort score);
        [DllImport(Lib)] private static extern ushort graphql_complexity(int slot);
        [DllImport(Lib)] private static extern byte graphql_resolve_field(int slot, byte typeKind, byte scalarKind);
        [DllImport(Lib)] private static extern ushort graphql_fields_resolved(int slot);
        [DllImport(Lib)] private static extern byte graphql_can_transition(byte from, byte to);
        [DllImport(Lib)] private static extern int graphql_sub_create(int slot);
        [DllImport(Lib)] private static extern byte graphql_sub_phase(int slot);
        [DllImport(Lib)] private static extern byte graphql_sub_advance(int slot);
        [DllImport(Lib)] private static extern byte graphql_sub_emit_event(int slot);
        [DllImport(Lib)] private static extern byte graphql_sub_abort(int slot);
        [DllImport(Lib)] private static extern uint graphql_sub_event_count(int slot);
        [DllImport(Lib)] private static extern byte graphql_sub_can_transition(byte from, byte to);
        [DllImport(Lib)] private static extern byte graphql_introspection_query(int slot, byte introField);
        [DllImport(Lib)] private static extern byte graphql_check_depth(ushort depth, ushort maxDepth);
        [DllImport(Lib)] private static extern byte graphql_check_complexity(ushort score, ushort maxComplexity);

        public static uint AbiVersion() => graphql_abi_version();

        public static int Create(GraphqlOperationType opType) =>
            ProvenError.CheckSlot(graphql_create((byte)opType));

        public static void Destroy(int slot) => graphql_destroy(slot);

        public static GraphqlPhase? Phase(int slot)
        {
            byte tag = graphql_phase(slot);
            return tag <= 4 ? (GraphqlPhase)tag : null;
        }

        public static GraphqlOperationType? OperationType(int slot)
        {
            byte tag = graphql_operation_type(slot);
            return tag <= 2 ? (GraphqlOperationType)tag : null;
        }

        /// <summary>Error category tag (255 = no error).</summary>
        public static byte ErrorCategory(int slot) => graphql_error_category(slot);

        /// <summary>Advance to the next lifecycle phase.</summary>
        public static void Advance(int slot) => ProvenError.CheckStatus(graphql_advance(slot));

        /// <summary>Abort with an error category.</summary>
        public static void Abort(int slot, byte errorCategory) =>
            ProvenError.CheckStatus(graphql_abort(slot, errorCategory));

        public static void SetQueryDepth(int slot, ushort depth) =>
            ProvenError.CheckStatus(graphql_set_query_depth(slot, depth));

        public static ushort QueryDepth(int slot) => graphql_query_depth(slot);

        public static void SetComplexity(int slot, ushort score) =>
            ProvenError.CheckStatus(graphql_set_complexity(slot, score));

        public static ushort Complexity(int slot) => graphql_complexity(slot);

        public static void ResolveField(int slot, byte typeKind, byte scalarKind) =>
            ProvenError.CheckStatus(graphql_resolve_field(slot, typeKind, scalarKind));

        public static ushort FieldsResolved(int slot) => graphql_fields_resolved(slot);

        public static bool CanTransition(GraphqlPhase from, GraphqlPhase to) =>
            graphql_can_transition((byte)from, (byte)to) == 1;

        public static int SubCreate(int slot) => ProvenError.CheckSlot(graphql_sub_create(slot));
        public static byte SubPhase(int slot) => graphql_sub_phase(slot);
        public static void SubAdvance(int slot) => ProvenError.CheckStatus(graphql_sub_advance(slot));
        public static void SubEmitEvent(int slot) => ProvenError.CheckStatus(graphql_sub_emit_event(slot));
        public static void SubAbort(int slot) => ProvenError.CheckStatus(graphql_sub_abort(slot));
        public static uint SubEventCount(int slot) => graphql_sub_event_count(slot);

        public static void IntrospectionQuery(int slot, byte introField) =>
            ProvenError.CheckStatus(graphql_introspection_query(slot, introField));

        /// <summary>Stateless: check if depth is within limit.</summary>
        public static bool CheckDepth(ushort depth, ushort maxDepth) =>
            graphql_check_depth(depth, maxDepth) == 1;

        /// <summary>Stateless: check if complexity is within limit.</summary>
        public static bool CheckComplexity(ushort score, ushort maxComplexity) =>
            graphql_check_complexity(score, maxComplexity) == 1;
    }
}
