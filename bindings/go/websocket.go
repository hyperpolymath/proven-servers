// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// WebSocket protocol bindings for proven-servers.
//
// Wraps the C-ABI functions from protocols/proven-websocket/ffi/zig/src/websocket.zig.
// Lifecycle: create -> handshake -> open -> send/recv frames -> close -> destroy.
// Opcodes follow RFC 6455 wire values.
package proven

/*
#cgo LDFLAGS: -lproven_websocket
#include <stdint.h>

extern uint32_t ws_abi_version();
extern int ws_create_context();
extern void ws_destroy_context(int slot);
extern uint8_t ws_state(int slot);
extern uint8_t ws_handshake(int slot);
extern uint8_t ws_send_frame(int slot, uint8_t opcode, const uint8_t *data, uint32_t len, uint8_t fin);
extern uint8_t ws_recv_frame(int slot, uint8_t *opcode_out, uint8_t *buf, uint32_t buf_len, uint32_t *written);
extern uint8_t ws_send_close(int slot, uint16_t code);
extern uint8_t ws_send_ping(int slot, const uint8_t *data, uint32_t len);
extern uint8_t ws_send_pong(int slot, const uint8_t *data, uint32_t len);
extern uint16_t ws_close_code(int slot);
extern uint8_t ws_is_masked(int slot);
extern uint32_t ws_frames_sent(int slot);
extern uint32_t ws_frames_received(int slot);
extern uint8_t ws_can_transition(uint8_t from, uint8_t to);
*/
import "C"
import "unsafe"

// WsOpcode represents a WebSocket frame opcode (RFC 6455 Section 5.2).
// Values are the 4-bit wire values from the spec.
type WsOpcode uint8

const (
	WsContinuation WsOpcode = 0x0 // Continuation frame
	WsText         WsOpcode = 0x1 // Text frame (UTF-8)
	WsBinary       WsOpcode = 0x2 // Binary frame
	WsClose        WsOpcode = 0x8 // Close frame
	WsPing         WsOpcode = 0x9 // Ping frame
	WsPong         WsOpcode = 0xA // Pong frame
)

// WsState represents the WebSocket connection state.
type WsState uint8

const (
	WsConnecting WsState = iota // Handshake in progress
	WsOpen                      // Connection open
	WsClosing                   // Close frame sent/received
	WsClosed                    // Connection closed
)

// WsCloseCode represents a WebSocket close status code (RFC 6455 Section 7.4).
type WsCloseCode uint16

const (
	WsCloseNormal         WsCloseCode = 1000 // Normal closure
	WsCloseGoingAway      WsCloseCode = 1001 // Endpoint going away
	WsCloseProtocolError  WsCloseCode = 1002 // Protocol error
	WsCloseUnsupported    WsCloseCode = 1003 // Unsupported data type
	WsCloseNoStatus       WsCloseCode = 1005 // No status code present
	WsCloseAbnormal       WsCloseCode = 1006 // Abnormal closure
	WsCloseInvalidPayload WsCloseCode = 1007 // Invalid frame payload data
	WsClosePolicyViolation WsCloseCode = 1008 // Policy violation
	WsCloseMessageTooBig  WsCloseCode = 1009 // Message too big
	WsCloseMandatoryExt   WsCloseCode = 1010 // Mandatory extension missing
	WsCloseInternalError  WsCloseCode = 1011 // Internal server error
)

// WsContext wraps a slot in the proven-websocket context pool.
type WsContext struct {
	slot C.int
}

// WsABIVersion returns the ABI version of the linked WebSocket library.
func WsABIVersion() uint32 {
	return uint32(C.ws_abi_version())
}

// WsCreateContext allocates a new WebSocket context in the Connecting state.
func WsCreateContext() (*WsContext, error) {
	slot := C.ws_create_context()
	s, err := slotError(slot)
	if err != nil {
		return nil, err
	}
	return &WsContext{slot: C.int(s)}, nil
}

// Close releases the WebSocket context slot back to the pool.
func (ctx *WsContext) Close() {
	C.ws_destroy_context(ctx.slot)
}

// State returns the current WebSocket connection state.
func (ctx *WsContext) State() (WsState, bool) {
	tag := C.ws_state(ctx.slot)
	if tag > 3 {
		return 0, false
	}
	return WsState(tag), true
}

// Handshake completes the WebSocket handshake. Transitions Connecting -> Open.
func (ctx *WsContext) Handshake() error {
	return statusError(C.ws_handshake(ctx.slot))
}

// SendFrame sends a WebSocket frame with the given opcode and data.
// fin=true marks the final fragment.
func (ctx *WsContext) SendFrame(opcode WsOpcode, data []byte, fin bool) error {
	var finByte C.uint8_t
	if fin {
		finByte = 1
	}
	var ptr *C.uint8_t
	if len(data) > 0 {
		ptr = (*C.uint8_t)(unsafe.Pointer(&data[0]))
	}
	return statusError(C.ws_send_frame(ctx.slot, C.uint8_t(opcode), ptr, C.uint32_t(len(data)), finByte))
}

// RecvFrame receives a WebSocket frame into buf. Returns the opcode and
// number of bytes written to buf.
func (ctx *WsContext) RecvFrame(buf []byte) (WsOpcode, int, error) {
	if len(buf) == 0 {
		return 0, 0, &ProvenError{Code: 0, Kind: ErrInvalidParameter}
	}
	var opcode C.uint8_t
	var written C.uint32_t
	err := statusError(C.ws_recv_frame(ctx.slot, &opcode, (*C.uint8_t)(unsafe.Pointer(&buf[0])), C.uint32_t(len(buf)), &written))
	return WsOpcode(opcode), int(written), err
}

// SendClose sends a close frame with the given status code. Transitions Open -> Closing.
func (ctx *WsContext) SendClose(code WsCloseCode) error {
	return statusError(C.ws_send_close(ctx.slot, C.uint16_t(code)))
}

// SendPing sends a ping frame with optional data.
func (ctx *WsContext) SendPing(data []byte) error {
	var ptr *C.uint8_t
	if len(data) > 0 {
		ptr = (*C.uint8_t)(unsafe.Pointer(&data[0]))
	}
	return statusError(C.ws_send_ping(ctx.slot, ptr, C.uint32_t(len(data))))
}

// SendPong sends a pong frame with optional data.
func (ctx *WsContext) SendPong(data []byte) error {
	var ptr *C.uint8_t
	if len(data) > 0 {
		ptr = (*C.uint8_t)(unsafe.Pointer(&data[0]))
	}
	return statusError(C.ws_send_pong(ctx.slot, ptr, C.uint32_t(len(data))))
}

// CloseCode returns the close status code received, or 0 if none.
func (ctx *WsContext) CloseCode() WsCloseCode {
	return WsCloseCode(C.ws_close_code(ctx.slot))
}

// IsMasked returns true if frames are masked (client-to-server).
func (ctx *WsContext) IsMasked() bool {
	return C.ws_is_masked(ctx.slot) == 1
}

// FramesSent returns the number of frames sent.
func (ctx *WsContext) FramesSent() uint32 {
	return uint32(C.ws_frames_sent(ctx.slot))
}

// FramesReceived returns the number of frames received.
func (ctx *WsContext) FramesReceived() uint32 {
	return uint32(C.ws_frames_received(ctx.slot))
}

// WsCanTransition checks whether a WebSocket state transition is valid.
func WsCanTransition(from, to WsState) bool {
	return C.ws_can_transition(C.uint8_t(from), C.uint8_t(to)) == 1
}
