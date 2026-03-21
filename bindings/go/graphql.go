// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// GraphQL protocol bindings for proven-servers.
//
// Wraps the C-ABI functions from protocols/proven-graphql/ffi/zig/src/graphql.zig.
// Lifecycle: create -> advance (Received->Parsed->Executing->Complete) -> destroy.
package proven

/*
#cgo LDFLAGS: -lproven_graphql
#include <stdint.h>

extern uint32_t graphql_abi_version();
extern int graphql_create(uint8_t op_type);
extern void graphql_destroy(int slot);
extern uint8_t graphql_phase(int slot);
extern uint8_t graphql_operation_type(int slot);
extern uint8_t graphql_error_category(int slot);
extern uint8_t graphql_advance(int slot);
extern uint8_t graphql_abort(int slot, uint8_t err_cat);
extern uint8_t graphql_set_query_depth(int slot, uint16_t depth);
extern uint16_t graphql_query_depth(int slot);
extern uint8_t graphql_set_complexity(int slot, uint16_t score);
extern uint16_t graphql_complexity(int slot);
extern uint8_t graphql_resolve_field(int slot, uint8_t type_kind, uint8_t scalar_kind);
extern uint16_t graphql_fields_resolved(int slot);
extern uint8_t graphql_can_transition(uint8_t from, uint8_t to);
extern int graphql_sub_create(int slot);
extern uint8_t graphql_sub_phase(int slot);
extern uint8_t graphql_sub_advance(int slot);
extern uint8_t graphql_sub_emit_event(int slot);
extern uint8_t graphql_sub_abort(int slot);
extern uint32_t graphql_sub_event_count(int slot);
extern uint8_t graphql_sub_can_transition(uint8_t from, uint8_t to);
extern uint8_t graphql_introspection_query(int slot, uint8_t intro_field);
extern uint8_t graphql_check_depth(uint16_t depth, uint16_t max_depth);
extern uint8_t graphql_check_complexity(uint16_t score, uint16_t max_complexity);
*/
import "C"

// GraphqlPhase represents the GraphQL request lifecycle phase.
// Tags match the Zig FFI.
type GraphqlPhase uint8

const (
	GqlReceived  GraphqlPhase = iota // Request received, not yet parsed
	GqlParsed                        // Query parsed and validated
	GqlExecuting                     // Execution in progress
	GqlComplete                      // Execution complete, response ready
	GqlError                         // Error occurred
)

// GraphqlOperationType represents the GraphQL operation type.
type GraphqlOperationType uint8

const (
	GqlQuery        GraphqlOperationType = iota // Query operation
	GqlMutation                                 // Mutation operation
	GqlSubscription                             // Subscription operation
)

// GraphqlContext wraps a slot in the proven-graphql context pool.
type GraphqlContext struct {
	slot C.int
}

// GraphqlABIVersion returns the ABI version.
func GraphqlABIVersion() uint32 {
	return uint32(C.graphql_abi_version())
}

// GraphqlCreate allocates a new GraphQL request context.
// opType: GqlQuery=0, GqlMutation=1, GqlSubscription=2.
func GraphqlCreate(opType GraphqlOperationType) (*GraphqlContext, error) {
	slot := C.graphql_create(C.uint8_t(opType))
	s, err := slotError(slot)
	if err != nil {
		return nil, err
	}
	return &GraphqlContext{slot: C.int(s)}, nil
}

// Close releases the GraphQL context slot.
func (ctx *GraphqlContext) Close() {
	C.graphql_destroy(ctx.slot)
}

// Phase returns the current request phase.
func (ctx *GraphqlContext) Phase() (GraphqlPhase, bool) {
	tag := C.graphql_phase(ctx.slot)
	if tag > 4 {
		return 0, false
	}
	return GraphqlPhase(tag), true
}

// OperationType returns the operation type tag.
func (ctx *GraphqlContext) OperationType() GraphqlOperationType {
	return GraphqlOperationType(C.graphql_operation_type(ctx.slot))
}

