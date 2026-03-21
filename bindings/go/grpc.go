// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// gRPC protocol bindings for proven-servers.
//
// Wraps the C-ABI functions from protocols/proven-grpc/ffi/zig/src/grpc.zig.
// Models the HTTP/2 stream state machine with flow control windows.
package proven

/*
#cgo LDFLAGS: -lproven_grpc
#include <stdint.h>
#include <stdint.h>

extern uint32_t grpc_abi_version();
extern int grpc_create(uint8_t compression);
extern void grpc_destroy(int slot);
extern uint8_t grpc_stream_state(int slot);
extern uint8_t grpc_compression(int slot);
extern uint8_t grpc_status_code(int slot);
extern uint8_t grpc_set_status(int slot, uint8_t status);
extern uint32_t grpc_stream_id(int slot);
extern uint8_t grpc_send_headers(int slot);
extern uint8_t grpc_local_end_stream(int slot);
extern uint8_t grpc_remote_end_stream(int slot);
extern uint8_t grpc_reset_stream(int slot, uint8_t status);
extern uint8_t grpc_close_half_local(int slot);
extern uint8_t grpc_close_half_remote(int slot);
extern uint8_t grpc_push_promise(int slot);
extern uint8_t grpc_reserved_to_half(int slot);
extern uint8_t grpc_can_send(int slot);
extern uint8_t grpc_can_receive(int slot);
extern int32_t grpc_send_window(int slot);
extern int32_t grpc_recv_window(int slot);
extern uint8_t grpc_update_send_window(int slot, int32_t delta);
extern uint8_t grpc_update_recv_window(int slot, int32_t delta);
extern uint8_t grpc_can_transition(uint8_t from, uint8_t to);
*/
import "C"

// GrpcStreamState represents the HTTP/2 stream state.
// Tags match StreamState in the Idris2 ABI.
type GrpcStreamState uint8

const (
	StreamIdle             GrpcStreamState = iota // Stream idle
	StreamReserved                                // Reserved (PUSH_PROMISE)
	StreamOpen                                    // Stream open
	StreamHalfClosedLocal                         // Half-closed (local)
	StreamHalfClosedRemote                        // Half-closed (remote)
	StreamClosed                                  // Stream closed
)

// GrpcCompression represents the compression algorithm.
type GrpcCompression uint8

const (
	GrpcNoCompression GrpcCompression = iota // No compression
	GrpcGzip                                 // Gzip
	GrpcDeflate                              // Deflate
)

// GrpcStatusCode represents a gRPC status code.
type GrpcStatusCode uint8

const (
	GrpcOk                 GrpcStatusCode = 0  // OK
	GrpcCancelled          GrpcStatusCode = 1  // Cancelled
	GrpcUnknownStatus      GrpcStatusCode = 2  // Unknown
	GrpcInvalidArgument    GrpcStatusCode = 3  // Invalid argument
	GrpcDeadlineExceeded   GrpcStatusCode = 4  // Deadline exceeded
	GrpcNotFoundStatus     GrpcStatusCode = 5  // Not found
	GrpcAlreadyExists      GrpcStatusCode = 6  // Already exists
	GrpcPermissionDenied   GrpcStatusCode = 7  // Permission denied
	GrpcResourceExhausted  GrpcStatusCode = 8  // Resource exhausted
	GrpcFailedPrecondition GrpcStatusCode = 9  // Failed precondition
	GrpcAborted            GrpcStatusCode = 10 // Aborted
	GrpcOutOfRange         GrpcStatusCode = 11 // Out of range
	GrpcUnimplemented      GrpcStatusCode = 12 // Unimplemented
	GrpcInternal           GrpcStatusCode = 13 // Internal
	GrpcUnavailable        GrpcStatusCode = 14 // Unavailable
	GrpcDataLoss           GrpcStatusCode = 15 // Data loss
	GrpcUnauthenticated    GrpcStatusCode = 16 // Unauthenticated
)

// GrpcContext wraps a slot in the proven-grpc context pool.
type GrpcContext struct {
	slot C.int
}

// GrpcABIVersion returns the ABI version.
func GrpcABIVersion() uint32 {
	return uint32(C.grpc_abi_version())
}

// GrpcCreate allocates a new gRPC stream context with the given compression.
func GrpcCreate(compression GrpcCompression) (*GrpcContext, error) {
	slot := C.grpc_create(C.uint8_t(compression))
	s, err := slotError(slot)
	if err != nil {
		return nil, err
	}
	return &GrpcContext{slot: C.int(s)}, nil
}

