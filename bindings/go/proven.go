// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Package proven provides Go bindings to the proven-servers Zig FFI layer.
//
// All 10 core protocols (HTTP, DNS, Firewall, FTP, GraphQL, gRPC, MQTT, SMTP,
// SSH) share a common slot-based context pool pattern. Each protocol module
// creates a context via its Create function and automatically destroys it
// when the Context wrapper is closed.
//
// Error handling follows the ProvenError type which maps the C-ABI return
// codes (slot=-1 for pool exhaustion, status!=0 for state/validation errors)
// to descriptive Go errors.
package proven

// #cgo LDFLAGS: -lproven_httpd -lproven_dns -lproven_firewall -lproven_ftp -lproven_graphql -lproven_grpc -lproven_mqtt -lproven_smtp -lproven_ssh_bastion
import "C"

import "fmt"

// ProvenError represents a unified error from the proven-servers FFI layer.
// All protocol bindings return this error type for consistency with the
// Idris2 ABI / Zig FFI error model.
type ProvenError struct {
	// Code is the raw FFI return code.
	Code int
	// Kind describes the error category.
	Kind ErrorKind
}

// ErrorKind enumerates the categories of proven-servers FFI errors.
// These map directly to the ProvenError variants in the Rust bindings.
type ErrorKind int

const (
	// ErrPoolExhausted indicates all 64 context slots are in use.
	ErrPoolExhausted ErrorKind = iota
	// ErrInvalidSlot indicates the slot index is invalid or inactive.
	ErrInvalidSlot
	// ErrInvalidState indicates the operation was rejected due to wrong
	// lifecycle state.
	ErrInvalidState
	// ErrInvalidParameter indicates a parameter value outside the valid
	// ABI tag range.
	ErrInvalidParameter
	// ErrCapacityExceeded indicates a fixed-size buffer or array limit
	// was exceeded.
	ErrCapacityExceeded
	// ErrValidationFailed indicates input validation failed (e.g.
	// traversal attack, length exceeded).
	ErrValidationFailed
	// ErrUnknown indicates an undocumented FFI return code.
	ErrUnknown
)

// Error implements the error interface for ProvenError.
func (e *ProvenError) Error() string {
	switch e.Kind {
	case ErrPoolExhausted:
		return "proven: context pool exhausted (64-slot limit)"
	case ErrInvalidSlot:
		return "proven: invalid or inactive context slot"
	case ErrInvalidState:
		return "proven: operation rejected: wrong lifecycle state"
	case ErrInvalidParameter:
		return "proven: parameter value outside valid ABI tag range"
	case ErrCapacityExceeded:
		return "proven: fixed-size buffer or array capacity exceeded"
	case ErrValidationFailed:
		return "proven: input validation failed"
	case ErrUnknown:
		return fmt.Sprintf("proven: unknown FFI error (code %d)", e.Code)
	default:
		return fmt.Sprintf("proven: error (code %d)", e.Code)
	}
}

// slotError interprets a slot-returning FFI call. Returns the slot index
// or an error if the slot is negative (pool exhausted).
func slotError(slot C.int) (int, error) {
	if slot >= 0 {
		return int(slot), nil
	}
	return -1, &ProvenError{Code: int(slot), Kind: ErrPoolExhausted}
}

// statusError interprets a status-returning FFI call (0=success, 1=invalid
// state, 2=validation failed).
func statusError(status C.uchar) error {
	switch status {
	case 0:
		return nil
	case 1:
		return &ProvenError{Code: 1, Kind: ErrInvalidState}
	case 2:
		return &ProvenError{Code: 2, Kind: ErrValidationFailed}
	default:
		return &ProvenError{Code: int(status), Kind: ErrUnknown}
	}
}