// ErrorCategory returns the error category tag (255 = no error).
func (ctx *GraphqlContext) ErrorCategory() uint8 {
	return uint8(C.graphql_error_category(ctx.slot))
}

// Advance moves to the next lifecycle phase.
func (ctx *GraphqlContext) Advance() error {
	return statusError(C.graphql_advance(ctx.slot))
}

// Abort aborts the request with an error category.
func (ctx *GraphqlContext) Abort(errCategory uint8) error {
	return statusError(C.graphql_abort(ctx.slot, C.uint8_t(errCategory)))
}

// SetQueryDepth sets the query nesting depth for depth limiting.
func (ctx *GraphqlContext) SetQueryDepth(depth uint16) error {
	return statusError(C.graphql_set_query_depth(ctx.slot, C.uint16_t(depth)))
}

// QueryDepth returns the current query depth.
func (ctx *GraphqlContext) QueryDepth() uint16 {
	return uint16(C.graphql_query_depth(ctx.slot))
}

// SetComplexity sets the query complexity score.
func (ctx *GraphqlContext) SetComplexity(score uint16) error {
	return statusError(C.graphql_set_complexity(ctx.slot, C.uint16_t(score)))
}

// Complexity returns the current complexity score.
func (ctx *GraphqlContext) Complexity() uint16 {
	return uint16(C.graphql_complexity(ctx.slot))
}

// ResolveField records a field resolution with type and scalar kind.
func (ctx *GraphqlContext) ResolveField(typeKind, scalarKind uint8) error {
	return statusError(C.graphql_resolve_field(ctx.slot, C.uint8_t(typeKind), C.uint8_t(scalarKind)))
}

// FieldsResolved returns the number of fields resolved so far.
func (ctx *GraphqlContext) FieldsResolved() uint16 {
	return uint16(C.graphql_fields_resolved(ctx.slot))
}

// GqlCanTransition checks whether a request phase transition is valid.
func GqlCanTransition(from, to GraphqlPhase) bool {
	return C.graphql_can_transition(C.uint8_t(from), C.uint8_t(to)) == 1
}

// SubCreate creates a subscription from a context in subscription mode.
// Returns the subscription slot ID.
func (ctx *GraphqlContext) SubCreate() (int, error) {
	slot := C.graphql_sub_create(ctx.slot)
	return slotError(slot)
}

// SubPhase returns the subscription phase tag.
func (ctx *GraphqlContext) SubPhase() uint8 {
	return uint8(C.graphql_sub_phase(ctx.slot))
}

// SubAdvance advances the subscription lifecycle.
func (ctx *GraphqlContext) SubAdvance() error {
	return statusError(C.graphql_sub_advance(ctx.slot))
}

// SubEmitEvent emits a subscription event.
func (ctx *GraphqlContext) SubEmitEvent() error {
	return statusError(C.graphql_sub_emit_event(ctx.slot))
}

// SubAbort aborts a subscription.
func (ctx *GraphqlContext) SubAbort() error {
	return statusError(C.graphql_sub_abort(ctx.slot))
}

// SubEventCount returns the subscription event count.
func (ctx *GraphqlContext) SubEventCount() uint32 {
	return uint32(C.graphql_sub_event_count(ctx.slot))
}

// IntrospectionQuery runs an introspection query on a specific field.
func (ctx *GraphqlContext) IntrospectionQuery(introField uint8) error {
	return statusError(C.graphql_introspection_query(ctx.slot, C.uint8_t(introField)))
}

// GqlCheckDepth checks if a query depth is within limits (stateless).
func GqlCheckDepth(depth, maxDepth uint16) bool {
	return C.graphql_check_depth(C.uint16_t(depth), C.uint16_t(maxDepth)) == 1
}

// GqlCheckComplexity checks if a complexity score is within limits (stateless).
func GqlCheckComplexity(score, maxComplexity uint16) bool {
	return C.graphql_check_complexity(C.uint16_t(score), C.uint16_t(maxComplexity)) == 1
}