// Close releases the gRPC context slot.
func (ctx *GrpcContext) Close() {
	C.grpc_destroy(ctx.slot)
}

// StreamState returns the current HTTP/2 stream state.
func (ctx *GrpcContext) StreamState() (GrpcStreamState, bool) {
	tag := C.grpc_stream_state(ctx.slot)
	if tag > 5 {
		return 0, false
	}
	return GrpcStreamState(tag), true
}

// Compression returns the compression algorithm tag.
func (ctx *GrpcContext) Compression() uint8 {
	return uint8(C.grpc_compression(ctx.slot))
}

// StatusCode returns the gRPC status code.
func (ctx *GrpcContext) StatusCode() (GrpcStatusCode, bool) {
	tag := C.grpc_status_code(ctx.slot)
	if tag > 16 {
		return 0, false
	}
	return GrpcStatusCode(tag), true
}

// SetStatus sets the gRPC status code.
func (ctx *GrpcContext) SetStatus(status GrpcStatusCode) error {
	return statusError(C.grpc_set_status(ctx.slot, C.uint8_t(status)))
}

// StreamID returns the HTTP/2 stream ID.
func (ctx *GrpcContext) StreamID() uint32 {
	return uint32(C.grpc_stream_id(ctx.slot))
}

// SendHeaders sends HEADERS frame. Transitions Idle -> Open.
func (ctx *GrpcContext) SendHeaders() error {
	return statusError(C.grpc_send_headers(ctx.slot))
}

// LocalEndStream sends local END_STREAM. Transitions Open -> HalfClosedLocal.
func (ctx *GrpcContext) LocalEndStream() error {
	return statusError(C.grpc_local_end_stream(ctx.slot))
}

// RemoteEndStream receives remote END_STREAM. Transitions Open -> HalfClosedRemote.
func (ctx *GrpcContext) RemoteEndStream() error {
	return statusError(C.grpc_remote_end_stream(ctx.slot))
}

// ResetStream sends RST_STREAM with a status code. Transitions Open -> Closed.
func (ctx *GrpcContext) ResetStream(status GrpcStatusCode) error {
	return statusError(C.grpc_reset_stream(ctx.slot, C.uint8_t(status)))
}

// CloseHalfLocal closes from HalfClosedLocal -> Closed.
func (ctx *GrpcContext) CloseHalfLocal() error {
	return statusError(C.grpc_close_half_local(ctx.slot))
}

// CloseHalfRemote closes from HalfClosedRemote -> Closed.
func (ctx *GrpcContext) CloseHalfRemote() error {
	return statusError(C.grpc_close_half_remote(ctx.slot))
}

// PushPromise sends PUSH_PROMISE. Transitions Idle -> Reserved.
func (ctx *GrpcContext) PushPromise() error {
	return statusError(C.grpc_push_promise(ctx.slot))
}

// ReservedToHalf transitions Reserved -> HalfClosedRemote.
func (ctx *GrpcContext) ReservedToHalf() error {
	return statusError(C.grpc_reserved_to_half(ctx.slot))
}

// CanSend checks if DATA frames can be sent from this state.
func (ctx *GrpcContext) CanSend() bool {
	return C.grpc_can_send(ctx.slot) == 1
}

// CanReceive checks if DATA frames can be received in this state.
func (ctx *GrpcContext) CanReceive() bool {
	return C.grpc_can_receive(ctx.slot) == 1
}

// SendWindow returns the send-side flow control window.
func (ctx *GrpcContext) SendWindow() int32 {
	return int32(C.grpc_send_window(ctx.slot))
}

// RecvWindow returns the receive-side flow control window.
func (ctx *GrpcContext) RecvWindow() int32 {
	return int32(C.grpc_recv_window(ctx.slot))
}

// UpdateSendWindow updates the send-side flow control window by delta.
func (ctx *GrpcContext) UpdateSendWindow(delta int32) error {
	return statusError(C.grpc_update_send_window(ctx.slot, C.int32_t(delta)))
}

// UpdateRecvWindow updates the receive-side flow control window by delta.
func (ctx *GrpcContext) UpdateRecvWindow(delta int32) error {
	return statusError(C.grpc_update_recv_window(ctx.slot, C.int32_t(delta)))
}

// GrpcCanTransition checks whether a stream state transition is valid.
func GrpcCanTransition(from, to GrpcStreamState) bool {
	return C.grpc_can_transition(C.uint8_t(from), C.uint8_t(to)) == 1
}
