// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Swift bindings for the proven-graphql protocol.
// Wraps the C-ABI functions from protocols/proven-graphql/ffi/zig/src/graphql.zig.
// Enums match Idris2 ABI tags exactly (GraphqlABI.Layout).

import Foundation

// MARK: - C interop declarations

@_silgen_name("graphql_abi_version")       private func graphql_abi_version() -> UInt32
@_silgen_name("graphql_create")            private func graphql_create(_ opType: UInt8) -> Int32
@_silgen_name("graphql_destroy")           private func graphql_destroy(_ slot: Int32)
@_silgen_name("graphql_phase")             private func graphql_phase(_ slot: Int32) -> UInt8
@_silgen_name("graphql_operation_type")    private func graphql_operation_type(_ slot: Int32) -> UInt8
@_silgen_name("graphql_error_category")    private func graphql_error_category(_ slot: Int32) -> UInt8
@_silgen_name("graphql_advance")           private func graphql_advance(_ slot: Int32) -> UInt8
@_silgen_name("graphql_abort")             private func graphql_abort(_ slot: Int32, _ errCat: UInt8) -> UInt8
@_silgen_name("graphql_set_query_depth")   private func graphql_set_query_depth(_ slot: Int32, _ depth: UInt16) -> UInt8
@_silgen_name("graphql_query_depth")       private func graphql_query_depth(_ slot: Int32) -> UInt16
@_silgen_name("graphql_set_complexity")    private func graphql_set_complexity(_ slot: Int32, _ score: UInt16) -> UInt8
@_silgen_name("graphql_complexity")        private func graphql_complexity(_ slot: Int32) -> UInt16
@_silgen_name("graphql_resolve_field")     private func graphql_resolve_field(_ slot: Int32, _ typeKind: UInt8, _ scalarKind: UInt8) -> UInt8
@_silgen_name("graphql_fields_resolved")   private func graphql_fields_resolved(_ slot: Int32) -> UInt16
@_silgen_name("graphql_can_transition")    private func graphql_can_transition(_ from: UInt8, _ to: UInt8) -> UInt8
@_silgen_name("graphql_sub_create")        private func graphql_sub_create(_ slot: Int32) -> Int32
@_silgen_name("graphql_sub_phase")         private func graphql_sub_phase(_ slot: Int32) -> UInt8
@_silgen_name("graphql_sub_advance")       private func graphql_sub_advance(_ slot: Int32) -> UInt8
@_silgen_name("graphql_sub_emit_event")    private func graphql_sub_emit_event(_ slot: Int32) -> UInt8
@_silgen_name("graphql_sub_abort")         private func graphql_sub_abort(_ slot: Int32) -> UInt8
@_silgen_name("graphql_sub_event_count")   private func graphql_sub_event_count(_ slot: Int32) -> UInt32
@_silgen_name("graphql_sub_can_transition") private func graphql_sub_can_transition(_ from: UInt8, _ to: UInt8) -> UInt8
@_silgen_name("graphql_introspection_query") private func graphql_introspection_query(_ slot: Int32, _ introField: UInt8) -> UInt8
@_silgen_name("graphql_check_depth")       private func graphql_check_depth(_ depth: UInt16, _ maxDepth: UInt16) -> UInt8
@_silgen_name("graphql_check_complexity")  private func graphql_check_complexity(_ score: UInt16, _ maxComplexity: UInt16) -> UInt8

// MARK: - Enums matching Idris2 ABI tags

/// GraphQL request lifecycle phases (tags 0-4).
public enum GraphqlPhase: Int, CaseIterable, Sendable {
    /// Request received, not yet parsed.
    case received = 0
    /// Query parsed and validated.
    case parsed = 1
    /// Execution in progress.
    case executing = 2
    /// Execution complete, response ready.
    case complete = 3
    /// Error occurred.
    case error = 4

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

/// GraphQL operation types (tags 0-2).
public enum GraphqlOperationType: Int, CaseIterable, Sendable {
    /// Standard query.
    case query = 0
    /// Mutation.
    case mutation = 1
    /// Subscription.
    case subscription = 2

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

// MARK: - Swift-idiomatic wrapper

/// Swift wrapper for the proven GraphQL server protocol FFI.
///
/// Manages an opaque GraphQL request context slot. The context is
/// automatically destroyed when this object is deallocated.
///
/// Lifecycle: Received -> Parsed -> Executing -> Complete (or Error).
public final class ProvenGraphql: @unchecked Sendable {

