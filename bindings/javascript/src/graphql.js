// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// JavaScript bindings for the proven-graphql Zig FFI.

import { checkSlot, checkStatus } from "./error.js";
import { loadLibrary } from "./ffi.js";

/** @readonly @enum {number} GraphQL request lifecycle phases. */
export const GraphqlPhase = Object.freeze({
    RECEIVED: 0, PARSED: 1, EXECUTING: 2, COMPLETE: 3, ERROR: 4,
});

/** @readonly @enum {number} GraphQL operation types. */
export const OperationType = Object.freeze({
    QUERY: 0, MUTATION: 1, SUBSCRIPTION: 2,
});

/** @readonly @enum {number} GraphQL error categories. */
export const ErrorCategory = Object.freeze({
    SYNTAX: 0, VALIDATION: 1, AUTHORIZATION: 2,
    EXECUTION: 3, RATE_LIMIT: 4, INTERNAL: 5,
});

let _lib = null;

/** @param {object} [options] */
export async function init(options) {
    if (!_lib) _lib = await loadLibrary("graphql", options);
}

function lib() {
    if (!_lib) throw new Error("graphql: call init() before using the module");
    return _lib;
}

/**
 * GraphQL request context wrapping a Zig FFI slot.
 */
export class GraphqlContext {
    constructor(slot) { this._slot = slot; this._destroyed = false; }

    /** @param {number} [opType=0] - OperationType tag. */
    static create(opType = OperationType.QUERY) {
        return new GraphqlContext(checkSlot(lib().graphql_create(opType)));
    }

    destroy() {
        if (!this._destroyed) { lib().graphql_destroy(this._slot); this._destroyed = true; }
    }

    /** @returns {number|null} */ phase() {
        const tag = lib().graphql_phase(this._slot); return tag <= 4 ? tag : null;
    }
    /** @returns {number} */ operationType() { return lib().graphql_operation_type(this._slot); }
    /** @returns {number} */ errorCategory() { return lib().graphql_error_category(this._slot); }
    /** @returns {number} */ queryDepth() { return lib().graphql_query_depth(this._slot); }
    /** @returns {number} */ complexity() { return lib().graphql_complexity(this._slot); }
    /** @returns {number} */ fieldsResolved() { return lib().graphql_fields_resolved(this._slot); }

    advance() { checkStatus(lib().graphql_advance(this._slot)); }
    /** @param {number} errCategory - ErrorCategory tag. */
    abort(errCategory) { checkStatus(lib().graphql_abort(this._slot, errCategory)); }
    /** @param {number} depth */
    setQueryDepth(depth) { checkStatus(lib().graphql_set_query_depth(this._slot, depth)); }
    /** @param {number} score */
    setComplexity(score) { checkStatus(lib().graphql_set_complexity(this._slot, score)); }
    /** @param {number} typeKind @param {number} scalarKind */
    resolveField(typeKind, scalarKind) {
        checkStatus(lib().graphql_resolve_field(this._slot, typeKind, scalarKind));
    }
    /** @param {number} introField */
    introspectionQuery(introField) {
        checkStatus(lib().graphql_introspection_query(this._slot, introField));
    }

    /** @returns {number} Subscription slot ID. */
    subCreate() { return checkSlot(lib().graphql_sub_create(this._slot)); }
    /** @returns {number} */ subPhase() { return lib().graphql_sub_phase(this._slot); }
    subAdvance() { checkStatus(lib().graphql_sub_advance(this._slot)); }
    subEmitEvent() { checkStatus(lib().graphql_sub_emit_event(this._slot)); }
    subAbort() { checkStatus(lib().graphql_sub_abort(this._slot)); }
    /** @returns {number} */ subEventCount() { return lib().graphql_sub_event_count(this._slot); }
}

/** @returns {number} */
export function abiVersion() { return lib().graphql_abi_version(); }

/** @param {number} from @param {number} to @returns {boolean} */
export function canTransition(from, to) {
    return lib().graphql_can_transition(from, to) === 1;
}

/** @param {number} from @param {number} to @returns {boolean} */
export function subCanTransition(from, to) {
    return lib().graphql_sub_can_transition(from, to) === 1;
}

/** @param {number} depth @param {number} maxDepth @returns {boolean} */
export function checkDepth(depth, maxDepth) {
    return lib().graphql_check_depth(depth, maxDepth) === 1;
}

/** @param {number} score @param {number} maxComplexity @returns {boolean} */
export function checkComplexity(score, maxComplexity) {
    return lib().graphql_check_complexity(score, maxComplexity) === 1;
}