    private let slot: Int32

    /// Create a new GraphQL request context.
    ///
    /// - Parameter operationType: The operation type (query, mutation, subscription).
    /// - Throws: ``ProvenError/poolExhausted`` if all 64 slots are in use.
    public init(operationType: GraphqlOperationType = .query) throws {
        self.slot = try ProvenError.checkSlot(graphql_create(operationType.tag))
    }

    deinit { graphql_destroy(slot) }

    /// The ABI version.
    public static var abiVersion: UInt32 { graphql_abi_version() }

    /// The current request phase.
    public var phase: GraphqlPhase? { GraphqlPhase(tag: graphql_phase(slot)) }

    /// The operation type tag.
    public var operationType: GraphqlOperationType? {
        GraphqlOperationType(tag: graphql_operation_type(slot))
    }

    /// The error category tag (255 = no error).
    public var errorCategory: UInt8 { graphql_error_category(slot) }

    /// Advance to the next lifecycle phase.
    public func advance() throws {
        try ProvenError.checkStatus(graphql_advance(slot))
    }

    /// Abort the request with an error category.
    ///
    /// - Parameter errorCategory: The error category tag.
    public func abort(errorCategory: UInt8) throws {
        try ProvenError.checkStatus(graphql_abort(slot, errorCategory))
    }

    /// Set the query nesting depth (for depth limiting).
    public func setQueryDepth(_ depth: UInt16) throws {
        try ProvenError.checkStatus(graphql_set_query_depth(slot, depth))
    }

    /// The current query depth.
    public var queryDepth: UInt16 { graphql_query_depth(slot) }

    /// Set the query complexity score.
    public func setComplexity(_ score: UInt16) throws {
        try ProvenError.checkStatus(graphql_set_complexity(slot, score))
    }

    /// The current complexity score.
    public var complexity: UInt16 { graphql_complexity(slot) }

    /// Record a field resolution with type and scalar kind.
    public func resolveField(typeKind: UInt8, scalarKind: UInt8) throws {
        try ProvenError.checkStatus(graphql_resolve_field(slot, typeKind, scalarKind))
    }

    /// The number of fields resolved so far.
    public var fieldsResolved: UInt16 { graphql_fields_resolved(slot) }

    /// Create a subscription from this context (must be subscription operation type).
    ///
    /// - Returns: The subscription slot ID.
    /// - Throws: ``ProvenError/poolExhausted`` if no slots available.
    public func createSubscription() throws -> Int32 {
        try ProvenError.checkSlot(graphql_sub_create(slot))
    }

    /// The subscription phase tag.
    public var subscriptionPhase: UInt8 { graphql_sub_phase(slot) }

    /// Advance the subscription lifecycle.
    public func subscriptionAdvance() throws {
        try ProvenError.checkStatus(graphql_sub_advance(slot))
    }

    /// Emit a subscription event.
    public func subscriptionEmitEvent() throws {
        try ProvenError.checkStatus(graphql_sub_emit_event(slot))
    }

    /// Abort a subscription.
    public func subscriptionAbort() throws {
        try ProvenError.checkStatus(graphql_sub_abort(slot))
    }

    /// The subscription event count.
    public var subscriptionEventCount: UInt32 { graphql_sub_event_count(slot) }

    /// Run an introspection query on a specific field.
    public func introspectionQuery(field: UInt8) throws {
        try ProvenError.checkStatus(graphql_introspection_query(slot, field))
    }

    /// Stateless query: check whether a request phase transition is valid.
    public static func canTransition(from: GraphqlPhase, to: GraphqlPhase) -> Bool {
        graphql_can_transition(from.tag, to.tag) == 1
    }

    /// Stateless: check if a query depth is within limits.
    public static func checkDepth(_ depth: UInt16, maxDepth: UInt16) -> Bool {
        graphql_check_depth(depth, maxDepth) == 1
    }

    /// Stateless: check if a complexity score is within limits.
    public static func checkComplexity(_ score: UInt16, maxComplexity: UInt16) -> Bool {
        graphql_check_complexity(score, maxComplexity) == 1
    }
}
